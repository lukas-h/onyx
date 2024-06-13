import 'package:onyx/central/link.dart';
import 'package:onyx/central/search.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/editor/item.dart';
import 'package:onyx/editor/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListEditor extends StatefulWidget {
  const ListEditor({super.key});

  @override
  State<ListEditor> createState() => ListEditorState();
}

class ListEditorState extends State<ListEditor> {
  bool _eventHandled = false;
  bool _previouslyEmpty = true;
  double scrollOffset = 0;
  final scrollController = ScrollController(keepScrollOffset: true);

  void _scrollListener() {
    if (scrollController.offset > 0) {
      scrollOffset = scrollController.offset;
    }
  }

  @override
  void initState() {
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PageCubit>();
    return SelectionArea(
      child: BlocConsumer<PageCubit, PageState>(
        bloc: cubit,
        listener: (context, state) {
          //scrollController.jumpTo(scrollOffset);
        },
        builder: (context, state) {
          return Focus(
            onKeyEvent: (node, event) {
              if (event.logicalKey != LogicalKeyboardKey.backspace) {
                return KeyEventResult.ignored;
              }
              final currentlyEmpty =
                  state.currentItem?.fullText.isEmpty == true;

              if (currentlyEmpty &&
                  state.index > 0 &&
                  !_eventHandled &&
                  _previouslyEmpty) {
                _previouslyEmpty = true;
                _eventHandled = true;
                context.read<PageCubit>().removeCurrent();
                Future.delayed(const Duration(milliseconds: 150), () {
                  _eventHandled = false;
                });
                _previouslyEmpty = currentlyEmpty;
                return KeyEventResult.handled;
              } else {
                _previouslyEmpty = currentlyEmpty;
              }

              return KeyEventResult.ignored;
            },
            child: Column(
              children: [
                Expanded(
                  child: ReorderableListView.builder(
                    scrollController: scrollController,
                    buildDefaultDragHandles: false,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.black.withOpacity(0.08),
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: child,
                        ),
                      );
                    },
                    itemBuilder: (context, index) {
                      final item = state.items[index];

                      return ListItemEditor(
                        cubit: cubit,
                        key: ValueKey(item.uid),
                        model: item,
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
                      );
                    },
                    itemCount: state.items.length,
                    onReorder: cubit.reorder,
                    footer: (state.sum > 0)
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 0.5, color: Colors.grey[300]!),
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
                          )
                        : Container(),
                  ),
                ),
                Material(
                  elevation: 0,
                  color: Colors.black.withOpacity(0.03),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  ),
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
                                state.index >= 0 &&
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
                      IconButton(
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        onPressed: state.items.isNotEmpty
                            ? () {
                                cubit.insertImage();
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.data_array_outlined),
                        onPressed: state.items.isNotEmpty
                            ? () async {
                                final page = await openInsertMenu(context);
                                if (page != null) {
                                  cubit.insertInternalLink(page.title);
                                }
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.link),
                        onPressed: state.items.isNotEmpty
                            ? () async {
                                final link =
                                    await openExternalLinkInsertMenu(context);
                                if (link != null) {
                                  cubit.insertExternalLink(link.$1, link.$2);
                                }
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.undo),
                        onPressed: cubit.canUndo
                            ? () {
                                cubit.undo();
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.redo),
                        onPressed: cubit.canRedo
                            ? () {
                                cubit.redo();
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
            ),
          );
        },
      ),
    );
  }
}
