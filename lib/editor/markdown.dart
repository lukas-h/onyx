// ignore_for_file: implementation_imports

import 'package:markdown/markdown.dart';
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
