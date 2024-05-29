import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/editor/item.dart';
import 'package:counter_note/editor/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListEditor extends StatefulWidget {
  const ListEditor({super.key});

  @override
  State<ListEditor> createState() => ListEditorState();
}

class ListEditorState extends State<ListEditor> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PageCubit>();
    return BlocBuilder<PageCubit, PageState>(
      bloc: cubit,
      builder: (content, state) {
        return Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: true,
                itemBuilder: (context, index) => ListItemEditor(
                  cubit: cubit,
                  key: UniqueKey(),
                  model: state.items[index],
                  inFocus: state.index == index,
                  onTap: () {
                    cubit.index(index);
                  },
                  onChecked: (i) {
                    cubit.check(i);
                  },
                  onChanged: (value) {
                    cubit.update(index, value);
                  },
                  onDeleted: () {
                    cubit.remove(index);
                  },
                  onNext: () {
                    cubit.skipToNext();
                  },
                  index: index,
                ),
                itemCount: state.items.length,
                onReorder: cubit.reorder,
              ),
            ),
            if (state.sum > 0)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 0.5, color: Colors.grey[300]!),
                  ),
                ),
                child: ListTile(
                  leading: const Icon(Icons.functions),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      state.sum.toDouble().toStringAsFixed(2),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            Material(
              elevation: 0,
              color: Colors.black.withOpacity(0.08),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      cubit.add(
                        ListItemState.unparsed(
                          index: state.items.length,
                          fullText: '',
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    onPressed: state.items.isNotEmpty &&
                            state.items[state.index].indent > 0
                        ? () {
                            cubit.decreaseIndent();
                          }
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_right),
                    onPressed: state.items.isNotEmpty
                        ? () {
                            cubit.increaseIndent();
                          }
                        : null,
                  ),
                  Expanded(child: Container()),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: state.index > 0
                        ? () {
                            cubit.index(state.index - 1);
                          }
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: state.items.isNotEmpty &&
                            state.index < state.items.length - 1
                        ? () {
                            cubit.index(state.index + 1);
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
