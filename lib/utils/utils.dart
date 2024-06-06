bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

extension OnlyStringExtension on String {
  String only(int max) => max >= (length - 1) ? this : substring(0, max);
}

extension OnlyListExtension on List {
  List only(int max) => max >= (length - 1) ? this : sublist(0, max);
}
