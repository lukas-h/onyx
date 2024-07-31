import 'package:flutter/material.dart';

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

class CodeblockRenderer extends StatelessWidget {
  const CodeblockRenderer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
