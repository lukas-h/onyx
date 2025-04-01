bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month && date.day == now.day;
}

extension OnlyStringExtension on String {
  String only(int max) => max >= (length - 1) ? this : substring(0, max);
}

extension OnlyListExtension on List {
  List only(int max) => max >= (length - 1) ? this : sublist(0, max);
}

String fourDigits(int n) {
  int absN = n.abs();
  String sign = n < 0 ? "-" : "";
  if (absN >= 1000) return "$n";
  if (absN >= 100) return "${sign}0$absN";
  if (absN >= 10) return "${sign}00$absN";
  return "${sign}000$absN";
}

String twoDigits(int n) {
  if (n >= 10) return "${n}";
  return "0${n}";
}

String dateTimeToYYYYMMDDString(DateTime date) {
  String y = fourDigits(date.year);
  String m = twoDigits(date.month);
  String d = twoDigits(date.day);
  return "$y-$m-$d";
}
