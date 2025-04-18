import 'package:flutter_test/flutter_test.dart';
import 'package:onyx/store/page_store.dart';

void main() {
  group('Markdown Parser', () {
    test('fails to parse empty string', () {
      const markdownString = '';

      expect(() => PageModel.fromMarkdown(markdownString), throwsA(isA<Exception>()));
    });

    test('parses journal with no text content', () {
      const markdownString = '''
---
title: 18/04/2025
created: 2025-04-18T11:17:51.172975
modified: 2025-04-18T11:31:40.982830
uid: 18/04/2025
---

''';

      final model = PageModel.fromMarkdown(markdownString);

      expect(model.title, "18/04/2025");
      expect(model.created, DateTime.parse("2025-04-18T11:17:51.172975"));
      expect(model.modified, DateTime.parse("2025-04-18T11:31:40.982830"));
      expect(model.uid, "18/04/2025");
      expect(model.fullText, ['']);
    });

    test('parses page with no text content', () {
      const markdownString = '''
---
title: Hi I am a page with a title
created: 2025-04-16T13:13:46.780
modified: 2025-04-16T13:13:46.780
uid: fjfCHDFrLOrU0Eu
---

''';

      final model = PageModel.fromMarkdown(markdownString);

      expect(model.title, "Hi I am a page with a title");
      expect(model.created, DateTime.parse("2025-04-16T13:13:46.780"));
      expect(model.modified, DateTime.parse("2025-04-16T13:13:46.780"));
      expect(model.uid, "fjfCHDFrLOrU0Eu");
      expect(model.fullText, ['']);
    });

    test('parses page with text content including symbols', () {
      const markdownString = '''
---
title: Page with content
created: 2025-04-14T12:31:00.065
modified: 2025-04-14T20:12:08.871912
uid: Qpj17TkOKVffGz1
---

content line
more content
so\$ %% \\n\\n symbols; wow!
pretty neat''';

      final model = PageModel.fromMarkdown(markdownString);

      expect(model.title, "Page with content");
      expect(model.created, DateTime.parse("2025-04-14T12:31:00.065"));
      expect(model.modified, DateTime.parse("2025-04-14T20:12:08.871912"));
      expect(model.uid, "Qpj17TkOKVffGz1");
      expect(model.fullText, ['content line', 'more content', 'so\$ %% \\n\\n symbols; wow!', 'pretty neat']);
    });
  });
}
