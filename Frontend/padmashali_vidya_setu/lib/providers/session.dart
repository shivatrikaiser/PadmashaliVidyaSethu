import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/auth_models.dart';
import '../models/member_models.dart';
import '../repositories/repositories.dart';
import '../utils/phone_countries.dart';

enum SessionStatus { unknown, signedOut, signedIn }

class SessionState {
  const SessionState({
    required this.status,
    this.account,
    this.selectedRegistrationId,
    this.expired = false,
    this.accountDeleted = false,
  });

  final SessionStatus status;
  final MyAccount? account;
  final String? selectedRegistrationId;

  /// True when the session ended because tokens could not be refreshed (shown once on the welcome screen).
  final bool expired;

  /// True right after the user deleted their account (shown once on the welcome screen).
  final bool accountDeleted;

  bool get hasMembers => (account?.members.isNotEmpty) ?? false;

  MemberSummary? get selectedMember {
    final members = account?.members ?? const [];
    if (members.isEmpty) return null;
    return members.firstWhere((m) => m.registrationId == selectedRegistrationId, orElse: () => members.first);
  }

  SessionState copyWith({MyAccount? account, String? selectedRegistrationId}) => SessionState(
    status: status,
    account: account ?? this.account,
    selectedRegistrationId: selectedRegistrationId ?? this.selectedRegistrationId,
  );
}

class PendingVerification {
  const PendingVerification({
    required this.mobileNumber,
    required this.challenge,
    required this.issuedAt,
    this.countryCode = DialCodes.india,
  });

  /// The number as typed (national digits) and its calling code; [apiMobileNumber] is what the API gets.
  final String mobileNumber;
  final String countryCode;
  String get apiMobileNumber => DialCodes.apiNumber(countryCode, mobileNumber);
  final VerificationChallenge challenge;
  final DateTime issuedAt;
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier({required TokenStorage tokens, required AuthRepository auth, required MemberRepository members})
    : _tokens = tokens,
      _auth = auth,
      _members = members,
      super(const SessionState(status: SessionStatus.unknown));

  final TokenStorage _tokens;
  final AuthRepository _auth;
  final MemberRepository _members;

  /// On app start: resume a stored session if it is still valid.
  /// Restores the stored session. The result is applied no sooner than [minimumDuration] (the splash screen's
  /// display time); the check itself runs immediately.
  Future<void> bootstrap({Duration minimumDuration = Duration.zero}) async {
    final minimum = Future<void>.delayed(minimumDuration);
    if (await _tokens.read() == null) {
      await minimum;
      state = const SessionState(status: SessionStatus.signedOut);
      return;
    }
    try {
      final account = await _members.myAccount();
      await minimum;
      state = SessionState(status: SessionStatus.signedIn, account: account);
    } on ApiException catch (e) {
      await minimum;
      if (e.isUnauthorized) {
        await _tokens.clear();
        state = const SessionState(status: SessionStatus.signedOut);
      } else {
        // Offline / server trouble: stay "unknown" so the splash screen can offer a retry.
        rethrow;
      }
    }
  }

  Future<void> signIn(AuthResult result) async {
    await _tokens.write(StoredTokens(accessToken: result.accessToken, refreshToken: result.refreshToken));
    final account = await _members.myAccount();
    state = SessionState(status: SessionStatus.signedIn, account: account);
  }

  Future<MyAccount> refreshAccount() async {
    final account = await _members.myAccount();
    state = state.copyWith(account: account);
    return account;
  }

  void selectMember(String registrationId) => state = state.copyWith(selectedRegistrationId: registrationId);

  Future<void> signOut() async {
    final tokens = await _tokens.read();
    if (tokens != null) {
      try {
        await _auth.logout(tokens.refreshToken);
      } on ApiException {
        // Signing out locally must always succeed.
      }
    }
    await _tokens.clear();
    state = const SessionState(status: SessionStatus.signedOut);
  }

  /// Deletes the account on the server (data kept, number blocked), then signs out on this device.
  Future<void> deleteAccount() async {
    await _members.deleteMyAccount();
    await _tokens.clear();
    state = const SessionState(status: SessionStatus.signedOut, accountDeleted: true);
  }

  void onSessionExpired() {
    if (state.status == SessionStatus.signedOut) return;
    state = const SessionState(status: SessionStatus.signedOut, expired: true);
  }
}
