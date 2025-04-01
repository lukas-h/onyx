import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

class LatexElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'latex') {
      try {
        return Math.tex(
          element.textContent,
          mathStyle: MathStyle.display,
          textStyle: preferredStyle,
          onErrorFallback: (error) {
            return Text(
              'LaTeX Error: $error',
              style: TextStyle(color: Colors.red),
            );
          },
        );
      } catch (e) {
        return Text(
          'LaTeX Error: $e',
          style: TextStyle(color: Colors.red),
        );
      }
    }
    return null;
  }
}
