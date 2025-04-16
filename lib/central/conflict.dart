import 'package:flutter/material.dart';
import 'package:onyx/widgets/button.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';

typedef OnResolved = void Function(bool keepInternal);

Future<void> openConflictMenu(
  BuildContext context, {
  required String fileName,
  required String internalContent,
  required String externalContent,
  required OnResolved onResolved,
}) async =>
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConflictMenu(
        fileName: fileName,
        internalContent: internalContent,
        externalContent: externalContent,
        onResolved: onResolved,
      ),
    );

class ConflictMenu extends StatefulWidget {
  final String fileName;
  final String internalContent;
  final String externalContent;
  final OnResolved onResolved;

  const ConflictMenu(
      {super.key,
      required this.fileName,
      required this.internalContent,
      required this.externalContent,
      required this.onResolved});

  @override
  State<ConflictMenu> createState() => _ConflictMenuState();
}

class _ConflictMenuState extends State<ConflictMenu> {
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
            maxWidth: 350,
            minWidth: 350,
            maxHeight: 650,
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Local Storage Conflict',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ListTile(
                title: Text(
                  '${widget.fileName} has been modified outside of Onyx. Which version do you want to use?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: PrettyDiffText(
                  oldText: widget.externalContent,
                  newText: widget.internalContent,
                ),
              )
            ],
          ),
        ),
        actions: [
          Button(
            'Use version from Onyx',
            maxWidth: false,
            borderColor: Color.fromARGB(255, 139, 197,
                139), // Colors from PrettyDiffText to match the above diff.
            icon: const Icon(Icons.edit),
            active: false,
            onTap: () {
              debugPrint("chose to use onyx edited version");
              widget.onResolved(true);
              Navigator.pop(context);
            },
          ),
          Button(
            'Use local version',
            maxWidth: true,
            borderColor: Color.fromARGB(255, 255, 129,
                129), // Colors from PrettyDiffText to match the above diff.
            icon: const Icon(Icons.folder),
            active: false,
            onTap: () {
              debugPrint("chose to use local file");
              widget.onResolved(false);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
