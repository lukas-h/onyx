import 'package:flutter/material.dart';
import 'package:onyx/cubit/origin/origin_cubit.dart';
import 'package:onyx/widgets/button.dart';

Future<OriginConflictResolutionType?> openConflictMenu(BuildContext context,
        {required String conflictFileUid, required bool isJournal, required OriginConflictType conflictType}) async =>
    showDialog<OriginConflictResolutionType>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConflictMenu(conflictFileUid: conflictFileUid, isJournal: isJournal, conflictType: conflictType),
    );

class ConflictMenu extends StatefulWidget {
  final String conflictFileUid;
  final bool isJournal;
  final OriginConflictType conflictType;

  const ConflictMenu({super.key, required this.conflictFileUid, required this.isJournal, required this.conflictType});

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

    late final String title;
    late final String internalButtonText;
    late final String externalButtonText;

    switch (widget.conflictType) {
      case OriginConflictType.add:
        title = '${widget.isJournal ? 'Journal from' : 'Page with uid'} ${widget.conflictFileUid} has been created outside of Onyx. What do you want to do?';
        internalButtonText = 'Delete file';
        externalButtonText = 'Import file to Onyx';
      case OriginConflictType.modify:
        title =
            '${widget.isJournal ? 'Journal from' : 'Page with uid'} ${widget.conflictFileUid} has been modified outside of Onyx. Which version do you want to use?';
        internalButtonText = 'Use version from Onyx';
        externalButtonText = 'Use local version';
      case OriginConflictType.delete:
        title =
            '${widget.isJournal ? 'Journal from' : 'Page with uid'} ${widget.conflictFileUid} has been DELETED outside of Onyx. Are you sure you want to delete it?';
        internalButtonText = 'Delete file';
        externalButtonText = 'Keep file';
    }

    return IconTheme(
      data: const IconThemeData(size: 15),
      child: AlertDialog(
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 350,
            minWidth: 350,
            maxHeight: 200,
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Storage Conflict',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ListTile(
                title: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            internalButtonText,
            maxWidth: false,
            borderColor: Color.fromARGB(255, 255, 129, 129),
            icon: const Icon(Icons.edit),
            active: false,
            onTap: () {
              Navigator.pop(context, OriginConflictResolutionType.useInternal);
            },
          ),
          Button(
            externalButtonText,
            maxWidth: true,
            borderColor: Color.fromARGB(255, 139, 197, 139),
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
