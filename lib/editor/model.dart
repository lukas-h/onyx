import 'package:nanoid/nanoid.dart';

enum Operator {
  add,
  subtract,
  multiply,
  divide,
  equals,
  none,
}

class ListItemState {
  final int index;
  final String fullText;
  final String textPart;
  final Operator operator;
  final num? number;
  final String uid;
  final int indent;
  final bool checked;
  final int position;

  ListItemState({
    this.indent = 0,
    required this.textPart,
    required this.operator,
    required this.number,
    required this.index,
    required this.position,
    required this.fullText,
    this.checked = false,
  }) : uid = nanoid(15);

  factory ListItemState.unparsed({
    required int index,
    required int position,
    required String fullText,
  }) =>
      ListItemState(
        textPart: '',
        operator: Operator.none,
        number: null,
        index: index,
        fullText: fullText,
        position: position,
      );

  ListItemState copyWith({
    int? index,
    String? fullText,
    String? textPart,
    bool? checked,
    Operator? operator,
    num? number,
    int? indent,
    int? position,
  }) =>
      ListItemState(
        index: index ?? this.index,
        fullText: fullText ?? this.fullText,
        textPart: textPart ?? this.textPart,
        operator: operator ?? this.operator,
        number: number ?? this.number,
        indent: indent ?? this.indent,
        checked: checked ?? this.checked,
        position: position ?? this.position,
      );

  @override
  String toString() {
    return "\n==========| SEARCH STARTED |==========\n"
        "index: $index   \nfullText:  $fullText \ntextPart:  $textPart; "
        "\noperator:  "
        "$operator;\nnumber:  $number;\n$uid;\nindent:  $indent;"
        "\nchecked:  $checked;"
        "\nposition:  $position\n\n\n==========| END |============";
  }
}
