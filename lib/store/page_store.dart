import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/utils/utils.dart';
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
        fullText: state.items
            .map(
              (e) => List.generate(e.indent, (e) => '  ').join('') + e.fullText,
            )
            .toList(),
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

  PageState toPageState(bool isJournal) =>
      PageState.fromPageModel(this, isJournal);
}

class PageStore {
  final List<PageModel> pages;
  final List<PageModel> journals;

  PageStore(this.pages, this.journals);

  Future<void> init() async {
    journals.addAll([
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
    ]);
  }

  int createPage() {
    final page = PageModel(
      fullText: const [''],
      title: '',
      created: DateTime.now(),
      uid: nanoid(),
    );
    pages.add(page);
    return pages.length - 1;
  }

  void updatePage(PageModel model) {
    pages[pages.indexWhere((e) => e.uid == model.uid)] = model;
  }

  void updateJournal(PageModel model) {
    journals[journals.indexWhere((e) => e.uid == model.uid)] = model;
  }

  void deletePage(String uid) {
    pages.removeWhere((e) => e.uid == uid);
  }

  int getPageIndex(String uid) => pages.indexWhere((e) => e.uid == uid);

  int getJournalIndex(String uid) => journals.indexWhere((e) => e.uid == uid);

  int getTodaysJournalIndex() => journals.indexWhere((e) => isToday(e.created));

  int get journalLength => journals.length;

  int get pageLength => pages.length;

  PageModel? getPage(int index) {
    if (index < 0 || index >= pages.length) return null;
    return pages[index];
  }

  PageModel? getJournal(int index) {
    if (index < 0 || index >= journals.length) return null;
    return journals[index];
  }
}
