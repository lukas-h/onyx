import 'package:flutter/material.dart';
import 'package:onyx/cubit/origin/origin_cubit.dart';
import 'package:onyx/service/origin_service.dart';
import 'package:onyx/widgets/button.dart';
import 'package:onyx/store/page_store.dart';
import 'package:get_time_ago/get_time_ago.dart';

typedef VersionMenuResult = ({OriginVersionActionType versionActionType, String? versionId, String? commitMessage});

Future<VersionMenuResult?> openVersionMenu(
  BuildContext context, {
  required PageStore pageStore,
}) async =>
    showDialog<VersionMenuResult>(
      context: context,
      builder: (context) => VersionMenu(
        pageStore: pageStore,
      ),
    );

class VersionMenu extends StatefulWidget {
  final PageStore pageStore;

  const VersionMenu({
    super.key,
    required this.pageStore,
  });

  @override
  State<VersionMenu> createState() => _VersionMenuState();
}

class _VersionMenuState extends State<VersionMenu> with SingleTickerProviderStateMixin {
  final _node = FocusNode();

  late TextEditingController _commitMessageController;
  late TabController _tabController;

  List<ChangeRecord> changes = [];
  List<VersionRecord> history = [];

  bool isCommitButtonEnabled = false;
  String? selectedVersion;
  String? commitMessage;

  @override
  void initState() {
    super.initState();

    getChangesAndHistoryAsync();

    _commitMessageController = TextEditingController();
    _commitMessageController.addListener(handleTextChanged);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(handleTabChanged);
  }

  void getChangesAndHistoryAsync() async {
    final changes = await widget.pageStore.originServices?.firstOrNull?.getCurrentDiff() ?? [];
    final history = await widget.pageStore.originServices?.firstOrNull?.getVersions() ?? [];

    setState(() {
      this.changes = changes;
      this.history = history;
    });
  }

  void handleTextChanged() {
    setState(() {
      commitMessage = _commitMessageController.text;
      isCommitButtonEnabled = _commitMessageController.text.isNotEmpty && changes.isNotEmpty;
    });
  }

  void handleTabChanged() {
    setState(() {
      // Re-render to ensure actions match the selected tab.
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
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 400,
              maxWidth: 400,
              minHeight: 300,
              maxHeight: 600,
            ),
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
                Flexible(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Changes Tab
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 200,
                                maxHeight: 400,
                              ),
                              child: changes.isEmpty
                                  ? Center(child: const Text('No changes yet.'))
                                  : ListView.builder(
                                      itemCount: changes.length,
                                      itemBuilder: (context, index) {
                                        final change = changes[index];
                                        return ListTile(
                                          // TODO: Add icons for different change types.
                                          leading: Icon(Icons.edit),
                                          title: Text(change.filePath),
                                          subtitle: Text(change.changeType),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                      // History Tab
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 200,
                                maxHeight: 400,
                              ),
                              child: history.isEmpty
                                  ? Center(child: const Text('No history yet.'))
                                  : ListView.builder(
                                      itemCount: history.length,
                                      itemBuilder: (context, index) {
                                        final item = history[index];
                                        final isSelected = selectedVersion == item.versionId;

                                        return ListTile(
                                          title: Text(item.commitMessage),
                                          subtitle: Text('${item.author}, ${GetTimeAgo.parse(item.versionDate)}'),
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
                    hintText: 'Commit message',
                    border: InputBorder.none,
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
