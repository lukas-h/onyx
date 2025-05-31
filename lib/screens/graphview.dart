import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/GraphView.dart';
import 'package:onyx/cubit/graph_cubit.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/store/page_store.dart';

class GraphViewScreen extends StatelessWidget {
  const GraphViewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<GraphCubit>(
      create: (_) => GraphCubit(context.read<PageCubit>()),
      child: TreeViewPage(), // Make TreeViewPage const if possible
    );
  }
}

class TreeViewPage extends StatefulWidget {
  @override
  _TreeViewPageState createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
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
                        child: BlocBuilder<GraphCubit, GraphState>(
                          builder: (context, state) {
                            return GraphView(
                              graph: state.graph,
                              algorithm: SugiyamaAlgorithm(builder),
                              paint: Paint()
                                ..color = Colors.green
                                ..strokeWidth = 1
                                ..style = PaintingStyle.stroke,
                              builder: (Node node) {
                                Map<PageModel, bool> isJournal = state.dataNode.entries.firstWhere((entry) => entry.key == node).value;
                                PageModel page = isJournal.keys.first;
                                return state.recursionExist.contains(node)
                                    ? nodeWithRecursionWidget(page.title, page.uid, isJournal.values.first)
                                    : nodeWidget(page.title, page.uid, isJournal.values.first);
                              },
                            );
                          },
                        )
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

  Widget nodeWidget(String nodeTitle, String uid, bool isJournal) {
    // Condition to check if it's a journal or page
    IconData iconData;
    if (isJournal) {
      iconData = Icons.calendar_today_outlined; // Specific icon for journal
    } else {
      iconData = Icons.summarize_outlined; // Specific icon for page
    }

    return InkWell(
      onTap: () {
        final navCubit = context.read<NavigationCubit>();
        navCubit.openPageOrJournalUsingUid(uid);
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

  Widget nodeWithRecursionWidget(String nodeTitle, String uid, bool isJournal) {
    // Decide the icon (journal vs page)
    IconData iconData;
    if (isJournal) {
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

  SugiyamaConfiguration builder = SugiyamaConfiguration();

  @override
  void initState() {
    super.initState();

    builder
      ..nodeSeparation = 30
      ..levelSeparation = 50
      ..orientation = (SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM);
  }
}
