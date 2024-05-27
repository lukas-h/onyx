import 'package:flutter/material.dart';

openSearchMenu(BuildContext context) async => showDialog(
      context: context,
      builder: (context) => const SearchMenu(),
    );

class SearchMenu extends StatelessWidget {
  const SearchMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: Text('Hi'),
    );
  }
}
