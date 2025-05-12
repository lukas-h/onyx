import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/GraphView.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/editor/model.dart';
import 'package:onyx/store/page_store.dart';

class GraphState {
  final Graph graph;
  final List<Node> recursionExist;
  final Map<String, Node> titleNode;
  final Map<Node,PageModel> dataNode;

  GraphState({required this.graph, required this.recursionExist, required this.titleNode, required this.dataNode}); 
}

class GraphCubit extends Cubit<GraphState>{
  final PageCubit cubit;
  final Graph graph = Graph()..isTree = false;
  Map<String, Node> titleNode = {};
  Map<Node,PageModel> dataNode = {};
  final List<Node> recursionExist = [];
  
  Node? getNodeByTitle(String title) => state.titleNode[title];

  PageModel? getPageModelForNode(Node node) => state.dataNode[node];

  PageModel? getPageModelByTitle(String title) {
    final node = getNodeByTitle(title);
    if (node != null) {
      return getPageModelForNode(node);
    }
    return null;
  }

  GraphCubit(this.cubit):super(GraphState(graph:Graph(), recursionExist: [], titleNode: {}, dataNode: {})){
    init();
  }
  init(){
    final pattern = RegExp(r'\[\[(.*?)\]\]');
    // Journal add nodes code starts here
    for (int i = 0; i < cubit.store.journals.length; i++) {
      PageModel page = cubit.store.journals.values.elementAt(i);
      if (page.uid.isNotEmpty && page.title.isNotEmpty && page.uid.contains('/')) {
        String numericString = page.uid.replaceAll('/', '');
        int numericDate = int.parse(numericString);
        final node = Node.Id(numericDate);
        titleNode[page.title] = node;
        graph.addNode(node);
        dataNode[node] = page;
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
        dataNode[node] = page;
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
                  recursionExist.add(node1);
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
                  recursionExist.add(node1);
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

    emit(GraphState(graph: graph, recursionExist: recursionExist, titleNode: titleNode, dataNode:dataNode));

  }

}