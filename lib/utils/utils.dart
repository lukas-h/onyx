import 'package:intl/intl.dart';
import 'package:onyx/editor/model.dart';

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

num calculateTotal(List<ListItemState> items, int untilIndex) {
  final limit = untilIndex < items.length ? untilIndex : items.length;
  if (limit == 0) return 0;

  // Filter out items that have neither a number nor a valid operator
  var working = List.of(items.take(limit))
      .where((item) =>
          item.number != null ||
          (item.operator == Operator.add || item.operator == Operator.subtract || item.operator == Operator.multiply || item.operator == Operator.divide))
      .toList();

  // Reduce groups of 2+ adjacent items with the same (max) indent
  // TODO: Replace while (true) with a more controlled loop to avoid infinite loops
  while (true) {
    if (working.length < 2) break;
    final maxIndent = working.map((e) => e.indent).fold(0, (a, b) => a > b ? a : b);

    // Find the first group of 2+ adjacent items with maxIndent
    int start = -1, end = -1;
    for (int i = 0; i < working.length;) {
      if (working[i].indent == maxIndent) {
        int j = i;
        while (j < working.length && working[j].indent == maxIndent) j++;
        if (j - i > 1) {
          start = i;
          end = j;
          break;
        }
        i = j;
      } else {
        i++;
      }
    }
    if (start == -1 || end == -1 || maxIndent == 0) break;

    // Reduce the group left-to-right
    num acc = working[start].number ?? 0;
    for (int i = start + 1; i < end; i++) {
      final op = working[i].operator;
      final n = working[i].number ?? 0;
      acc = switch (op) {
        Operator.add => acc + n,
        Operator.subtract => acc - n,
        Operator.multiply => acc * n,
        Operator.divide => n != 0 ? acc / n : 0,
        _ => n,
      };
    }

    // Replace the group with a single item (copy first, update number and indent)
    final itemToCopy = working[start];
    working.replaceRange(start, end, [itemToCopy.copyWith(number: acc, indent: maxIndent - 1)]);
  }

  // Sum up the remaining items
  num sum = 0;
  for (var item in working) {
    final n = item.number ?? (item.operator == Operator.multiply || item.operator == Operator.divide ? 1 : 0);
    switch (item.operator) {
      case Operator.add:
        sum += n;
        break;
      case Operator.subtract:
        sum -= n;
        break;
      case Operator.multiply:
        sum *= n;
        break;
      case Operator.divide:
        sum /= n;
        break;
      default:
        break;
    }
  }
  return sum;
}

extension OnlyStringExtension on String {
  String only(int max) => max >= (length - 1) ? this : substring(0, max);
}

extension OnlyListExtension on List {
  List only(int max) => max >= (length - 1) ? this : sublist(0, max);
}

final ddmmyyyy = DateFormat.yMd('en_AU');
