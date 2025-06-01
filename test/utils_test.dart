import 'package:flutter_test/flutter_test.dart';
import 'package:onyx/editor/model.dart';
import 'package:onyx/utils/utils.dart';

void main() {
  group('Calculation tests', () {
    test('calculate total', () {
      final item1 = ListItemState(textPart: ":3", operator: Operator.add, number: 3, index: 0, position: 0, fullText: ':3');
      final item2 = ListItemState(textPart: ":*5", operator: Operator.multiply, number: 5, index: 1, position: 0, fullText: ':*5');
      final item3 = ListItemState(textPart: ":-2", operator: Operator.subtract, number: 2, index: 2, position: 0, fullText: ':-2');

      final sum = calculateTotal([item1, item2, item3], 3);
      expect(sum, 13);
    });

    test('calculate total with indentation', () {
      final item1 = ListItemState(indent: 0, textPart: ":3", operator: Operator.add, number: 3, index: 0, position: 0, fullText: ':3');
      final item2 = ListItemState(indent: 1, textPart: ":*5", operator: Operator.multiply, number: 5, index: 1, position: 0, fullText: ':*5');
      final item3 = ListItemState(indent: 1, textPart: ":-2", operator: Operator.subtract, number: 2, index: 2, position: 0, fullText: ':-2');

      final sum = calculateTotal([item1, item2, item3], 3);
      expect(sum, 9);
    });

    test('calculate total with nested indentation', () {
      final item1 = ListItemState(indent: 0, textPart: ":3", operator: Operator.add, number: 3, index: 0, position: 0, fullText: ':3');
      final item2 = ListItemState(indent: 2, textPart: ":*5", operator: Operator.multiply, number: 5, index: 1, position: 0, fullText: ':*5');
      final item3 = ListItemState(indent: 2, textPart: ":-2", operator: Operator.subtract, number: 2, index: 2, position: 0, fullText: ':-2');
      final item4 = ListItemState(indent: 1, textPart: ":+4", operator: Operator.add, number: 4, index: 3, position: 0, fullText: ':+4');

      final sum = calculateTotal([item1, item2, item3, item4], 4);
      expect(sum, 21);
    });

    test('calculate total with three adjacent indented items', () {
      final item1 = ListItemState(indent: 0, textPart: ":3", operator: Operator.add, number: 3, index: 0, position: 0, fullText: ':3');
      final item2 = ListItemState(indent: 1, textPart: ":*5", operator: Operator.multiply, number: 5, index: 1, position: 0, fullText: ':*5');
      final item3 = ListItemState(indent: 1, textPart: ":-2", operator: Operator.subtract, number: 2, index: 2, position: 0, fullText: ':-2');
      final item4 = ListItemState(indent: 1, textPart: ":+4", operator: Operator.add, number: 4, index: 3, position: 0, fullText: ':+4');

      final sum = calculateTotal([item1, item2, item3, item4], 4);
      expect(sum, 21);
    });
  });
}
