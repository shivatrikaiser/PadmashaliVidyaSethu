import '../core/api/api_client.dart';
import '../models/app_branding.dart';
import '../models/app_version.dart';
import '../models/auth_models.dart';
import '../models/location_models.dart';
import '../models/master_data_item.dart';
import '../models/member_models.dart';

class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  Future<VerificationChallenge> requestCode(String mobileNumber) =>
      _api.post('/api/v1/auth/verification-codes', {'mobileNumber': mobileNumber}, VerificationChallenge.fromJson);

  Future<AuthResult> verifyCode(String challengeId, String code) => _api.post(
    '/api/v1/auth/verification-codes/verify',
    {'challengeId': challengeId, 'code': code},
    AuthResult.fromJson,
  );

  Future<void> logout(String refreshToken) => _api.post('/api/v1/auth/logout', {'refreshToken': refreshToken}, (_) {});
}

class MasterDataRepository {
  MasterDataRepository(this._api);
  final ApiClient _api;

  Future<List<MasterDataItem>> list(String type) => _api.get('/api/v1/master-data/$type', MasterDataItem.listFromJson);

  Future<List<MasterDataItem>> states(int countryId) =>
      _api.get('/api/v1/locations/countries/$countryId/states', MasterDataItem.listFromJson);

  Future<List<MasterDataItem>> districts(int stateId) =>
      _api.get('/api/v1/locations/states/$stateId/districts', MasterDataItem.listFromJson);

  Future<List<MasterDataItem>> taluks(int districtId) =>
      _api.get('/api/v1/locations/districts/$districtId/taluks', MasterDataItem.listFromJson);

  Future<PinLookupResult> lookupPinCode(String pinCode) =>
      _api.get('/api/v1/locations/pin-codes/$pinCode', PinLookupResult.fromJson);

  /// Splash-screen sponsor / "Powered by" (public, works before sign-in).
  Future<AppBranding> branding() => _api.get('/api/v1/app/branding', AppBranding.fromJson);

  /// The current app release for [platform] (android | ios) - public, checked on every screen.
  Future<AppVersionInfo> appVersion(String platform) =>
      _api.get('/api/v1/app/version', AppVersionInfo.fromJson, query: {'platform': platform});
}

/// Messages from the Contact us screen, sent to the shared enquiry service (the same one as the VidyaSethu website's
/// forms; emailed to support).
class EnquiryRepository {
  EnquiryRepository(this._api);
  final ApiClient _api;

  Future<void> send({
    required String name,
    required String email,
    required String phone,
    required String message,
    required Duration elapsed,
  }) {
    String? value(String s) => s.trim().isEmpty ? null : s.trim();
    return _api.post('/api/v1/enquiries', {
      'category': 'general',
      'name': name.trim(),
      'organization': 'Padmashali Vidya Sethu app',
      'email': value(email),
      'phone': value(phone),
      'message': message.trim(),
      'consent': true,
      'locale': 'en',
      'page': 'pvs-app/contact',
      'elapsedMs': elapsed.inMilliseconds,
    }, (_) {});
  }
}

class MemberRepository {
  MemberRepository(this._api);
  final ApiClient _api;

  Future<MyAccount> myAccount() => _api.get('/api/v1/me', MyAccount.fromJson);

  /// Sends a verification code to a member's own (optional) mobile number while registering them.
  Future<VerificationChallenge> requestMemberMobileCode(String mobileNumber) =>
      _api.post('/api/v1/members/mobile-verifications', {'mobileNumber': mobileNumber}, VerificationChallenge.fromJson);

  /// Deletes the signed-in account: kept for the records but marked deleted; the number cannot sign in again.
  Future<void> deleteMyAccount() => _api.post('/api/v1/me/deletion', null, (_) {});

  /// Sends a code (separate from the mobile number's) to a member's optional email address.
  Future<EmailChallenge> requestMemberEmailCode(String email) =>
      _api.post('/api/v1/members/email-verifications', {'email': email}, EmailChallenge.fromJson);

  /// Returns the verified challenge id, sent as `emailVerificationId` when registering.
  Future<String> verifyMemberEmailCode(String challengeId, String code) => _api.post(
    '/api/v1/members/email-verifications/verify',
    {'challengeId': challengeId, 'code': code},
    (d) => (d! as Map<String, Object?>)['challengeId']! as String,
  );

  /// Checks that code; the returned challenge id goes into the registration as `mobileVerificationId`.
  Future<String> verifyMemberMobileCode(String challengeId, String code) => _api.post(
    '/api/v1/members/mobile-verifications/verify',
    {'challengeId': challengeId, 'code': code},
    (d) => (d! as Map<String, Object?>)['challengeId']! as String,
  );

  Future<RegistrationResult> register(Map<String, Object?> request) =>
      _api.post('/api/v1/members', request, RegistrationResult.fromJson);

  Future<MemberProfile> profile(String registrationId) =>
      _api.get('/api/v1/members/$registrationId', MemberProfile.fromJson);

  Future<MemberDashboard> dashboard(String registrationId) =>
      _api.get('/api/v1/members/$registrationId/dashboard', MemberDashboard.fromJson);
}
