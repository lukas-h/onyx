import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/GraphView.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/editor/model.dart';
import 'package:onyx/store/page_store.dart';

class GraphViewScreen extends StatelessWidget {
  const GraphViewScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<PageCubit, PageState>(builder: (context, state) {
        return TreeViewPage();
      });
}

class TreeViewPage extends StatefulWidget {
  @override
  _TreeViewPageState createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  Map<String, Node> titleNode = {};
  final List<Node> recusrionExist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(200),
            minScale: 0.01,
            maxScale: 5.0,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: GraphView(
                        graph: graph,
                        algorithm: SugiyamaAlgorithm(builder),
                        paint: Paint()
                          ..color = Colors.green
                          ..strokeWidth = 1
                          ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          String? key = titleNode.entries.firstWhere((entry) => entry.value == node).key;
                          return recusrionExist.contains(node) ? nodeWithRecursionWidget(key) : nodeWidget(key);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget nodeWidget(String nodeTitle) {
    // Condition to check if it's a journal or page
    IconData iconData;
    if (nodeTitle.contains('/')) {
      iconData = Icons.calendar_today_outlined; // Specific icon for journal
    } else {
      iconData = Icons.summarize_outlined; // Specific icon for page
    }

    return InkWell(
      onTap: () {
        final navCubit = context.read<NavigationCubit>();
        navCubit.openPageOrJournal(nodeTitle);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: Colors.blue, spreadRadius: 1),
          ],
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData),
            SizedBox(width: 8),
            Text(nodeTitle),
          ],
        ),
      ),
    );
  }

  Widget nodeWithRecursionWidget(String nodeTitle) {
    // Decide the icon (journal vs page)
    IconData iconData;
    if (nodeTitle.contains('/')) {
      iconData = Icons.calendar_today_outlined;
    } else {
      iconData = Icons.summarize_outlined;
    }

    return InkWell(
      onTap: () {
        final navCubit = context.read<NavigationCubit>();
        navCubit.openPageOrJournal(nodeTitle);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.blue.withValues(), spreadRadius: 1, blurRadius: 3),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.loop, size: 20, color: Colors.blue), // Loop Icon to show recursion exist for the current node
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, size: 20),
                const SizedBox(width: 6),
                Text(nodeTitle, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final Graph graph = Graph()..isTree = false;
  SugiyamaConfiguration builder = SugiyamaConfiguration();

  @override
  void initState() {
    super.initState();
    final pattern = RegExp(r'\[\[(.*?)\]\]');
    final cubit = context.read<PageCubit>();

    // Journal add nodes code starts here
    for (int i = 0; i < cubit.store.journals.length; i++) {
      PageModel page = cubit.store.journals.values.elementAt(i);
      if (page.uid.isNotEmpty && page.title.isNotEmpty && page.uid.contains('/')) {
        String numericString = page.uid.replaceAll('/', '');
        int numericDate = int.parse(numericString);
        final node = Node.Id(numericDate);
        titleNode[page.title] = node;
        graph.addNode(node);
      }
    }
    // Journal add nodes code ends here

    // Page add node code starts here
    for (int i = 0; i < cubit.store.pages.length; i++) {
      PageModel page = cubit.store.pages.values.elementAt(i);
      if (page.uid.isNotEmpty && page.title.isNotEmpty) {
        int randomId = UniqueKey().hashCode;
        final node = Node.Id(randomId);
        titleNode[page.title] = node;
        graph.addNode(node);
      }
    }
    //Page add node code ends here

    // Journal edges code starts here
    for (int i = 0; i < cubit.store.journals.length; i++) {
      PageModel page = cubit.store.journals.values.elementAt(i);
      if (page.uid.isNotEmpty && page.title.isNotEmpty && page.uid.contains('/')) {
        final pageState = PageState.fromPageModel(page, true);
        for (int x = 0; x < pageState.items.length; x++) {
          ListItemState item = pageState.items.elementAt(x);
          final matches = pattern.allMatches(item.fullText);
          if (matches.isNotEmpty) {
            for (final match in matches) {
              final content = match.group(1); // Extracts the content between [[ and ]]
              if (titleNode.containsKey(content)) {
                Node node1 = titleNode[page.title]!;
                Node node2 = titleNode[content]!;
                if (node1 == node2) {
                  recusrionExist.add(node1);
                } else {
                  graph.addEdge(node1, node2, paint: Paint()..color = Colors.blue);
                }
              }
            }
          }
        }
      }
    }
    // Journal edges Code ends here

    // Pages edges code start here
    for (int i = 0; i < cubit.store.pages.length; i++) {
      PageModel page = cubit.store.pages.values.elementAt(i);
      if (page.uid.isNotEmpty && page.title.isNotEmpty) {
        final pageState = PageState.fromPageModel(page, false);
        for (int x = 0; x < pageState.items.length; x++) {
          ListItemState item = pageState.items.elementAt(x);
          final matches = pattern.allMatches(item.fullText);
          if (matches.isNotEmpty) {
            for (final match in matches) {
              final content = match.group(1); // Extracts the content between [[ and ]]
              if (titleNode.containsKey(content)) {
                Node node1 = titleNode[page.title]!;
                Node node2 = titleNode[content]!;
                if (node1 == node2) {
                  recusrionExist.add(node1);
                } else {
                  graph.addEdge(node1, node2, paint: Paint()..color = Colors.blue);
                }
              }
            }
          }
        }
      }
    }
    // Pages edges code ends here

    builder
      ..nodeSeparation = 30
      ..levelSeparation = 50
      ..orientation = (SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM);
  }
}
