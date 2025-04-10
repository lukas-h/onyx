import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/nanoid.dart';

import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/service/origin_service.dart';
import 'package:onyx/utils/utils.dart';
import 'package:watcher/watcher.dart';

class PageModel {
  final String uid;
  final String title;
  final DateTime created;
  final DateTime modified;
  final List<String> fullText;

  PageModel({
    required this.uid,
    required this.title,
    required this.created,
    required this.modified,
    required this.fullText,
  });

  factory PageModel.fromPageState(PageState state) => PageModel(
        uid: state.uid,
        title: state.title,
        created: state.created,
        modified: state.modified,
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
modified: ${modified.toIso8601String()}
uid: $uid
---

${fullText.join('\n')}
''';

  // TODO: Modify regex to read modified from file too.
  factory PageModel.fromMarkdown(String markdown) {
    // Matches the structure created by toMarkdown() and uses named capturing groups to extract the details for pageModel.
    final fromMarkdownRegex = RegExp(
        r'---\ntitle: (?<title>[\S ]*)\ncreated: (?<created>[\S]*)\nuid: (?<uid>[\S]*)\n---\n\n(?<fullText>(.|\n)*)');

    RegExpMatch? match = fromMarkdownRegex.firstMatch(markdown);
    if (match != null) {
      String? titleGroupMatch = match.namedGroup("title");
      String? createdGroupMatch = match.namedGroup("created");
      String? uidGroupMatch = match.namedGroup("uid");
      String? fullTextGroupMatch = match.namedGroup("fullText");

      return PageModel(
        title: titleGroupMatch ?? '',
        created: DateTime.tryParse(createdGroupMatch ?? '') ?? DateTime.now(),
        modified: DateTime.now(), // TODO: Read from regex match.
        uid: uidGroupMatch ?? nanoid(15),
        fullText: fullTextGroupMatch?.split('\n') ?? const [''],
      );
    }

    throw Exception('Unable to parse file to markdown. Content: $markdown.');
  }

  PageState toPageState(bool isJournal) =>
      PageState.fromPageModel(this, isJournal);

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
    DateTime? modified,
    List<String>? fullText,
  }) {
    return PageModel(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      fullText: fullText ?? this.fullText,
    );
  }
}

class PageStore {
  List<OriginService>? _originServices;
  final List<PageModel> pages = [];
  final List<PageModel> journals = [];

  PageStore({List<OriginService>? originServices})
      : _originServices = originServices;

  set originServices(List<OriginService> originServices) {
    _originServices = originServices;
  }

  Future<void> init() async {
    // TODO check for local changes that aren't online yet
    final dbPages = await _originServices?.firstOrNull?.getPages() ?? [];
    pages.removeWhere((e) => dbPages.map((k) => k.uid).contains(e.uid));
    pages.addAll(dbPages);

    final dbJournals = await _originServices?.firstOrNull?.getJournals() ?? [];
    journals.clear();
    journals.addAll([
      ...List.generate(
        30,
        (index) {
          final date = DateTime.now().subtract(Duration(days: index));
          final title = DateFormat.yMMMMd().format(date);
          final journal = dbJournals.singleWhereOrNull((e) => e.title == title);
          return journal?.copyWith(created: date) ??
              PageModel(
                fullText: const [''],
                title: title,
                created: date,
                modified: DateTime.now(), //TODO: now datetime?
                uid: nanoid(15),
              );
        },
      ),
    ]);
  }

  Future<void> initLimitation() async {
    // TODO check for local changes that aren't online yet
    final dbPages = await _originServices?.firstOrNull?.getPages() ?? [];

    _originServices?.firstOrNull?.subscribeToPages();

    pages.removeWhere((e) => dbPages.map((k) => k.uid).contains(e.uid));
    pages.addAll(dbPages);

    final dbJournals = await _originServices?.firstOrNull?.getJournals() ?? [];

    _originServices?.firstOrNull?.subscribeToJournals();

    journals.clear();
    await loadMoreJournals(dbJournals, 30, false);
  }

  Future<void> loadMoreJournals(
      List<PageModel> dbJournals, int count, bool addNextData) async {
    final currentLength = journals.length;

    // Fetch new journals either by adding next or subtracting previous dates
    final newJournals = List.generate(count, (index) {
      final date = addNextData
          ? DateTime.now().add(Duration(days: currentLength + index))
          : DateTime.now().subtract(Duration(days: currentLength + index));

      final title = DateFormat.yMMMMd().format(date);
      final journal = dbJournals.singleWhereOrNull((e) => e.title == title);

      return journal?.copyWith(created: date) ??
          PageModel(
            fullText: const [''],
            title: title,
            created: date,
            modified: DateTime.now(), //TODO: now datetime?
            uid: nanoid(15),
          );
    });

    // Add the new journals to the existing list
    journals.addAll(newJournals);
  }

  int createPage() {
    final page = PageModel(
      fullText: const [''],
      title: '',
      created: DateTime.now(),
      modified: DateTime.now(),
      uid: nanoid(15),
    );
    pages.add(page);
    _originServices?.firstOrNull?.createPage(page);
    return pages.length - 1;
  }

  void updatePage(PageModel model) {
    pages[pages.indexWhere((e) => e.uid == model.uid)] = model;
    _originServices?.firstOrNull?.updatePage(model);
  }

  void updateJournal(PageModel model) {
    journals[journals.indexWhere((e) => e.uid == model.uid)] = model;
    _originServices?.firstOrNull?.updateJournal(model);
  }

  void deletePage(String uid) {
    pages.removeWhere((e) => e.uid == uid);
    _originServices?.firstOrNull?.deletePage(uid);
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
