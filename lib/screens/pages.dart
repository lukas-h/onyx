import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/editor/list.dart';
import 'package:counter_note/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            return const _PageDetail(); // TODO implement route detail
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
          child: ListTile(
            title: Text(
              'Pages',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Button(
                  'New Page',
                  icon: const Icon(Icons.note_add_outlined),
                  active: false,
                  onTap: () {
                    context.read<NavigationCubit>().createPage();
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) => _PageCard(state: pages[index]),
            itemCount: pages.length,
          ),
        ),
      ],
    );
  }
}

class _PageCard extends StatelessWidget {
  final PageState state;
  const _PageCard({required this.state});

  @override
  Widget build(BuildContext context) {
    // TODO improve widget
    return ListTile(
      title: Text(state.title),
      onTap: () {
        context.read<NavigationCubit>().switchToPage(state.uid);
      },
    );
  }
}

class _PageDetail extends StatefulWidget {
  const _PageDetail();

  @override
  State<_PageDetail> createState() => _PageDetailState();
}

class _PageDetailState extends State<_PageDetail> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController(text: '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      BlocBuilder<PageCubit, PageState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ListTile(
              title: TextField(
                controller: _controller,
                style: Theme.of(context).textTheme.headlineLarge,
                decoration: const InputDecoration(
                  hintText: 'Page Title...',
                  border: InputBorder.none,
                ),
                cursorColor: Colors.black,
                onChanged: (v) {
                  print(v);
                  context.read<PageCubit>().updateTitle(state.title);
                },
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button(
                    'Action',
                    icon: const Icon(Icons.question_mark_outlined),
                    onTap: () {},
                    active: false,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      const Expanded(child: ChecklistView()),
    ]);
  }
}
