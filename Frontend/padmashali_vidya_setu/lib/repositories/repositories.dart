import '../core/api/api_client.dart';
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
}

class MemberRepository {
  MemberRepository(this._api);
  final ApiClient _api;

  Future<MyAccount> myAccount() => _api.get('/api/v1/me', MyAccount.fromJson);

  Future<RegistrationResult> register(Map<String, Object?> request) =>
      _api.post('/api/v1/members', request, RegistrationResult.fromJson);

  Future<MemberProfile> profile(String registrationId) =>
      _api.get('/api/v1/members/$registrationId', MemberProfile.fromJson);

  Future<MemberDashboard> dashboard(String registrationId) =>
      _api.get('/api/v1/members/$registrationId/dashboard', MemberDashboard.fromJson);
}
