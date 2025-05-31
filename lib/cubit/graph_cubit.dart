import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/GraphView.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/store/page_store.dart';

class PageWrapper {
  final PageModel page;
  final bool isJournal;

  PageWrapper({required this.page, required this.isJournal});
}

class GraphState {
  final Graph graph;
  final List<Node> recursionExist;
  final Map<String, Node> titleNode;
  final Map<Node, Map<PageModel, bool>> dataNode;

  GraphState({required this.graph, required this.recursionExist, required this.titleNode, required this.dataNode});
}

class GraphCubit extends Cubit<GraphState> {
  final PageCubit cubit;
  final Graph graph = Graph()..isTree = false;
  Map<String, Node> titleNode = {};
  Map<Node, Map<PageModel, bool>> dataNode = {};
  final List<Node> recursionExist = [];

  Node? getNodeByUid(String uid) => state.titleNode[uid];

  Map<PageModel, bool>? getPageModelForNode(Node node) => state.dataNode[node];

  Map<PageModel, bool>? getPageModelById(String uid) {
    final node = getNodeByUid(uid);
    if (node != null) {
      return getPageModelForNode(node);
    }
    return null;
  }

  GraphCubit(this.cubit) : super(GraphState(graph: Graph(), recursionExist: [], titleNode: {}, dataNode: {})) {
    init();
  }

  void createGraphNodes(List<PageWrapper> allPages) {
    for (final entry in allPages) {
      final PageModel page = entry.page;
      final bool isJournal = entry.isJournal;

      if (page.uid.isNotEmpty && page.title.isNotEmpty) {
        late final Node node;
        if (isJournal && page.uid.contains('/')) {
          final numericDate = int.parse(page.uid.replaceAll('/', ''));
          node = Node.Id(numericDate);
          titleNode[page.uid] = node;
          graph.addNode(node);
          dataNode[node] = {page: isJournal};
        } else if (!isJournal) {
          node = Node.Id(page.uid.hashCode);
          titleNode[page.uid] = node;
          graph.addNode(node);
          dataNode[node] = {page: isJournal};
        }
      }
    }
  }

  void createGraphEdges(List<PageWrapper> allPages) {
    final pattern = RegExp(r'\[\[(.*?)\]\]');
    for (final entry in allPages) {
      final PageModel page = entry.page;
      final bool isJournal = entry.isJournal;

      if (page.uid.isNotEmpty && page.title.isNotEmpty && ((isJournal && page.uid.contains('/')) || (!isJournal))) {
        final pageState = PageState.fromPageModel(page, isJournal);

        for (final item in pageState.items) {
          final matches = pattern.allMatches(item.fullText);
          for (final match in matches) {
            final content = match.group(1);
            if (content != null && titleNode.containsKey(content)) {
              final node1 = titleNode[page.uid]!;
              final node2 = titleNode[content]!;

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

  init() {
    // Combine journals and pages
    final allPages = [
      ...cubit.store.journals.values.map((p) => PageWrapper(page: p, isJournal: true)),
      ...cubit.store.pages.values.map((p) => PageWrapper(page: p, isJournal: false)),
    ];

    // Add nodes (journals + pages)
    createGraphNodes(allPages);

    // Add edges (journals + pages)
    createGraphEdges(allPages);

    emit(GraphState(graph: graph, recursionExist: recursionExist, titleNode: titleNode, dataNode: dataNode));
  }
}
