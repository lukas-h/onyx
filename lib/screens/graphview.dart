
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/GraphView.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/editor/model.dart';
import 'package:onyx/store/page_store.dart';

class GraphViewScreen extends StatelessWidget  {
const GraphViewScreen({super.key});
 @override
  Widget build(BuildContext context) => 
        BlocBuilder<PageCubit, PageState>(
          builder: (context, state) {
            return TreeViewPage();
          }
        );

}
class TreeViewPage extends StatefulWidget  {
  @override
  _TreeViewPageState createState() => _TreeViewPageState();
  
}

class _TreeViewPageState extends State<TreeViewPage> {
  final List<Node> nodeList = [];
  Map<String,Node> titleNode = {};
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
                        String? key = titleNode.entries
                            .firstWhere((entry) => entry.value == node)
                            .key;
                        return rectangleWidget(key);
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


  Random r = Random();

 Widget rectangleWidget(String a) {
  // Condition to check if it's a journal or page
  IconData iconData;
  if (a.contains('/')) {
    iconData = Icons.calendar_today_outlined; // Specific icon for journal
  } else {
    iconData = Icons.summarize_outlined; // Specific icon for page
  }

  return InkWell(
    onTap: () {
      final navCubit = context.read<NavigationCubit>();
      navCubit.openPageOrJournal(a);
    },
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.blue, spreadRadius: 1),
        ],
        color: Colors.white, // Optional for better contrast
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData),
          SizedBox(width: 8), // Space between icon and text
          Text(a),
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
    for(int i=0;i<cubit.store.journals.length;i++){
    PageModel page = cubit.store.journals.values.elementAt(i);
    if(page.uid.isNotEmpty && page.title.isNotEmpty && page.uid.contains('/')){
     String numericString = page.uid.replaceAll('/', '');
     int numericDate = int.parse(numericString);
     final nodex = Node.Id(numericDate);
     nodeList.add(nodex);
     titleNode[page.title] = nodex;
     graph.addNode(nodex);
    }
    }
  // Journal add nodes code ends here
    
    // Page add node code starts here
    for(int i=0;i<cubit.store.pages.length;i++){
    PageModel page = cubit.store.pages.values.elementAt(i);
    if(page.uid.isNotEmpty && page.title.isNotEmpty){
      int randomId = UniqueKey().hashCode; 
      final nodex = Node.Id(randomId);
      nodeList.add(nodex);
      titleNode[page.title] = nodex;
      graph.addNode(nodex);
    }
    }
    //Page add node code ends here

    // Journal edges code starts here
    for(int i=0;i<cubit.store.journals.length;i++){
    PageModel page = cubit.store.journals.values.elementAt(i);
    if(page.uid.isNotEmpty && page.title.isNotEmpty && page.uid.contains('/')){
      final pagestate = PageState.fromPageModel(page, true);
      for(int x=0;x<pagestate.items.length;x++){
        ListItemState item = pagestate.items.elementAt(x);
        final matches = pattern.allMatches(item.fullText);
        if(matches.isNotEmpty){
          for (final match in matches) {
              final content = match.group(1); // Extracts the content between [[ and ]]
              if(titleNode.containsKey(content)){
              Node node1 = titleNode[page.title]!;
              Node node2 = titleNode[content]!;
              graph.addEdge(node1, node2,paint: Paint()..color = Colors.blue);
          }
        }
        }    
      }
    }
  }
  // Journal edges Code ends here

  // Pages edges code start here
    for(int i=0;i<cubit.store.pages.length;i++){
     PageModel page = cubit.store.pages.values.elementAt(i);
    if(page.uid.isNotEmpty && page.title.isNotEmpty){
      final pagestate = PageState.fromPageModel(page, false);
      for(int x=0;x<pagestate.items.length;x++){
        ListItemState item = pagestate.items.elementAt(x);
        final matches = pattern.allMatches(item.fullText);
        if(matches.isNotEmpty){
          for (final match in matches) {
              final content = match.group(1); // Extracts the content between [[ and ]]
              if(titleNode.containsKey(content)){
              Node node1 = titleNode[page.title]!;
              Node node2 = titleNode[content]!;
              graph.addEdge(node1, node2,paint: Paint()..color = Colors.blue);
          }
        }
        }    
      }
    }
  }
  // Pages edges code ends here

    //Page code ends here

    // final node1 = Node.Id(1);
    // final node2 = Node.Id(2);
    // final node3 = Node.Id(3);
    // final node4 = Node.Id(4);
    // final node5 = Node.Id(5);
    // final node6 = Node.Id(6);
    // final node8 = Node.Id(7);
    // final node7 = Node.Id(8);
    // final node9 = Node.Id(9);
    // final node10 = Node.Id(10);  
    // final node11 = Node.Id(11);
    // final node12 = Node.Id(12);

    // graph.addEdge(node1, node2);
    // graph.addEdge(node1, node3, paint: Paint()..color = Colors.red);
    // graph.addEdge(node1, node4, paint: Paint()..color = Colors.blue);
    // graph.addEdge(node2, node5);
    // graph.addEdge(node2, node6);
    // graph.addEdge(node6, node7, paint: Paint()..color = Colors.red);
    // graph.addEdge(node6, node8, paint: Paint()..color = Colors.red);
    // graph.addEdge(node4, node9);
    // graph.addEdge(node4, node10, paint: Paint()..color = Colors.black);
    // graph.addEdge(node4, node11, paint: Paint()..color = Colors.red);
    // graph.addEdge(node11, node12);

    builder
      ..nodeSeparation = 30
      ..levelSeparation = 50
      ..orientation = (SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM);
  }
}