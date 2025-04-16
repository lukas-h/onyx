import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/nanoid.dart';

import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/service/origin_service.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:nanoid/nanoid.dart';

import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/store/pocketbase.dart';
import 'package:onyx/hive/hive_boxes.dart';
import 'package:onyx/utils/utils.dart';
import 'package:watcher/watcher.dart';

class PageModel extends HiveObject {
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
    final fromMarkdownRegex = RegExp(r'---\ntitle: (?<title>[\S ]*)\ncreated: (?<created>[\S]*)\nuid: (?<uid>[\S]*)\n---\n\n(?<fullText>(.|\n)*)');

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
  final pages = Hive.box<PageModel>(pageBox);
  final journals = Hive.box<PageModel>(journalBox);

  PageStore({List<OriginService>? originServices}) : _originServices = originServices;

  set originServices(List<OriginService> originServices) {
    _originServices = originServices;
  }

  Future<void> init() async {
    // TODO check for local changes that aren't online yet

    final dbPages = await await _originServices?.firstOrNull?.getPages() ?? [];
    pages.putAll(Map.fromIterable(dbPages, key: (element) => element.uid));

    _originServices?.firstOrNull?.subscribeToPages();

    final dbJournals = await _originServices?.firstOrNull?.getJournals() ?? [];
    journals.clear();
    journals.putAll(Map.fromIterable(dbJournals, key: (element) => element.uid));

    _originServices?.firstOrNull?.subscribeToJournals();
  }

  String createPage() {
    final page = PageModel(
      fullText: const [''],
      title: '',
      created: DateTime.now(),
      modified: DateTime.now(),
      uid: nanoid(15),
    );
    pages.put(page.uid, page);
    _originServices?.firstOrNull?.createPage(page);
    return page.uid;
  }

  void updatePage(PageModel model) {
    pages.put(model.uid, model);
    _originServices?.firstOrNull?.updatePage(model);
  }

  void updateJournal(PageModel model) {
    journals.put(model.uid, model);
    _originServices?.firstOrNull?.updateJournal(model);
  }

  void deletePage(String uid) {
    pages.delete(uid);
    _originServices?.firstOrNull?.deletePage(uid);
  }

  String getTodaysJournalId() => ddmmyyyy.format(DateTime.now());

  int get journalLength => journals.length;

  int get pageLength => pages.length;

  PageModel? getPage(String id) {
    return pages.get(id);
  }

  PageModel getJournal(String dateId) {
    final journal = journals.get(dateId);
    if (journal != null) {
      return journal;
    } else {
      final newJournal = PageModel(
        fullText: const [''],
        title: dateId,
        created: DateTime.now(),
        uid: dateId,
      );
      journals.put(dateId, newJournal);
      return newJournal;
    }
  }
}
