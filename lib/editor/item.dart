import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/editor/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ListItem extends StatefulWidget {
  final ListItemModel model;
  final int index;
  final ValueChanged<ListItemModel> onChanged;
  final ValueChanged<int> onChecked;
  final VoidCallback onDeleted;
  final VoidCallback onTap;
  final VoidCallback onNext;
  final bool inFocus;
  final PageCubit cubit;

  const ListItem({
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
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  bool hasMatch = false;
  String match = '';
  @override
  void initState() {
    if (widget.inFocus) {
      _focusNode.requestFocus();
    }
    _controller.text = widget.model.fullText;
    super.initState();
  }

  Widget _buildParsedPart(ListItemModel model, int index) {
    return Row(
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
        Expanded(
            child: MarkdownBody(
          data: model.textPart,
          styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 16)),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 44,
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.inFocus
              ? Colors.black.withOpacity(0.08)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0, left: 29),
                  child: TextField(
                      minLines: 1,
                      maxLines: 1,
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16, height: 1),
                      scrollPadding: EdgeInsets.zero,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        widget.onNext();
                      },
                      expands: false,
                      focusNode: _focusNode,
                      controller: _controller,
                      onChanged: (v) {
                        widget.onChanged(
                          widget.model.copyWith(
                            fullText: _controller.text,
                            textPart: _controller.text,
                          ),
                        );
                      }),
                ),
              ),
            if (!widget.inFocus)
              Expanded(
                child: _buildParsedPart(widget.model, widget.index),
              ),
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
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
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
