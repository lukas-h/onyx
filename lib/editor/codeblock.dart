final codeblockExp = RegExp(r"```(?:\w+)?\s*\n([\s\S]*?)\n```");

final codeblockStartExp = RegExp(r"(```(?:\w+)?\s)");
final codeblockEndExp = RegExp(r"(\n```)");

final codeblockLangExp = RegExp(r"```(\w+)?\n");



bool hasCodeblock(String markdown) => codeblockExp.hasMatch(markdown);


String getCodeblockContent(String markdown) {
  final result = codeblockExp.stringMatch(markdown);
  if (result == null) return "";
  return result
      .replaceAll(codeblockStartExp, "")
      .replaceAll(codeblockEndExp, "")
      .trim();
}

String getCodeblockLanguage(String markdown) {
  final result = codeblockLangExp.stringMatch(markdown);
  if (result == null) return 'plaintext';
  return RegExp(r"(\w+)").stringMatch(result) ?? 'plaintext';
}

(String, String?, String?) getCodeblockBeforeAfter(String input, RegExp regex) {
  Match? match = regex.firstMatch(input);

  if (match == null) {
    return (input, null, null);
  }

  int start = match.start;
  int end = match.end;

  String before = input.substring(0, start);
  String code = input.substring(match.start, match.end);
  String after = input.substring(end);

  return (before, code, after);
}

List<String> parseMarkdownBody(String body) {
  final (before, code, after) = getCodeblockBeforeAfter(body, codeblockExp);
  final beforeList = before.trimRight().split('\n');
  final afterList = after?.trimLeft().split('\n');
  return [
    ...beforeList,
    if (code != null) code,
    ...?afterList,
  ];
}
