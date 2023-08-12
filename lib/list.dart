import 'package:counter_note/cubit.dart';
import 'package:counter_note/item.dart';
import 'package:counter_note/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChecklistView extends StatefulWidget {
  const ChecklistView({super.key});

  @override
  State<ChecklistView> createState() => ChecklistViewState();
}

class ChecklistViewState extends State<ChecklistView> {
  final cubit = CounterCubit();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      bloc: cubit,
      builder: (content, state) {
        return Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                itemBuilder: (context, index) => ListItem(
                  cubit: cubit,
                  key: ValueKey(state.items[index].uid),
                  model: state.items[index],
                  inFocus: state.index == index,
                  onTap: () {
                    cubit.index(index);
                  },
                  onChecked: () {
                    cubit.remove(index);
                  },
                  onChanged: (value) {
                    cubit.update(index, value);
                  },
                  onDeleted: () {
                    cubit.remove(index);
                  },
                  onNext: () {
                    cubit.add(
                      ListItemModel(
                        textPart: '',
                        operator: Operator.none,
                        number: null,
                        index: state.items.length,
                        fullText: '',
                      ),
                    );
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
                )),
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
              elevation: 2,
              color: Colors.orange,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      cubit.add(
                        ListItemModel(
                          textPart: '',
                          operator: Operator.none,
                          number: null,
                          index: state.items.length,
                          fullText: '',
                        ),
                      );
                    },
                  ),
                  Expanded(child: Container()),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () {
                      cubit.index(state.index - 1);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () {
                      cubit.index(state.index + 1);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_indent_increase),
                    onPressed: () {},
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
