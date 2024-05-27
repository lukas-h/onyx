import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

openSearchMenu(BuildContext context) async => showDialog(
      context: context,
      builder: (context) => const SearchMenu(),
    );

class SearchMenu extends StatelessWidget {
  const SearchMenu({super.key});

  @override
  Widget build(BuildContext context) {
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
              const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
                ),
                cursorColor: Colors.black,
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
              const Divider(),
              const ListTile(
                leading: Icon(Icons.calendar_today_outlined),
                title: Text(
                  'Journals',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                dense: true,
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                ),
                title: Text(DateFormat.yMMMMd().format(DateTime.now())),
                dense: true,
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                ),
                title: Text(DateFormat.yMMMMd()
                    .format(DateTime.now().subtract(const Duration(days: 1)))),
                dense: true,
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                ),
                title: Text(DateFormat.yMMMMd()
                    .format(DateTime.now().subtract(const Duration(days: 2)))),
                dense: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
