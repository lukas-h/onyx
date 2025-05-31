import 'package:collection/collection.dart';
import 'package:nanoid/nanoid.dart';
import 'package:onyx/cubit/origin/origin_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/service/origin_service.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:onyx/hive/hive_boxes.dart';
import 'package:onyx/utils/utils.dart';

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

  factory PageModel.fromMarkdown(String markdown) {
    // Matches the structure created by toMarkdown() and uses named capturing groups to extract the details for pageModel.
    final fromMarkdownRegex =
        RegExp(r'---\ntitle: (?<title>[\S ]*)\ncreated: (?<created>[\S]*)\nmodified: (?<modified>[\S]*)\nuid: (?<uid>[\S]*)\n---\n\n(?<fullText>(.|\n)*)');

    RegExpMatch? match = fromMarkdownRegex.firstMatch(markdown);
    if (match != null) {
      String? titleGroupMatch = match.namedGroup("title");
      String? createdGroupMatch = match.namedGroup("created");
      String? modifiedGroupMatch = match.namedGroup("modified");
      String? uidGroupMatch = match.namedGroup("uid");
      String? fullTextGroupMatch = match.namedGroup("fullText");

      return PageModel(
        title: titleGroupMatch ?? '',
        created: DateTime.tryParse(createdGroupMatch ?? '') ?? DateTime.now(),
        modified: DateTime.tryParse(modifiedGroupMatch ?? '') ?? DateTime.now(),
        uid: uidGroupMatch ?? nanoid(15),
        fullText: fullTextGroupMatch?.split('\n') ?? [''],
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
  List<OriginService>? originServices;
  final pages = Hive.box<PageModel>(pageBox);
  final journals = Hive.box<PageModel>(journalBox);

  PageStore({this.originServices});

  Future<void> init() async {
    _initPages();
    _initJournals();
  }

  void _initPages() async {
    final originPages = await originServices?.firstOrNull?.getPages() ?? [];

    // Origin pages which do not exist in Hive.
    for (var originPage in originPages) {
      if (!pages.containsKey(originPage.uid)) {
        pages.put(originPage.uid, originPage.copyWith(modified: DateTime.now()));
      }
    }

    // Hive pages which do not exist in Origin.
    for (var hivePage in pages.values) {
      if (!originPages.any((originPage) => originPage.uid == hivePage.uid)) {
        originServices?.firstOrNull?.createPage(hivePage.copyWith(modified: DateTime.now()));
      }
    }

    originServices?.firstOrNull?.subscribeToPages();
  }

  void _initJournals() async {
    final originJournals = await originServices?.firstOrNull?.getJournals() ?? [];

    // Origin journals which do not exist in Hive.
    for (var originJournal in originJournals) {
      if (!journals.containsKey(originJournal.uid)) {
        journals.put(originJournal.uid, originJournal.copyWith(modified: DateTime.now()));
      }
    }

    // Hive journals which do not exist in Origin.
    for (var hiveJournal in journals.values) {
      if (!originJournals.any((originJournal) => originJournal.uid == hiveJournal.uid)) {
        originServices?.firstOrNull?.createJournal(hiveJournal.copyWith(modified: DateTime.now()));
      }
    }

    originServices?.firstOrNull?.subscribeToJournals();
  }

  void resolveConflict(String modelUid, bool isJournal, OriginConflictResolutionType resolution) async {
    switch (resolution) {
      case OriginConflictResolutionType.useInternal:
        if (isJournal) {
          final internalJournal = journals.get(modelUid);
          if (internalJournal != null) {
            originServices?.firstOrNull?.updateJournal(internalJournal.copyWith(modified: DateTime.now()));
          }
        } else {
          final internalPage = pages.get(modelUid);
          if (internalPage != null) {
            originServices?.firstOrNull?.updatePage(internalPage.copyWith(modified: DateTime.now()));
          }
        }
        break;
      case OriginConflictResolutionType.useExternal:
        if (isJournal) {
          final originJournals = await originServices?.firstOrNull?.getJournals();
          final externalJournal = originJournals?.firstWhereOrNull((journal) => journal.uid == modelUid);
          if (externalJournal != null) {
            journals.put(externalJournal.uid, externalJournal.copyWith(modified: DateTime.now()));
          }
        } else {
          final originPages = await originServices?.firstOrNull?.getPages();
          final externalPage = originPages?.firstWhereOrNull((page) => page.uid == modelUid);
          if (externalPage != null) {
            pages.put(externalPage.uid, externalPage.copyWith(modified: DateTime.now()));
          }
        }
        break;
      case OriginConflictResolutionType.deleteInternal:
        isJournal ? journals.delete(modelUid) : pages.delete(modelUid);
        break;
      case OriginConflictResolutionType.deleteExternal:
        isJournal ? originServices?.firstOrNull?.deleteJournal(modelUid) : originServices?.firstOrNull?.deletePage(modelUid);
        break;
    }

    originServices?.firstOrNull?.markConflictResolved();
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
    originServices?.firstOrNull?.createPage(page);
    return page.uid;
  }

  void updatePage(PageModel model) {
    pages.put(model.uid, model);
    originServices?.firstOrNull?.updatePage(model);
  }

  void updateJournal(PageModel model) {
    journals.put(model.uid, model);
    originServices?.firstOrNull?.updateJournal(model);
  }

  void deletePage(String uid) {
    pages.delete(uid);
    originServices?.firstOrNull?.deletePage(uid);
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
        modified: DateTime.now(),
        uid: dateIdOrToday,
      );
      journals.put(dateIdOrToday, newJournal);
      return newJournal;
    }
  }
}
