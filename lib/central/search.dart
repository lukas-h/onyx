import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/screens/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension on List {
  List only(int max) => max >= (length - 1) ? this : sublist(0, max);
}

typedef OnPageSelected = void Function(BuildContext context, PageState? state);

Future<void> openSearchMenu(
  BuildContext context, {
  required OnPageSelected onSelect,
}) async =>
    showDialog(
      context: context,
      builder: (context) => SearchMenu(
        onSelect: onSelect,
      ),
    );

Future<PageState?> openInsertMenu(BuildContext context) async =>
    showDialog<PageState>(
      context: context,
      builder: (context) => SearchMenu(
        onSelect: (context, state) {
          if (state != null) Navigator.pop(context, state);
        },
      ),
    );

class SearchMenu extends StatefulWidget {
  final OnPageSelected onSelect;
  const SearchMenu({super.key, required this.onSelect});

  @override
  State<SearchMenu> createState() => _SearchMenuState();
}

class _SearchMenuState extends State<SearchMenu> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NavigationCubit>();
    return IconTheme(
      data: const IconThemeData(size: 15),
      child: AlertDialog(
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 350,
            minWidth: 350, // TODO adaptive width
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
                ),
                cursorColor: Colors.black,
                onChanged: (v) {
                  setState(() {
                    query = v.trimLeft();
                  });
                },
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.summarize_outlined),
                title: Text(
                  'Pages',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                dense: true,
              ),
              if (query.isEmpty)
                ...cubit.pages.only(3).map(
                      (e) => PageCard(
                        small: true,
                        state: e,
                        onTap: () {
                          widget.onSelect(context, e);
                        },
                      ),
                    ),
              if (query.isNotEmpty)
                ...cubit.pages
                    .where(
                      (e) => e.title
                          .trim()
                          .toLowerCase()
                          .contains(query.trim().toLowerCase()),
                    )
                    .map(
                      (e) => PageCard(
                        small: true,
                        state: e,
                        onTap: () {
                          widget.onSelect(context, e);
                        },
                      ),
                    ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.calendar_today_outlined),
                title: Text(
                  'Journals',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                dense: true,
              ),
              if (query.isEmpty)
                ...cubit.journals.only(3).map(
                      (e) => PageCard(
                        icon: const Icon(Icons.calendar_today_outlined),
                        state: e,
                        small: true,
                        onTap: () {
                          widget.onSelect(context, e);
                        },
                      ),
                    ),
              if (query.isNotEmpty)
                ...cubit.journals
                    .where(
                      (e) => e.title
                          .trim()
                          .toLowerCase()
                          .contains(query.trim().toLowerCase()),
                    )
                    .map(
                      (e) => PageCard(
                        icon: const Icon(Icons.calendar_today_outlined),
                        state: e,
                        small: true,
                        onTap: () {
                          widget.onSelect(context, e);
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
