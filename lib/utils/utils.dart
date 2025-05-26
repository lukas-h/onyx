import 'package:intl/intl.dart';

bool isToday(String dateString) {
  try {
    final now = DateTime.now();
    final date = ddmmyyyy.parse(dateString);
    return date.year == now.year && date.month == now.month && date.day == now.day;
  } catch (e) {
    return true;
  }
}

String parseDateOrToday(String dateString) {
  try {
    ddmmyyyy.parse(dateString);
    return dateString;
  } catch (e) {
    return ddmmyyyy.format(DateTime.now());
  }
}

extension OnlyStringExtension on String {
  String only(int max) => max >= (length - 1) ? this : substring(0, max);
}

extension OnlyListExtension on List {
  List only(int max) => max >= (length - 1) ? this : sublist(0, max);
}

final ddmmyyyy = DateFormat.yMd('en_AU');
