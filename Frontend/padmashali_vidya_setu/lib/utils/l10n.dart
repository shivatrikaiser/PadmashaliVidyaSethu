import 'package:flutter/widgets.dart';

import '../core/api/api_exception.dart';
import '../l10n/generated/app_localizations.dart';
import 'validators.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension ValidationIssueText on ValidationIssue {
  String text(AppLocalizations l10n) => switch (this) {
    ValidationIssue.required => l10n.validationRequired,
    ValidationIssue.nameTooShort => l10n.validationNameTooShort,
    ValidationIssue.nameInvalid => l10n.validationNameInvalid,
    ValidationIssue.addressTooShort => l10n.validationAddressTooShort,
    ValidationIssue.phoneInvalid => l10n.phoneInvalid,
    ValidationIssue.pinInvalid => l10n.validationPinInvalid,
  };
}

/// User-facing text for any error. Server messages are already written for users; network and
/// unexpected errors get localized fallbacks. Internal details are never shown.
String describeError(AppLocalizations l10n, Object error) {
  if (error is ApiException) {
    if (error.isNetwork) return l10n.errorNetwork;
    if (error.isUnauthorized) return l10n.errorSessionExpired;
    return error.message ?? l10n.errorGeneric;
  }
  return l10n.errorGeneric;
}
