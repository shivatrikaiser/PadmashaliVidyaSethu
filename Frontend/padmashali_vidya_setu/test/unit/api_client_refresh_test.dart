import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/core/api/api_client.dart';
import 'package:padmashali_vidya_setu/core/api/api_exception.dart';
import 'package:padmashali_vidya_setu/core/storage/token_storage.dart';

/// Answers every request with [handler] instead of the network.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  late MemoryTokenStorage tokens;
  late bool expired;

  ApiClient client(ResponseBody Function(RequestOptions options) handler) {
    final dio = Dio(BaseOptions(baseUrl: 'http://test.invalid', responseType: ResponseType.json))
      ..httpClientAdapter = _FakeAdapter(handler);
    return ApiClient(
      baseUrl: 'http://test.invalid',
      tokenStorage: tokens,
      onSessionExpired: () => expired = true,
      dio: dio,
    );
  }

  setUp(() async {
    tokens = MemoryTokenStorage();
    await tokens.write(const StoredTokens(accessToken: 'old-access', refreshToken: 'refresh-1'));
    expired = false;
  });

  test('offline while refreshing keeps the session and reports a network error', () async {
    final api = client((o) {
      if (o.path.endsWith('/token/refresh')) {
        throw DioException.connectionError(requestOptions: o, reason: 'offline');
      }
      return _json(401, {'success': false});
    });

    await expectLater(
      api.get('/api/v1/me', (d) => d),
      throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.network)),
    );
    expect(expired, isFalse);
    expect((await tokens.read())?.refreshToken, 'refresh-1');
  });

  test('a server error while refreshing keeps the session', () async {
    final api = client(
      (o) => o.path.endsWith('/token/refresh') ? _json(503, {'success': false}) : _json(401, {'success': false}),
    );

    await expectLater(api.get('/api/v1/me', (d) => d), throwsA(isA<ApiException>()));
    expect(expired, isFalse);
    expect(await tokens.read(), isNotNull);
  });

  test('a rejected refresh token ends the session', () async {
    final api = client((o) => _json(401, {'success': false}));

    await expectLater(api.get('/api/v1/me', (d) => d), throwsA(isA<ApiException>()));
    expect(expired, isTrue);
    expect(await tokens.read(), isNull);
  });

  test('a successful refresh retries the request with the new token', () async {
    final api = client((o) {
      if (o.path.endsWith('/token/refresh')) {
        return _json(200, {
          'success': true,
          'data': {'accessToken': 'new-access', 'refreshToken': 'refresh-2'},
        });
      }
      return o.headers['Authorization'] == 'Bearer new-access'
          ? _json(200, {'success': true, 'data': 'ok'})
          : _json(401, {'success': false});
    });

    expect(await api.get('/api/v1/me', (d) => d), 'ok');
    expect((await tokens.read())?.refreshToken, 'refresh-2');
  });
}
