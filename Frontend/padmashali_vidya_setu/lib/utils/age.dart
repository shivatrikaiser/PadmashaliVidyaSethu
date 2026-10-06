/// Age in completed years on [today]. Mirrors the backend's AgeCalculator.
int ageOn(DateTime dateOfBirth, DateTime today) {
  var age = today.year - dateOfBirth.year;
  final hadBirthdayThisYear =
      today.month > dateOfBirth.month ||
      (today.month == dateOfBirth.month && today.day >= _birthdayDay(dateOfBirth, today.year));
  if (!hadBirthdayThisYear) age--;
  return age;
}

/// 29 Feb birthdays fall on 28 Feb in non-leap years (same convention as the API).
int _birthdayDay(DateTime dob, int year) {
  if (dob.month == 2 && dob.day == 29 && !_isLeap(year)) return 28;
  return dob.day;
}

bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

/// Today's date with the time stripped.
DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
