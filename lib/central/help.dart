import 'package:onyx/widgets/button.dart';
import 'package:flutter/material.dart';

void openHelpMenu(BuildContext context) => showDialog(
      context: context,
      builder: (context) => const HelpMenu(),
    );

class HelpMenu extends StatelessWidget {
  const HelpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 350,
          minWidth: 350, // TODO adaptive width
          maxHeight: 650,
        ),
        child: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Navigation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                dense: true,
              ),
              ListTile(
                dense: true,
                title: Text('Search pages and journals'),
                leading: Text('⌘K'),
              ),
              ListTile(
                dense: true,
                title: Text('Manually synchronize'),
                leading: Text('⌘S'),
              ),
              ListTile(
                  dense: true,
                  title: Text('Open help menu'),
                  leading: Text('⌘H')),
              ListTile(
                dense: true,
                title: Text('Next journal'),
                leading: Text('⌘↑'),
              ),
              ListTile(
                  dense: true,
                  title: Text('Previous journal'),
                  leading: Text('⌘↓')),
              ListTile(
                title: Text(
                  'Editing',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                dense: true,
              ),
              ListTile(
                dense: true,
                title: Text('Undo change'),
                leading: Text('⌘Z'),
              ),
              ListTile(
                dense: true,
                title: Text('Redo change'),
                leading: Text('⌘⇧Z'),
              ),
              ListTile(
                dense: true,
                title: Text('Delete line'),
                leading: Text('⌘⌫'),
              ),
              ListTile(
                dense: true,
                title: Text('Add line feed'),
                leading: Text('⏎'),
              ),
              ListTile(
                dense: true,
                title: Text('Add new paragraph'),
                leading: Text('⌘⏎'),
              ),
              ListTile(
                dense: true,
                title: Text('Move paragraph up'),
                leading: Text('↑'),
              ),
              ListTile(
                dense: true,
                title: Text('Move paragraph down'),
                leading: Text('↓'),
              ),
              ListTile(
                dense: true,
                title: Text('Increase indent'),
                leading: Text('⇥'),
              ),
              ListTile(
                dense: true,
                title: Text('Decrease indent'),
                leading: Text('⇧⇥'),
              ),
              ListTile(
                dense: true,
                title: Text('Insert image ![alt](href)'),
                leading: Text('⌘I'),
              ),
              ListTile(
                dense: true,
                title: Text('Insert internal link/reference [[title]]'),
                leading: Text('⌘R'),
              ),
              ListTile(
                dense: true,
                title: Text('Insert external link [text](href)'),
                leading: Text('⌘L'),
              ),
              // arrows ↑ ↓ → ←
              // tab ⇥
            ],
          ),
        ),
      ),
      actions: [
        Button(
          'Close help menu',
          maxWidth: false,
          icon: const Icon(Icons.close),
          active: false,
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
