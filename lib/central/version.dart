import 'package:flutter/material.dart';
import 'package:onyx/cubit/origin/origin_cubit.dart';
import 'package:onyx/service/origin_service.dart';
import 'package:onyx/widgets/button.dart';

typedef VersionMenuResult = ({OriginVersionActionType versionActionType, String? versionId, String? commitMessage});

Future<VersionMenuResult?> openVersionMenu(
  BuildContext context, {
  required List<ChangeRecord> changes,
  required List<VersionRecord> history,
}) async =>
    showDialog<VersionMenuResult>(
      context: context,
      builder: (context) => VersionMenu(
        changes: changes,
        history: history,
      ),
    );

class VersionMenu extends StatefulWidget {
  final List<ChangeRecord> changes;
  final List<VersionRecord> history;

  const VersionMenu({
    super.key,
    required this.changes,
    required this.history,
  });

  @override
  State<VersionMenu> createState() => _VersionMenuState();
}

class _VersionMenuState extends State<VersionMenu> with SingleTickerProviderStateMixin {
  final _node = FocusNode();

  late TextEditingController _commitMessageController;
  late TabController _tabController;

  bool isCommitButtonEnabled = false;
  String? selectedVersion;
  String? commitMessage;

  @override
  void initState() {
    super.initState();

    _commitMessageController = TextEditingController();
    _commitMessageController.addListener(handleTextChanged);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(handleTabChanged);
  }

  void handleTextChanged() {
    setState(() {
      commitMessage = _commitMessageController.text;
      isCommitButtonEnabled = _commitMessageController.text.isNotEmpty;
    });
  }

  void handleTabChanged() {
    setState(() {
      // Rerender to ensure actions match the selected tab.
    });
  }

  void commitChanges() {
    debugPrint("Commit Changes");
    Navigator.pop(
      context,
      (
        versionActionType: OriginVersionActionType.commitChanges,
        versionId: selectedVersion,
        commitMessage: commitMessage,
      ),
    );
  }

  void selectVersion() {
    debugPrint("Selected Version");
    Navigator.pop(
      context,
      (
        versionActionType: OriginVersionActionType.useVersion,
        versionId: selectedVersion,
        commitMessage: commitMessage,
      ),
    );
  }

  @override
  void dispose() {
    _commitMessageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _node.requestFocus();
    });

    return IconTheme(
        data: const IconThemeData(size: 15),
        child: AlertDialog(
          title: Text('Version Control'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Current Changes'),
                    Tab(text: 'Change History'),
                  ],
                ),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Changes Tab
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 150,
                            child: widget.changes.isEmpty
                                ? Center(child: const Text('No changes yet.'))
                                : ListView.builder(
                                    itemCount: widget.changes.length,
                                    itemBuilder: (context, index) {
                                      final change = widget.changes[index];
                                      return ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text(change.filePath),
                                        subtitle: Text(change.changeType),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                      // History Tab
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 150,
                            child: widget.history.isEmpty
                                ? Center(child: const Text('No history yet.'))
                                : ListView.builder(
                                    itemCount: widget.history.length,
                                    itemBuilder: (context, index) {
                                      final item = widget.history[index];
                                      final isSelected = selectedVersion == item.versionId;
                                      return ListTile(
                                        title: Text(item.versionId),
                                        subtitle: Text('${item.versionDate} - ${item.commitMessage}'),
                                        tileColor: isSelected ? Colors.blue.shade100 : null,
                                        onTap: () {
                                          setState(() {
                                            selectedVersion = item.versionId;
                                          });
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (_tabController.index == 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextField(
                  controller: _commitMessageController,
                  decoration: const InputDecoration(
                    labelText: 'Commit Message',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Button(
                'Commit Changes',
                maxWidth: true,
                icon: const Icon(Icons.folder),
                active: false,
                onTap: isCommitButtonEnabled ? commitChanges : null,
              ),
            ] else
              Button(
                'Use Selected Version',
                maxWidth: true,
                icon: const Icon(Icons.folder),
                active: false,
                onTap: selectedVersion != null ? selectVersion : null,
              ),
          ],
        ));
  }
}
