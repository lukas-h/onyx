
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

class LatexElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'inline-latex') {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Math.tex(
          element.textContent,
          textStyle: preferredStyle,
          onErrorFallback: (error) {
            return Text(
              error as String,
              style: TextStyle(color: Colors.red),
            );
          },
        ),
      );
    } else if(element.tag == 'block-latex'){
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Math.tex(
          element.textContent,
          textStyle: preferredStyle,
          onErrorFallback: (error) {
            return Text(
              error as String,
              style: TextStyle(color: Colors.red),
            );
          },
        ),
      );
    }
    return null;
  }
}