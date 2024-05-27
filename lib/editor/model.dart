import 'package:nanoid/nanoid.dart';

enum Operator {
  add,
  subtract,
  multiply,
  divide,
  equals,
  none,
}

class ListItemModel {
  final int index;
  final String fullText;
  final String textPart;
  final Operator operator;
  final num? number;
  final String uid;
  final int indent;
  final bool checked;

  ListItemModel({
    this.indent = 0,
    required this.textPart,
    required this.operator,
    required this.number,
    required this.index,
    required this.fullText,
    this.checked = false,
  }) : uid = nanoid();

  ListItemModel copyWith({
    int? index,
    String? fullText,
    String? textPart,
    bool? checked,
    Operator? operator,
    num? number,
    int? indent,
  }) {
    return ListItemModel(
      index: index ?? this.index,
      fullText: fullText ?? this.fullText,
      textPart: textPart ?? this.textPart,
      operator: operator ?? this.operator,
      number: number ?? this.number,
      indent: indent ?? this.indent,
      checked: checked ?? this.checked,
    );
  }
}
