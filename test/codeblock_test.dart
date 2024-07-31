import 'package:flutter_test/flutter_test.dart';
import 'package:onyx/editor/codeblock.dart';

const codeblockWithLang = '''
```json
{
    "key": "value"
}
```
''';

const codeblockWithoutLang = '''
```
{
    "key": "value"
}
```
''';

const codeblockContent = '''{
    "key": "value"
}''';

const codeblockLang = 'json';

void main() {
  group('Codeblock regular expressions', () {
    test('test matching w/ lang code', () {
      expect(codeblockExp.hasMatch(codeblockWithLang), true);
      expect(codeblockExp.stringMatch(codeblockWithLang),
          codeblockWithLang.trim());
    });
    test('test matching w/o lang code', () {
      expect(codeblockExp.hasMatch(codeblockWithoutLang), true);
      expect(codeblockExp.stringMatch(codeblockWithoutLang),
          codeblockWithoutLang.trim());
    });

    test('test matching opening w/ lang code', () {
      expect(codeblockStartExp.hasMatch(codeblockWithLang), true);
      expect(codeblockStartExp.stringMatch(codeblockWithLang), '```json\n');
    });
    test('test matching opening w/o lang code', () {
      expect(codeblockStartExp.hasMatch(codeblockWithoutLang), true);
      expect(codeblockStartExp.stringMatch(codeblockWithoutLang), '```\n');
    });
    test('test matching closing w/ lang code', () {
      expect(codeblockEndExp.hasMatch(codeblockWithLang), true);
      expect(codeblockEndExp.stringMatch(codeblockWithLang), '\n```');
    });
    test('test matching closing w/o lang code', () {
      expect(codeblockEndExp.hasMatch(codeblockWithoutLang), true);
      expect(codeblockEndExp.stringMatch(codeblockWithoutLang), '\n```');
    });
    test('retrieve content w/ lang code', () {
      expect(getCodeblockContent(codeblockWithLang), codeblockContent);
    });
    test('retrieve content w/o lang code', () {
      expect(getCodeblockContent(codeblockWithoutLang), codeblockContent);
    });
    test('retrieve lang w/ lang code', () {
      expect(getCodeblockLanguage(codeblockWithLang), codeblockLang);
    });
    test('retrieve lang w/o lang code', () {
      expect(getCodeblockLanguage(codeblockWithoutLang), 'plaintext');
    });
    test('has match', () {
      expect(hasCodeblock(codeblockWithLang), true);
      expect(hasCodeblock(codeblockWithoutLang), true);
    });
    test('has no match', () {
      expect(hasCodeblock('random string'), false);
      expect(hasCodeblock('```random string'), false);
      expect(hasCodeblock('random string ```bla```'), false);
      expect(hasCodeblock('```'), false);
    });
  });
}
