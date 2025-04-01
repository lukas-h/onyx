import 'package:onyx/editor/codeblock.dart';
import 'package:onyx/editor/model.dart';

// For operators "+-*/" match the op (eg. ":+"), number (eg. "100,000"), and the text (eg. "cost")
// For the equals operator (":="), do not match any named group, but still match the text as a whole.
final mathematicalExpressionRegex =
    RegExp(r'^(:=)|(?<op>^:[+\-\/*]?)(?<num>[0-9]+([,.]?[0-9]+)?)(?<text>.*)');
  
final checkboxRegex = RegExp(r'^(?<op>:\[(x?)\])(.*)$');

final operators = {
  ':-': Operator.subtract,
  ':+': Operator.add,
  ':/': Operator.divide,
  ':*': Operator.multiply,
  ':=': Operator.equals,
  ':[]':Operator.uncheck,
  ':[x]':Operator.check
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
      String? opGroupMatch = match.namedGroup("op");

      if (opGroupMatch != null) {
        String? numGroupMatch = match.namedGroup("num");
        String? textGroupMatch = match.namedGroup("text");

        operator = operators[opGroupMatch] ?? Operator.add;
        number = num.tryParse(numGroupMatch ?? "");
        source = textGroupMatch?.trim() ?? "";
      } else {
        operator = Operator.equals;
        source = source.substring(2).trim();
      }
    }
    else if(hascheckbox(source)){
        RegExpMatch? checkboxmatch = checkboxRegex.firstMatch(source);
        if(checkboxmatch!=null){
          String? opGroupMatch = checkboxmatch.namedGroup("op");
          if (opGroupMatch != null) {
            operator = operators[opGroupMatch] ?? Operator.none;
          }
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
