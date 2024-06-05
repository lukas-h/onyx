import 'package:counter_note/widgets/button.dart';
import 'package:flutter/material.dart';

Future<(String, String)?> openExternalLinkInsertMenu(
    BuildContext context) async {
  return showDialog<(String, String)>(
    context: context,
    builder: (context) => const LinkMenu(),
  );
}

class LinkMenu extends StatefulWidget {
  const LinkMenu({super.key});

  @override
  State<LinkMenu> createState() => _LinkMenuState();
}

class _LinkMenuState extends State<LinkMenu> {
  final _textController = TextEditingController();
  final _hrefController = TextEditingController();
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
              controller: _textController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Title...',
              ),
              cursorColor: Colors.black,
            ),
            TextField(
              controller: _hrefController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'URL...',
              ),
              cursorColor: Colors.black,
            ),
          ],
        ),
      ),
      actions: [
        Button(
          'Insert link',
          icon: const Icon(Icons.done),
          active: false,
          onTap: () {
            final rec = (_textController.text, _hrefController.text);
            Navigator.pop(
              context,
              rec,
            );
          },
        ),
      ],
    );
  }
}
