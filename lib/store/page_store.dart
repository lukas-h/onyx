import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:nanoid/nanoid.dart';

import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/store/pocketbase.dart';
import 'package:onyx/hive/hive_boxes.dart';
import 'package:onyx/utils/utils.dart';

class PageModel extends HiveObject {
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

  PageState toPageState(bool isJournal) => PageState.fromPageModel(this, isJournal);

  Map<String, dynamic> toJson() => {
        'title': title,
        'uid': uid,
        'id': uid,
        'body': fullText.join('\n'),
      };

  PageModel copyWith({
    String? uid,
    String? title,
    DateTime? created,
    List<String>? fullText,
  }) {
    return PageModel(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      created: created ?? this.created,
      fullText: fullText ?? this.fullText,
    );
  }
}

class PageStore {
  PocketBaseService? _pbService;
  final pages = Hive.box<PageModel>(pageBox);
  final journals = Hive.box<PageModel>(journalBox);

  PageStore({PocketBaseService? pbService}) : _pbService = pbService;

  set pbService(PocketBaseService pbService) {
    _pbService = pbService;
  }

  Future<void> init() async {
    // TODO check for local changes that aren't online yet
    // conflict management needs to happen here
    final dbPages = await _pbService?.getPages() ?? [];
    _pbService?.subscribeToPage();
    pages.putAll(Map.fromIterable(dbPages, key: (element) => element.uid));

    final dbJournals = await _pbService?.getJournals() ?? [];
    _pbService?.subscribeToJournals();
    journals.clear();
    journals.putAll(Map.fromIterable(dbJournals, key: (element) => element.uid));
  }

  Future<void> initLimitation() async {
    // TODO check for local changes that aren't online yet
    // conflict management needs to happen here
    final dbPages = await _pbService?.getPages() ?? [];
    _pbService?.subscribeToPage();
    pages.putAll(Map.fromIterable(dbPages, key: (element) => element.uid));

    final dbJournals = await _pbService?.getJournals() ?? [];
    _pbService?.subscribeToJournals();
    journals.putAll(Map.fromIterable(dbJournals, key: (element) => element.uid));
  }

  String createPage() {
    final page = PageModel(
      fullText: const [''],
      title: '',
      created: DateTime.now(),
      uid: nanoid(15),
    );
    pages.put(page.uid, page);
    _pbService?.createPage(page);
    return page.uid;
  }

  void updatePage(PageModel model) {
    pages.put(model.uid, model);
    _pbService?.updatePage(model);
  }

  void updateJournal(PageModel model) {
    journals.put(model.uid, model);
    _pbService?.updateJournal(model);
  }

  void deletePage(String uid) {
    pages.delete(uid);
    _pbService?.deletePage(uid);
  }

  String getTodaysJournalId() => ddmmyyyy.format(DateTime.now());

  int get journalLength => journals.length;

  int get pageLength => pages.length;

  PageModel? getPage(String id) {
    return pages.get(id);
  }

  PageModel getJournal(String dateId) {
    final dateIdOrToday = parseDateOrToday(dateId);

    final journal = journals.get(dateIdOrToday);
    if (journal != null) {
      return journal;
    } else {
      final newJournal = PageModel(
        fullText: const [''],
        title: dateIdOrToday,
        created: DateTime.now(),
        uid: dateIdOrToday,
      );
      journals.put(dateIdOrToday, newJournal);
      return newJournal;
    }
  }
}
