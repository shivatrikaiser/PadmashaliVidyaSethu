import 'master_data_item.dart';

class VerificationChallenge {
  const VerificationChallenge({
    required this.challengeId,
    required this.maskedMobileNumber,
    required this.codeLength,
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
    this.developmentCode,
  });

  final String challengeId;
  final String maskedMobileNumber;
  final int codeLength;
  final int expiresInSeconds;
  final int resendAfterSeconds;

  /// Only present when the backend runs in Development with code exposure enabled.
  final String? developmentCode;

  factory VerificationChallenge.fromJson(Object? json) {
    final m = json! as Json;
    return VerificationChallenge(
      challengeId: m['challengeId']! as String,
      maskedMobileNumber: m['maskedMobileNumber']! as String,
      codeLength: m['codeLength']! as int,
      expiresInSeconds: m['expiresInSeconds']! as int,
      resendAfterSeconds: m['resendAfterSeconds']! as int,
      developmentCode: m['developmentCode'] as String?,
    );
  }
}

/// A code sent to a member's (optional) email address - its own code, separate from the mobile number's.
class EmailChallenge {
  const EmailChallenge({
    required this.challengeId,
    required this.maskedEmail,
    required this.codeLength,
    required this.resendAfterSeconds,
    this.developmentCode,
  });

  final String challengeId;
  final String maskedEmail;
  final int codeLength;
  final int resendAfterSeconds;

  /// Only present when the backend runs in Development with code exposure enabled.
  final String? developmentCode;

  factory EmailChallenge.fromJson(Object? json) {
    final m = json! as Json;
    return EmailChallenge(
      challengeId: m['challengeId']! as String,
      maskedEmail: m['maskedEmail']! as String,
      codeLength: m['codeLength']! as int,
      resendAfterSeconds: m['resendAfterSeconds']! as int,
      developmentCode: m['developmentCode'] as String?,
    );
  }
}

class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewAccount,
    required this.registeredMemberCount,
  });

  final String accessToken;
  final String refreshToken;
  final bool isNewAccount;
  final int registeredMemberCount;

  factory AuthResult.fromJson(Object? json) {
    final m = json! as Json;
    return AuthResult(
      accessToken: m['accessToken']! as String,
      refreshToken: m['refreshToken']! as String,
      isNewAccount: m['isNewAccount']! as bool,
      registeredMemberCount: m['registeredMemberCount']! as int,
    );
  }
}
