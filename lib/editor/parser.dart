import 'package:onyx/editor/model.dart';

final mathematicalExpressionRegex =
    RegExp(r'^(?<op>:[=+-/*]?)(?<num>[0-9]+([,.]?[0-9]+)?)?(?<text>.*)');

final operators = {
  ':-': Operator.subtract,
  ':+': Operator.add,
  ':/': Operator.divide,
  ':*': Operator.multiply,
  ':=': Operator.equals,
};

abstract class Parser {
  static ListItemState parse(ListItemState model) {
    int parseIndent(String fullText) {
      final leadingWhitespace = RegExp(r'^\s+');
      final match = leadingWhitespace.firstMatch(fullText);
      final count = match?.group(0)?.length ?? 0;

      return (count / 2).round().clamp(0, 12);
    }

    var updatedModel = model;
    var source = model.fullText.trim();
    updatedModel = updatedModel.copyWith(indent: parseIndent(model.fullText));

    Operator operator = Operator.none;
    num? number;

    RegExpMatch? match = mathematicalExpressionRegex.firstMatch(source);

    if (match != null) {
      operator = operators[match.namedGroup("op")] ?? Operator.add;

      if (operator != Operator.equals) {
        number = num.tryParse(match.namedGroup("num") ?? "");

        if (number != null) {
          source = match.namedGroup("text")?.trim() ?? "";
        }
      } else {
        source = source.substring(match.namedGroup("op")?.length ?? 0);
      }
    }

    updatedModel = updatedModel.copyWith(
      textPart: source,
      operator: operator,
      number: number,
    );

    return updatedModel;
  }
}
