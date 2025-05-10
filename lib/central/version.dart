import 'package:flutter/material.dart';
import 'package:onyx/widgets/button.dart';

void openVersionMenu(BuildContext context) async => showDialog(
      context: context,
      builder: (context) => VersionMenu(),
    );

class VersionMenu extends StatefulWidget {
  const VersionMenu({super.key});

  @override
  State<VersionMenu> createState() => _VersionMenuState();
}

class _VersionMenuState extends State<VersionMenu> {
  final _node = FocusNode();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _node.requestFocus();
    });

    return IconTheme(
      data: const IconThemeData(size: 15),
      child: AlertDialog(
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
            minWidth: 350,
            maxHeight: 800,
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Version Control',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ListTile(
                title: Text(
                  'test',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            'button1',
            maxWidth: false,
            icon: const Icon(Icons.edit),
            active: false,
            onTap: () {},
          ),
          Button(
            'button2',
            maxWidth: true,
            icon: const Icon(Icons.folder),
            active: false,
            onTap: () {},
          ),
          Button(
            'Close',
            maxWidth: false,
            icon: const Icon(Icons.close),
            active: false,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
