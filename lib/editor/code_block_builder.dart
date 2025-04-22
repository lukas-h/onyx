import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'item.dart';

class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Extract language from info string (e.g., ```dart)
    final info = element.attributes['class'] ?? '';
    final lang = info.replaceFirst('language-', '').trim();
    final text = element.textContent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: HighlightView(
        text,
        language: lang.isEmpty ? 'plaintext' : lang,
        theme: githubTheme,
        padding: const EdgeInsets.all(8),
        textStyle: const TextStyle(
          fontSize: ListItemEditor.fontSize,
          fontFamily: 'Source Code Pro',
        ),
      ),
    );
  }
}
