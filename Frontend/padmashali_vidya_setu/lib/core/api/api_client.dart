import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_exception.dart';

typedef JsonParser<T> = T Function(Object? data);

/// Thin wrapper over Dio for the PVS API:
/// * unwraps the `{ success, message, data, errors }` envelope,
/// * attaches the bearer token,
/// * on 401 refreshes the session once (shared by concurrent requests) and retries,
/// * converts every failure into an [ApiException].
class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    required void Function() onSessionExpired,
    Dio? dio,
  }) : _tokens = tokenStorage,
       _onSessionExpired = onSessionExpired,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 30),
               contentType: Headers.jsonContentType,
               responseType: ResponseType.json,
             ),
           ) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: _attachToken));
  }

  final Dio _dio;
  final TokenStorage _tokens;
  final void Function() _onSessionExpired;
  Future<bool>? _refreshInFlight;

  static const _refreshPath = '/api/v1/auth/token/refresh';

  Future<T> get<T>(String path, JsonParser<T> parse, {Map<String, Object?>? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: query), parse);

  Future<T> post<T>(String path, Object? body, JsonParser<T> parse) =>
      _send(() => _dio.post<Object?>(path, data: body), parse);

  Future<void> _attachToken(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path != _refreshPath && !options.headers.containsKey('Authorization')) {
      final tokens = await _tokens.read();
      if (tokens != null) options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  Future<T> _send<T>(Future<Response<Object?>> Function() request, JsonParser<T> parse) async {
    try {
      return _unwrap(await request(), parse);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && e.requestOptions.path != _refreshPath && await _tryRefresh()) {
        try {
          return _unwrap(await request(), parse);
        } on DioException catch (retryError) {
          throw _toApiException(retryError);
        }
      }
      throw _toApiException(e);
    }
  }

  /// Returns true when a new access token was obtained. Concurrent callers share one refresh.
  Future<bool> _tryRefresh() {
    return _refreshInFlight ??= _refresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<bool> _refresh() async {
    final current = await _tokens.read();
    if (current == null) return false;
    try {
      final response = await _dio.post<Object?>(_refreshPath, data: {'refreshToken': current.refreshToken});
      final data = _unwrap(response, (d) => d as Map<String, Object?>);
      await _tokens.write(
        StoredTokens(accessToken: data['accessToken']! as String, refreshToken: data['refreshToken']! as String),
      );
      return true;
    } on DioException {
      await _tokens.clear();
      _onSessionExpired();
      return false;
    }
  }

  static T _unwrap<T>(Response<Object?> response, JsonParser<T> parse) {
    final body = response.data;
    if (body is Map<String, Object?> && body['success'] == true) return parse(body['data']);
    throw ApiException(kind: ApiErrorKind.server, message: null, statusCode: response.statusCode);
  }

  static ApiException _toApiException(DioException e) {
    final response = e.response;
    if (response == null) {
      return const ApiException(kind: ApiErrorKind.network, message: null);
    }

    String? message;
    final fieldErrors = <String, String>{};
    final body = response.data;
    if (body is Map<String, Object?>) {
      message = body['message'] as String?;
      final errors = body['errors'];
      if (errors is List) {
        for (final item in errors.whereType<Map<String, Object?>>()) {
          final field = item['field'] as String?;
          final text = item['message'] as String?;
          if (field != null && text != null) fieldErrors.putIfAbsent(field, () => text);
        }
      }
    }

    final status = response.statusCode ?? 0;
    final kind = switch (status) {
      400 || 422 => ApiErrorKind.validation,
      401 => ApiErrorKind.unauthorized,
      403 => ApiErrorKind.forbidden,
      404 => ApiErrorKind.notFound,
      409 => ApiErrorKind.conflict,
      429 => ApiErrorKind.tooManyRequests,
      503 => ApiErrorKind.unavailable,
      _ => ApiErrorKind.server,
    };
    return ApiException(
      kind: kind,
      message: message,
      statusCode: status,
      fieldErrors: fieldErrors,
      retryAfterSeconds: int.tryParse(response.headers.value('retry-after') ?? ''),
    );
  }
}
