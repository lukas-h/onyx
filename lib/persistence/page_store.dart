import 'package:counter_note/cubit/page_cubit.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/nanoid.dart';

class PageModel {
  final String uid;
  final String title;
  final DateTime created;
  final List<String> fullText;

  PageModel({
    required this.uid,
    required this.title,
    required this.created,
    required this.fullText,
  });

  factory PageModel.fromPageState(PageState state) => PageModel(
        uid: state.uid,
        title: state.title,
        created: state.created,
        fullText: state.items.map((e) => e.fullText).toList(),
      );

  String toMarkdown() => '''
---
title: $title
created: ${created.toIso8601String()}
uid: $uid
---

${fullText.join('\n')}
''';

// TODO finish markdown parser
  factory PageModel.fromMarkdown(String markdown) => PageModel(
        created: DateTime.now(),
        fullText: [],
        title: '',
        uid: '',
      );

  PageState toPageState() => PageState.fromPageModel(this);
}

class PageStore {
  final List<PageModel> pages;
  late final List<PageModel> journals;

  PageStore(this.pages, this.journals);

  Future<void> init() async {
    journals = [
      ...List.generate(
        30,
        (index) {
          final date = DateTime.now().subtract(Duration(days: index));
          return PageModel(
            fullText: const [''],
            title: DateFormat.yMMMMd().format(date),
            created: date,
            uid: nanoid(),
          );
        },
      ),
    ];
  }

  updatePage() {}
  updateJournal() {}
}
