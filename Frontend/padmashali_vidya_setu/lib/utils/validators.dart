import 'phone_countries.dart';

/// Pure validation rules mirroring the backend validators. They return a key
/// that the UI maps to a localized message, keeping this file free of UI strings.
enum ValidationIssue {
  required,
  nameTooShort,
  nameInvalid,
  addressTooShort,
  phoneInvalid,
  phoneInvalidInternational,
  emailInvalid,
  pinInvalid,
  postalCodeInvalid,
}

abstract final class Validators {
  // Letters in any script (Kannada names work), spaces, dots, apostrophes, hyphens.
  static final _name = RegExp(r"^[\p{L}\p{M}][\p{L}\p{M} .'\-]*$", unicode: true);
  static final _indianMobile = RegExp(r'^[6-9]\d{9}$');
  static final _pin = RegExp(r'^[1-9]\d{5}$');
  // Same shape check as the API (local@domain.tld).
  static final _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~\-]+@[A-Za-z0-9](?:[A-Za-z0-9\-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9\-]{0,61}[A-Za-z0-9])?)+$",
  );
  static final _postalCode = RegExp(r'^[A-Za-z0-9][A-Za-z0-9 \-]{1,9}$');

  static ValidationIssue? personName(String? value) {
    final v = tidy(value);
    if (v.isEmpty) return ValidationIssue.required;
    if (v.length < 2) return ValidationIssue.nameTooShort;
    if (!_name.hasMatch(v)) return ValidationIssue.nameInvalid;
    return null;
  }

  /// [countryCode] is the calling code without "+": India (default) needs 10 digits starting 6-9; other countries a
  /// number that makes 8-15 digits with the code (E.164).
  static ValidationIssue? mobile(String? value, {String countryCode = DialCodes.india}) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return ValidationIssue.required;
    if (countryCode == DialCodes.india) return _indianMobile.hasMatch(digits) ? null : ValidationIssue.phoneInvalid;
    final total = countryCode.length + DialCodes.nationalDigits(digits).length;
    return total >= 8 && total <= 15 ? null : ValidationIssue.phoneInvalidInternational;
  }

  static ValidationIssue? pinCode(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return ValidationIssue.required;
    return _pin.hasMatch(v) ? null : ValidationIssue.pinInvalid;
  }

  static bool isCompletePin(String value) => _pin.hasMatch(value.trim());

  /// Required email address (asked with a mobile number outside India).
  static ValidationIssue? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return ValidationIssue.required;
    return v.length <= 254 && _email.hasMatch(v) ? null : ValidationIssue.emailInvalid;
  }

  /// Postal code of an address outside India: optional, letters, digits, spaces and hyphens.
  static ValidationIssue? postalCode(String? value) {
    final v = tidy(value);
    if (v.isEmpty) return null;
    return _postalCode.hasMatch(v) ? null : ValidationIssue.postalCodeInvalid;
  }

  static ValidationIssue? addressLine(String? value) {
    final v = tidy(value);
    if (v.isEmpty) return ValidationIssue.required;
    return v.length < 3 ? ValidationIssue.addressTooShort : null;
  }

  static ValidationIssue? requiredText(String? value) => tidy(value).isEmpty ? ValidationIssue.required : null;

  static String tidy(String? value) => (value ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');
}
