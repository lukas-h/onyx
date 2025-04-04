import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/editor/delete.dart';
import 'package:onyx/editor/favorite.dart';
import 'package:onyx/editor/list.dart';
import 'package:onyx/extensions/extensions_registry.dart';
import 'package:onyx/extensions/page_extension.dart';
import 'package:onyx/widgets/button.dart';
import 'package:onyx/widgets/narrow_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:onyx/widgets/page_header.dart';

class PagesScreen extends StatelessWidget {
  const PagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        if (state is NavigationSuccess) {
          if (state.route == RouteState.pages) {
            return const _PagesList();
          } else {
            return const _PageDetail();
          }
        } else {
          return Container();
        }
      },
    );
  }
}

class _PagesList extends StatelessWidget {
  const _PagesList();

  @override
  Widget build(BuildContext context) {
    // TODO reactive
    final pages = context.read<NavigationCubit>().pages;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: PageHeader(
            title: Text(
              'Pages',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            buttons: [
              Button(
                'New Page',
                maxWidth: false,
                icon: const Icon(Icons.note_add_outlined),
                active: false,
                onTap: () {
                  context.read<NavigationCubit>().createPage();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: NarrowBody(
            child: ListView.builder(
              itemBuilder: (context, index) => PageCard(
                state: pages[index],
                onTap: () {
                  context
                      .read<NavigationCubit>()
                      .switchToPage(pages[index].uid);
                },
              ),
              itemCount: pages.length,
            ),
          ),
        ),
      ],
    );
  }
}

class PageCard extends StatelessWidget {
  final PageState state;
  final VoidCallback onTap;
  final Icon? icon;
  final bool small;
  const PageCard({
    super.key,
    required this.state,
    required this.onTap,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.5, color: Colors.grey[300]!),
          ),
        ),
        child: ListTile(
          title: Text(state.title),
          dense: small,
          subtitle:
              small ? null : Text(DateFormat.yMMMMd().format(state.created)),
          leading: icon ?? const Icon(Icons.summarize_outlined),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _PageDetail extends StatefulWidget {
  const _PageDetail();

  @override
  State<_PageDetail> createState() => _PageDetailState();
}

class _PageDetailState extends State<_PageDetail> {
  PageExtension? selectedExtension;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              BlocBuilder<PageCubit, PageState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: PageHeader(
                      buttons: [
                        FavoriteButton(uid: state.uid),
                        const SizedBox(width: 8),
                        DeleteButton(state: state),
                        for (final ext in context
                            .read<ExtensionsRegistry>()
                            .pagesExtensions) ...[
                          const SizedBox(width: 8),
                          ext.buildControlButton(
                              context, state, ext == selectedExtension, () {
                            setState(() {
                              if (ext == selectedExtension) {
                                selectedExtension = null;
                              } else {
                                selectedExtension = ext;
                              }
                            });
                          }),
                        ]
                      ],
                      title: _PageTitleEditor(
                        title: state.title,
                        index: state.index,
                      ),
                    ),
                  );
                },
              ),
              const Expanded(
                child: NarrowBody(child: ListEditor()),
              ),
            ],
          ),
        ),
        if (selectedExtension != null)
          const VerticalDivider(
            width: 1,
            color: Colors.black26,
            thickness: 1,
          ),
        if (selectedExtension != null)
          BlocBuilder<PageCubit, PageState>(
            builder: (context, state) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: selectedExtension != null ? 380 : 0,
                child: selectedExtension!.buildBody(context, state),
              );
            },
          ),
      ],
    );
  }
}

class _PageTitleEditor extends StatefulWidget {
  final String title;
  final int index;
  const _PageTitleEditor({required this.title, required this.index});

  @override
  State<_PageTitleEditor> createState() => _PageTitleEditorState();
}

class _PageTitleEditorState extends State<_PageTitleEditor> {
  late final TextEditingController _controller;
  final _node = FocusNode();

  @override
  void initState() {
    _controller = TextEditingController(text: widget.title);
    if (widget.index == -1) {
      _node.requestFocus();
    }
    _node.addListener(() {
      if (_node.hasFocus) {
        context.read<PageCubit>().index(-1);
      }
    });
    _node.onKeyEvent = (node, event) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        context.read<PageCubit>().index(0);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _node,
      controller: _controller,
      style: Theme.of(context).textTheme.headlineLarge,
      decoration: const InputDecoration(
        hintText: 'Page Title...',
        border: InputBorder.none,
      ),
      cursorColor: Colors.black,
      onChanged: (v) {
        context.read<PageCubit>().updateTitle(v);
      },
    );
  }
}
