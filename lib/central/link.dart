import 'package:counter_note/widgets/button.dart';
import 'package:flutter/material.dart';

class LinkMenu extends StatefulWidget {
  const LinkMenu({super.key});

  @override
  State<LinkMenu> createState() => _LinkMenuState();
}

class _LinkMenuState extends State<LinkMenu> {
  final _altController = TextEditingController();
  final _linkController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 350,
          minWidth: 350, // TODO adaptive width
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _altController,
            ),
            TextField(
              controller: _linkController,
            ),
            const Divider(),
          ],
        ),
      ),
      actions: [
        Button(
          'Insert',
          icon: const Icon(Icons.done),
          active: false,
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
