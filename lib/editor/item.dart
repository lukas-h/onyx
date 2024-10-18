import 'dart:io';

import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/editor/codeblock.dart';
import 'package:onyx/editor/image_builder.dart';
import 'package:onyx/editor/markdown.dart';
import 'package:onyx/editor/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ListItemEditor extends StatefulWidget {
  final ListItemState model;
  final int index;
  final ValueChanged<ListItemState> onChanged;
  final ValueChanged<int> onChecked;
  final VoidCallback onDeleted;
  final VoidCallback onTap;
  final VoidCallback onNext;
  final bool inFocus;
  final PageCubit cubit;

  const ListItemEditor({
    super.key,
    required this.inFocus,
    required this.onChecked,
    required this.onChanged,
    required this.model,
    required this.onDeleted,
    required this.onTap,
    required this.onNext,
    required this.index,
    required this.cubit,
  });

  @override
  State<ListItemEditor> createState() => _ListItemEditorState();
}

class _ListItemEditorState extends State<ListItemEditor> {
  late final FocusNode _node;
  final _controller = TextEditingController();
  bool hasMatch = false;
  String match = '';

  void updatePos() {
    widget.onChanged(
      widget.model.copyWith(
        fullText: _controller.text,
        textPart: _controller.text,
        position: _controller.selection.baseOffset,
      ),
    );
  }

  @override
  void initState() {
    _node = FocusNode();
    _controller.text = widget.model.fullText;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: widget.model.position));
    _controller.addListener(updatePos);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(updatePos);
    super.dispose();
  }

  Widget _buildParsedPart(ListItemState model, int index) {
    final hasCode = hasCodeblock(model.textPart);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (model.operator != Operator.none)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 20,
              width: 22,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.transparent, width: 1.5),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: Icon(
                  switch (model.operator) {
                    Operator.add => Icons.add,
                    Operator.subtract => Icons.remove,
                    Operator.multiply => Icons.close,
                    Operator.divide => Icons.percent,
                    Operator.equals => Icons.drag_handle,
                    Operator.none => Icons.article,
                  },
                  size: 15,
                ),
              ),
            ),
          if (model.operator == Operator.none) const SizedBox(width: 30),
          if (model.operator != Operator.none &&
              model.operator != Operator.equals)
            SizedBox(
              width: 60,
              child: Text(
                model.number.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          if (model.operator == Operator.equals)
            SizedBox(
              width: 60,
              child: Text(
                widget.cubit
                    .calculateUntil(widget.cubit.state.items, index)
                    .toDouble()
                    .toStringAsFixed(2),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          if (hasCode)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: HighlightView(
                  getCodeblockContent(model.textPart),
                  language: getCodeblockLanguage(model.textPart),
                  theme: githubTheme,
                  padding: const EdgeInsets.all(12),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Source Code Pro',
                  ),
                ),
              ),
            ),
          if (!hasCode)
            Expanded(
              child: MarkdownBody(
                data: model.textPart,
                imageBuilder: (uri, title, alt) =>
                    ImageBuilder(uri: uri, title: title, alt: alt),
                onTapLink: (text, href, title) {
                  if (Uri.tryParse(href ?? '') != null) {
                    launchUrlString(href!);
                  }
                },
                onTapInternalLink: (text) {
                  context.read<NavigationCubit>().openPageOrJournal(text);
                },
                extensionSet: onyxFlavored,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    letterSpacing: 0,
                  ),
                  code: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Source Code Pro',
                    backgroundColor: Color(0xffddffdd),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 64),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.inFocus) {
        _node.requestFocus();
      }
    });
    return GestureDetector(
      onTap: () {
        _node.requestFocus();
        widget.onTap();
      },
      child: Container(
        //constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.inFocus
              ? Colors.black.withOpacity(0.03)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          //border: Border(
          //  bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
          //),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < (widget.model.indent + 1); i++)
              const SizedBox(
                width: 20,
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_right,
                    size: 10,
                    color: Colors.black38,
                  ),
                ),
              ),
            if (widget.inFocus)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 0),
                  constraints: const BoxConstraints(minHeight: 0),
                  padding: const EdgeInsets.only(bottom: 0, left: 29),
                  child: TextField(
                    textInputAction: Platform.isIOS || Platform.isAndroid
                        ? TextInputAction.done
                        : TextInputAction.none,
                    minLines: 1,
                    maxLines: 100,
                    cursorColor: Colors.black,
                    cursorHeight: 16,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      letterSpacing: 0,
                    ),
                    scrollPadding: EdgeInsets.zero,
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.top,
                    expands: false,
                    focusNode: _node,
                    controller: _controller,
                  ),
                ),
              ),
            if (!widget.inFocus)
              Expanded(
                child: _buildParsedPart(widget.model, widget.index),
              ),
            if (widget.inFocus) ...[
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: widget.onDeleted,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent, width: 1.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.black38,
                      size: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 18,
                height: 20,
                child: ReorderableDragStartListener(
                  index: widget.index,
                  child: const Icon(
                    Icons.drag_indicator_outlined,
                    color: Colors.black38,
                    size: 18,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  InkWell _checkbox() {
    return InkWell(
      onTap: () {
        widget.onChecked(widget.model.index);
      },
      child: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          color: widget.model.checked ? Colors.black38 : Colors.transparent,
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: Icon(
            Icons.check,
            color: widget.model.checked ? Colors.white : Colors.transparent,
            size: 15,
          ),
        ),
      ),
    );
  }
}
