import 'package:flutter_test/flutter_test.dart';
import 'package:onyx/editor/model.dart';
import 'package:onyx/editor/parser.dart';

void main() {
  group('Parser', () {
    test(
        'correctly identifies and assigns operator when source starts with operator',
        () {
      const text = ':+ 5';
      final model = ListItemState(
        index: 0,
        fullText: text,
        textPart: '',
        checked: false,
        operator: Operator.none,
        number: 0,
        indent: 0,
        position: text.length,
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
        position: 0,
        indent: 0,
      );

      final result = Parser.parse(model);

      expect(result.operator, Operator.none);
      expect(result.textPart, '');
      expect(result.number, 0);
    });

    test('test indent paser', () {
      const text = '    hello world';
      final model = ListItemState(
        index: 0,
        fullText: text,
        textPart: '',
        checked: false,
        operator: Operator.none,
        number: 0,
        indent: 0,
        position: text.length,
      );

      final result = Parser.parse(model);

      expect(result.operator, Operator.none);
      expect(result.fullText, 'hello world');
      expect(result.textPart, 'hello world');
      expect(result.number, 0);
      expect(result.indent, 2);
    });

    test('test single space indent paser', () {
      const text = ' hello world';
      final model = ListItemState(
        index: 0,
        fullText: text,
        textPart: '',
        checked: false,
        operator: Operator.none,
        number: 0,
        indent: 0,
        position: text.length,
      );

      final result = Parser.parse(model);

      expect(result.operator, Operator.none);
      expect(result.fullText, ' hello world');
      expect(result.textPart, ' hello world');
      expect(result.number, 0);
      expect(result.indent, 0);
    });

    test('test newline indent paser', () {
      const text = '\n  hello world';
      final model = ListItemState(
        index: 0,
        fullText: text,
        textPart: '',
        checked: false,
        operator: Operator.none,
        number: 0,
        indent: 0,
        position: text.length,
      );

      final result = Parser.parse(model);

      expect(result.operator, Operator.none);
      expect(result.fullText, '\n  hello world');
      expect(result.textPart, '\n  hello world');
      expect(result.number, 0);
      expect(result.indent, 0);
    });
  });
}
