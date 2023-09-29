import 'package:counter_note/cubit.dart';
import 'package:counter_note/model.dart';
import 'package:flutter/material.dart';

class ListItem extends StatefulWidget {
  final ListItemModel model;
  final int index;
  final ValueChanged<ListItemModel> onChanged;
  final VoidCallback onChecked;
  final VoidCallback onDeleted;
  final VoidCallback onTap;
  final VoidCallback onNext;
  final bool inFocus;
  final CounterCubit cubit;

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
  bool checked = false;
  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  bool hasMatch = false;
  String match = '';
  @override
  void initState() {
    if (widget.inFocus) {
      print('HI');
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
            width: 20,
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
        if (model.operator == Operator.none) const SizedBox(width: 25),
        if (model.operator != Operator.none &&
            model.operator != Operator.equals)
          SizedBox(
            width: 100,
            child: Text(
              model.number.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        if (model.operator == Operator.equals)
          SizedBox(
            width: 100,
            child: Text(
              widget.cubit
                  .calculateUntil(widget.cubit.state.items, index)
                  .toDouble()
                  .toStringAsFixed(2),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
            child: Text(
          model.textPart,
          style: const TextStyle(fontSize: 16),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.inFocus ? Colors.black12 : Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  checked = !checked;
                });
                widget.onChecked();
              },
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: checked ? Colors.black : Colors.transparent,
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: checked ? Colors.white : Colors.transparent,
                    size: 15,
                  ),
                ),
              ),
            ),
            if (widget.inFocus)
              const SizedBox(
                width: 20,
              ),
            if (widget.inFocus)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: TextField(
                      maxLines: 1,
                      minLines: 1,
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        widget.onNext();
                      },
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
                  color: checked ? Colors.black : Colors.transparent,
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
              width: 30,
            ),
          ],
        ),
      ),
    );
  }
}
