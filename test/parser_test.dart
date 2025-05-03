import 'package:flutter_test/flutter_test.dart';
import 'package:onyx/editor/model.dart';
import 'package:onyx/editor/parser.dart';

void main() {
  group('Calculation Parser', () {
    test('correctly identifies operator when source starts with operator', () {
      const text = ':+5';
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

    test('does not identify operator if space between operator and number', () {
      const text = ': 5';
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
      expect(result.textPart, ': 5');
      expect(result.number, 0);
    });

    test('correctly identifies operator with additional text', () {
      const text = ':/2 description text';
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

      expect(result.operator, Operator.divide);
      expect(result.textPart, 'description text');
      expect(result.number, 2);
    });

    test('correctly identifies equals operator', () {
      const text = ':=';
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

      expect(result.operator, Operator.equals);
      expect(result.textPart, '');
      expect(result.number, 0);
    });

    test('correctly identifies equals operator treating number as text', () {
      const text = ':= 17 description';
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

      expect(result.operator, Operator.equals);
      expect(result.textPart, '17 description');
      expect(result.number, 0);
    });

    test('does not identify equals if space between operator and number', () {
      const text = ': = description text';
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
      expect(result.textPart, ': = description text');
      expect(result.number, 0);
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
  });

  group('Indent Parser', () {
    test('test indent parser', () {
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
      expect(result.textPart, 'hello world');
      expect(result.number, 0);
      expect(result.indent, 2);
    });

    test('test indent parser with newLine', () {
      const text = '  \nhello world';
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
      expect(result.textPart, '\nhello world');
      expect(result.number, 0);
      expect(result.indent, 1);
    });

    test('test indent parser with single space', () {
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
      expect(result.textPart, ' hello world');
      expect(result.number, 0);
      expect(result.indent, 0);
    });

    test('test indent parser with operator', () {
      const text = '  :20 apples';
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
      expect(result.textPart, 'apples');
      expect(result.number, 20);
      expect(result.indent, 1);
    });
  });
}
