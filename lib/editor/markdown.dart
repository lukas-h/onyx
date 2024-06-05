// ignore_for_file: implementation_imports

import 'package:markdown/markdown.dart';
import 'package:markdown/src/extension_set.dart';
import 'package:markdown/src/block_syntaxes/block_syntax.dart';
import 'package:markdown/src/block_syntaxes/alert_block_syntax.dart';
import 'package:markdown/src/block_syntaxes/block_syntax.dart';
import 'package:markdown/src/block_syntaxes/fenced_code_block_syntax.dart';
import 'package:markdown/src/block_syntaxes/footnote_def_syntax.dart';
import 'package:markdown/src/block_syntaxes/header_with_id_syntax.dart';
import 'package:markdown/src/block_syntaxes/ordered_list_with_checkbox_syntax.dart';
import 'package:markdown/src/block_syntaxes/setext_header_with_id_syntax.dart';
import 'package:markdown/src/block_syntaxes/table_syntax.dart';
import 'package:markdown/src/block_syntaxes/unordered_list_with_checkbox_syntax.dart';
import 'package:markdown/src/inline_syntaxes/autolink_extension_syntax.dart';
import 'package:markdown/src/inline_syntaxes/color_swatch_syntax.dart';
import 'package:markdown/src/inline_syntaxes/emoji_syntax.dart';
import 'package:markdown/src/inline_syntaxes/inline_html_syntax.dart';
import 'package:markdown/src/inline_syntaxes/inline_syntax.dart';
import 'package:markdown/src/inline_syntaxes/strikethrough_syntax.dart';
import 'package:markdown/src/ast.dart';
import 'package:markdown/src/charcode.dart';
import 'package:markdown/src/inline_parser.dart';
import 'package:markdown/src/util.dart';

final ExtensionSet onyxFlavored = ExtensionSet(
  List<BlockSyntax>.unmodifiable(
    <BlockSyntax>[
      const FencedCodeBlockSyntax(),
      const TableSyntax(),
      const UnorderedListWithCheckboxSyntax(),
      const OrderedListWithCheckboxSyntax(),
      const FootnoteDefSyntax(),
    ],
  ),
  List<InlineSyntax>.unmodifiable(
    <InlineSyntax>[
      InlineHtmlSyntax(),
      StrikethroughSyntax(),
      AutolinkExtensionSyntax(),
      InternalLinkSyntax(),
    ],
  ),
);

class InternalLinkSyntax extends InlineSyntax {
  static const _pattern = r'\[\[([^\[\]]+)\]\]';

  InternalLinkSyntax() : super(_pattern);

  @override
  bool tryMatch(InlineParser parser, [int? startMatchPos]) {
    final match = pattern.matchAsPrefix(parser.source, parser.pos);
    if (match == null) {
      return false;
    }
    parser.writeText();
    if (onMatch(parser, match)) parser.consume(match.match.length);
    return true;
  }

  @override
  bool onMatch(InlineParser parser, Match match) {
    final markerLength = match[0]!.length;
    final contentStart = parser.pos;
    final contentEnd = contentStart + markerLength;

    var internalLink = parser.source.substring(contentStart, contentEnd);

    internalLink = internalLink.substring(2, internalLink.length - 2);

    parser.addNode(Element.text('internalLink', internalLink));
    return true;
  }
}
