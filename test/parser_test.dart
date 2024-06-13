import 'package:flutter_test/flutter_test.dart';
import 'package:onyx/editor/model.dart';
import 'package:onyx/editor/parser.dart';

void main() {
  group('Parser', () {
    test(
        'correctly identifies and assigns operator when source starts with operator',
        () {
      final model = ListItemState(
        index: 0,
        fullText: ':+ 5',
        textPart: '',
        checked: false,
        operator: Operator.none,
        number: 0,
        indent: 0,
      );

      final result = Parser.parse(model);

      expect(result.operator, Operator.add);
      expect(result.textPart, '');
      expect(result.number, 5);
    });

    test('source string is empty or only whitespace', () {
      final model = ListItemState(
        index: 0,
        fullText: '',
        textPart: '',
        checked: false,
        operator: Operator.none,
        number: 0,
        indent: 0,
      );

      final result = Parser.parse(model);

      expect(result.operator, Operator.none);
      expect(result.textPart, '');
      expect(result.number, 0);
    });

    test('test indent paser', () {
      final model = ListItemState(
        index: 0,
        fullText: '    hello',
        textPart: '',
        checked: false,
        operator: Operator.none,
        number: 0,
        indent: 0,
      );

      final result = Parser.parse(model);

      expect(result.operator, Operator.none);
      expect(result.textPart, 'hello');
      expect(result.number, 0);
      expect(result.indent, 2);
    });
  });
}
