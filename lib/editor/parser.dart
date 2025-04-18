import 'package:onyx/editor/model.dart';

final expression = RegExp(r'^\:[0-9]+(([\.\,])+[0-9]+)?');

abstract class Parser {
  static ListItemState parse(ListItemState model) {
    var updatedModel = model;
    var source = model.fullText.trim();

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
