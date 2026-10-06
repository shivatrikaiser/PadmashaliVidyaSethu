/// Pure validation rules mirroring the backend validators. They return a key
/// that the UI maps to a localized message, keeping this file free of UI strings.
enum ValidationIssue { required, nameTooShort, nameInvalid, addressTooShort, phoneInvalid, pinInvalid }

abstract final class Validators {
  // Letters in any script (Kannada names work), spaces, dots, apostrophes, hyphens.
  static final _name = RegExp(r"^[\p{L}\p{M}][\p{L}\p{M} .'\-]*$", unicode: true);
  static final _indianMobile = RegExp(r'^[6-9]\d{9}$');
  static final _pin = RegExp(r'^[1-9]\d{5}$');

  static ValidationIssue? personName(String? value) {
    final v = tidy(value);
    if (v.isEmpty) return ValidationIssue.required;
    if (v.length < 2) return ValidationIssue.nameTooShort;
    if (!_name.hasMatch(v)) return ValidationIssue.nameInvalid;
    return null;
  }

  static ValidationIssue? mobile(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return ValidationIssue.required;
    return _indianMobile.hasMatch(digits) ? null : ValidationIssue.phoneInvalid;
  }

  static ValidationIssue? pinCode(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return ValidationIssue.required;
    return _pin.hasMatch(v) ? null : ValidationIssue.pinInvalid;
  }

  static bool isCompletePin(String value) => _pin.hasMatch(value.trim());

  static ValidationIssue? addressLine(String? value) {
    final v = tidy(value);
    if (v.isEmpty) return ValidationIssue.required;
    return v.length < 3 ? ValidationIssue.addressTooShort : null;
  }

  static ValidationIssue? requiredText(String? value) => tidy(value).isEmpty ? ValidationIssue.required : null;

  static String tidy(String? value) => (value ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');
}
