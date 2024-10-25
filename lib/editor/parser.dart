import 'package:onyx/editor/model.dart';

final expression = RegExp(r'^\:[0-9]+(([\.\,])+[0-9]+)?');

abstract class Parser {
  static ListItemState parse(ListItemState model) {
    int parseIndent(String fullText) {
      final leadingWhitespace = RegExp(r'^\s+');
      final match = leadingWhitespace.firstMatch(fullText);
      final count = match?.group(0)?.length ?? 0;

      return (count / 2).round().clamp(0, 12);
    }

    var updatedModel = model;
    // : -
    var source = model.fullText.trim();
    if (model.fullText.trim().startsWith(":")) {
      source = model.fullText.replaceAll(" ", "");
    }
    updatedModel = updatedModel.copyWith(indent: parseIndent(model.fullText));

    Operator operator = Operator.none;

    <String, Operator>{
      ':-': Operator.subtract,
      ':+': Operator.add,
      ':/': Operator.divide,
      ':*': Operator.multiply,
      ':=': Operator.equals,
    }.forEach((key, value) {
      if (source.startsWith(key)) {
        operator = value;
      }
    });

    if (operator != Operator.none) {
      source = ':${source.substring(2)}';
    }

    num? number;
    if (hasMatch(source)) {
      var match = getMatch(source);
      number = num.tryParse(match.substring(1));
      if (number != null) {
        updatedModel = updatedModel.copyWith(number: number);
        if (operator == Operator.none) {
          operator = Operator.add;
        }
        source = source.substring(getMatch(source).length).trim();
      }
    }

    updatedModel = updatedModel.copyWith(
      textPart: source,
      operator: operator,
      number: number,
    );

    return updatedModel;
  }

  static bool hasMatch(String source) => expression.hasMatch(source);

  static String getMatch(String source) {
    final match = expression.firstMatch(source);
    if (match != null) {
      return source.substring(match.start, match.end);
    } else {
      return '';
    }
  }
}
