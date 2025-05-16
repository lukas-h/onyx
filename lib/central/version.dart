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

class _VersionMenuState extends State<VersionMenu> with SingleTickerProviderStateMixin {
  final _node = FocusNode();
  String? selectedVersion;

  late TextEditingController _textEditingController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Rebuild on tab change so the action button can change.
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _node.requestFocus();
    });

    final List<Map<String, String>> changes = [
      {'file': 'lib/main.dart', 'status': 'Modified'},
      {'file': 'lib/utils.dart', 'status': 'Added'},
    ];

    final List<Map<String, String>> history = [
      {'version': 'v1.3.0', 'date': '2025-05-01', 'message': 'Bug fix in utils'},
      {'version': 'v1.2.0', 'date': '2025-04-15', 'message': 'New feature'},
    ];

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
                            child: ListView.builder(
                              itemCount: changes.length,
                              itemBuilder: (context, index) {
                                final change = changes[index];
                                return ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text(change['file']!),
                                  subtitle: Text(change['status']!),
                                );
                              },
                            ),
                          ),
                          TextField(
                            controller: _textEditingController,
                            onSubmitted: (String value) {},
                          )
                        ],
                      ),
                      // History Tab
                      ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          final isSelected = selectedVersion == item['version'];
                          return ListTile(
                            title: Text(item['version']!),
                            subtitle: Text('${item['date']} - ${item['message']}'),
                            tileColor: isSelected ? Colors.blue.shade100 : null,
                            onTap: () {
                              setState(() {
                                selectedVersion = item['version'];
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (_tabController.index == 0)
              Button(
                'Commit Changes',
                maxWidth: true,
                icon: const Icon(Icons.folder),
                active: false,
                onTap: () {},
              )
            else
              Button(
                'Use Selected Version',
                maxWidth: true,
                icon: const Icon(Icons.folder),
                active: false,
                onTap: () {},
              ),
          ],
        ));
  }
}
