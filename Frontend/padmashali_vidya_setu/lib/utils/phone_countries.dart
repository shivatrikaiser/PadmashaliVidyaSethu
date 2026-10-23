/// Country calling codes offered for mobile numbers. India (+91) is the default: its numbers get a code by SMS;
/// numbers in every other country get it on WhatsApp.
class DialCode {
  const DialCode(this.code, this.label);

  /// Digits only, e.g. "971".
  final String code;

  /// Shown in the picker, e.g. "United Arab Emirates".
  final String label;

  bool get isIndia => code == DialCodes.india;
}

abstract final class DialCodes {
  static const india = '91';

  /// The countries members live in (matches the address country list); add more as needed.
  static const all = [
    DialCode(india, 'India'),
    DialCode('971', 'United Arab Emirates'),
    DialCode('968', 'Oman'),
    DialCode('974', 'Qatar'),
    DialCode('966', 'Saudi Arabia'),
    DialCode('965', 'Kuwait'),
    DialCode('973', 'Bahrain'),
    DialCode('1', 'United States / Canada'),
    DialCode('44', 'United Kingdom'),
    DialCode('61', 'Australia'),
    DialCode('65', 'Singapore'),
    DialCode('49', 'Germany'),
    DialCode('64', 'New Zealand'),
  ];

  /// What the API expects: Indian numbers as the 10 digits, others in E.164 form (+CCNNNN...).
  static String apiNumber(String code, String digits) => code == india ? digits : '+$code${nationalDigits(digits)}';

  /// The national number without a leading trunk "0" (e.g. UK "07911..." → "7911..."), as E.164 needs it.
  static String nationalDigits(String digits) => digits.replaceFirst(RegExp(r'^0+'), '');

  /// Longest national number accepted for [code] (E.164 allows 15 digits including the country code).
  static int maxDigits(String code) => code == india ? 10 : 15 - code.length;
}
