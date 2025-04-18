import 'package:flutter/material.dart';
import 'package:onyx/cubit/origin/origin_cubit.dart';
import 'package:onyx/widgets/button.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';

Future<OriginConflictResolutionType?> openConflictMenu(BuildContext context,
        {required String conflictFileUid, required bool isJournal, required String internalContent, required String externalContent}) async =>
    showDialog<OriginConflictResolutionType>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          ConflictMenu(conflictFileUid: conflictFileUid, isJournal: isJournal, internalContent: internalContent, externalContent: externalContent),
    );

class ConflictMenu extends StatefulWidget {
  final String conflictFileUid;
  final bool isJournal;
  final String internalContent;
  final String externalContent;

  const ConflictMenu({super.key, required this.conflictFileUid, required this.isJournal, required this.internalContent, required this.externalContent});

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
                  '${widget.isJournal ? 'Journal' : 'Page'} with uid "${widget.conflictFileUid}" has been modified outside of Onyx. Which version do you want to use?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: PrettyDiffText(
                  oldText: widget.internalContent,
                  newText: widget.externalContent,
                ),
              )
            ],
          ),
        ),
        actions: [
          Button(
            'Use version from Onyx',
            maxWidth: false,
            borderColor: Color.fromARGB(255, 255, 129, 129), // Colors from PrettyDiffText to match the above diff.
            icon: const Icon(Icons.edit),
            active: false,
            onTap: () {
              Navigator.pop(context, OriginConflictResolutionType.useInternal);
            },
          ),
          Button(
            'Use local version',
            maxWidth: true,
            borderColor: Color.fromARGB(255, 139, 197, 139), // Colors from PrettyDiffText to match the above diff.
            icon: const Icon(Icons.folder),
            active: false,
            onTap: () {
              Navigator.pop(context, OriginConflictResolutionType.useExternal);
            },
          ),
        ],
      ),
    );
  }
}
