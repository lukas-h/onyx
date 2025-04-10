import 'package:flutter_test/flutter_test.dart';
import 'package:onyx/store/page_store.dart';

void main() {
  group('Markdown Parser', () {
    test('fails to parse empty string', () {
      const markdownString = '';

      expect(() => PageModel.fromMarkdown(markdownString),
          throwsA(isA<Exception>()));
    });

    test('parses journal with no text content', () {
      const markdownString = '''
---
title: April 5, 2025
created: 2025-04-05T18:23:49.819680
uid: 2JBDe1yCs2dBx6E
---

''';

      final model = PageModel.fromMarkdown(markdownString);

      expect(model.title, "April 5, 2025");
      expect(model.created, DateTime.parse("2025-04-05T18:23:49.819680"));
      expect(model.uid, "2JBDe1yCs2dBx6E");
      expect(model.fullText, []);
    });
  });
}
