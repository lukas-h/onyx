import 'package:flutter_test/flutter_test.dart';
import 'package:onyx/store/page_store.dart';

void main() {
  group('From Markdown', () {
    test('', () {
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

  group('To Markdown', () {
    test('creates markdown for journal with no content', () {
      final timeNow = DateTime.now();

      final model = PageModel(title: "18/04/2025", created: DateTime.parse("2025-04-18T11:17:51.172975"), modified: timeNow, uid: "18/04/2025", fullText: ['']);

      final markdown = model.toMarkdown();

      expect(markdown, '''
---
title: 18/04/2025
created: 2025-04-18T11:17:51.172975
modified: ${timeNow.toIso8601String()}
uid: 18/04/2025
---


''');
    });

    test('creates markdown for page with complex content', () {
      final timeNow = DateTime.now();

      final model = PageModel(
          title: "Page with complex content",
          created: DateTime.parse("2025-04-18T12:30:14.671637"),
          modified: timeNow,
          uid: "XYQvV-NwgD-6UJ_",
          fullText: [
            '# This is the main title',
            '## And a kind of subheading thing',
            ':+100 We start with a positive value',
            ':-90 Then we minus',
            ':*2',
            ':/5 And times and divide',
            ':= 9 <-- this number is unrelated to the equals!',
            '* Now a list',
            '* Another item',
            '* And a third',
            '-[ ] Unchecked item',
            '-[x] Checked item',
            '[[15/04/2025]] And a link to something else!',
          ]);

      final markdown = model.toMarkdown();

      expect(markdown, '''
---
title: Page with complex content
created: 2025-04-18T12:30:14.671637
modified: ${timeNow.toIso8601String()}
uid: XYQvV-NwgD-6UJ_
---

# This is the main title
## And a kind of subheading thing
:+100 We start with a positive value
:-90 Then we minus
:*2
:/5 And times and divide
:= 9 <-- this number is unrelated to the equals!
* Now a list
* Another item
* And a third
-[ ] Unchecked item
-[x] Checked item
[[15/04/2025]] And a link to something else!
''');
    });
  });
}
