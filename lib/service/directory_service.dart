import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:onyx/service/pb_service.dart';
import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';
import 'package:onyx/service/origin_service.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as y;
import 'package:watcher/watcher.dart';

typedef PageRecord = ({DateTime lastModified, String pageContent});

class DirectoryService extends OriginService {
  static const pagesFolderName = '_pages';
  static const journalsFolderName = '_journals';

  final Directory directory;

  final Map<String, PageRecord> pagesCache = {};

  late final Timer writeTimer;

  DirectoryService(this.directory) {
    writeTimer = Timer.periodic(Duration(seconds: 15), (timer) async {
      for (final entry in pagesCache.entries) {
        String pageUid = entry.key;
        PageRecord pageRecord = entry.value;

        final page = File(
          p.join(
            directory.path,
            pagesFolderName,
            '$pageUid.md',
          ),
        );

        if (!await page.exists()) {
          await page.create();
        }
        await page.writeAsString(pageRecord.pageContent);
      }
    });
  }

  // TODO: Clear writeTimer in destructor, something like close in originservice.

  Future<List<PageModel>> _getModels(String collection) async {
    final modelsDir = Directory(p.join(directory.path, collection));
    if (!await modelsDir.exists()) {
      await modelsDir.create();
      return [];
    }
    final list = modelsDir.list();

    final models = <PageModel>[];
    await for (final item in list) {
      if (item is! File) continue;
      final content = await item.readAsString();
      models.add(PageModel.fromMarkdown(content));
    }

    return models;
  }

  @override
  Future<List<PageModel>> getPages() => _getModels(pagesFolderName);

  @override
  void subscribeToPages() {
    DirectoryWatcher(p.join(
      directory.path,
      pagesFolderName,
    )).events.listen((WatchEvent event) {
      switch (event.type) {
        // final pageUid = ;

        case ChangeType.ADD:
          // createPage(event.);
          return;
        case ChangeType.MODIFY:
          // something w/ conflicts??
          return;
        case ChangeType.REMOVE:
          // deletePage();
          return;
      }
    });
  }

  @override
  Future<List<PageModel>> getJournals() => _getModels(journalsFolderName);

  @override
  void subscribeToJournals() {}

  @override
  Future<void> createPage(PageModel model) =>
      _writePage(pagesFolderName, model);

  @override
  Future<void> createJournal(PageModel model) =>
      _writePage(journalsFolderName, model);

  @override
  Future<void> updatePage(PageModel model) =>
      _writePage(pagesFolderName, model);

  @override
  Future<void> updateJournal(PageModel model) =>
      _writePage(journalsFolderName, model);

  @override
  Future<void> deletePage(String uid) => _deleteItem(pagesFolderName, uid);

  Future<void> _writePage(String collection, PageModel model) async {
    final page = File(
      p.join(
        directory.path,
        collection,
        '${model.uid}.md',
      ),
    );

    pagesCache[model.uid] = (
      lastModified: model.modified,
      pageContent: model.toMarkdown(),
    );

    if (!await page.exists()) {
      await page.create();
    }
    await page.writeAsString(model.toMarkdown());
  }

  Future<void> _deleteItem(String collection, String uid) async {
    final page = File(
      p.join(
        directory.path,
        collection,
        '$uid.md',
      ),
    );
    if (await page.exists()) {
      await page.delete();
    }
  }

  Future<(List<String>, File)> _getFavoritesImpl() async {
    final file = File(p.join(directory.path, 'favorites.yaml'));
    if (!await file.exists()) {
      await file.create();
      await file.writeAsString('favorites: []');
      return (<String>[], file);
    }
    final content = await file.readAsString();
    final yaml = y.loadYaml(content);
    final list = (yaml['favorites'] as List).cast<String>();
    return (list, file);
  }

  String _toYaml(Iterable<String> list) {
    final buf = StringBuffer();
    buf.writeln('favorites:');
    for (final item in list) {
      buf.writeln('  - $item');
    }
    return buf.toString();
  }

  @override
  Future<List<String>> getFavorites() async {
    final result = await _getFavoritesImpl();
    return result.$1;
  }

  @override
  Future<void> createFavorite(String uid) async {
    final result = await _getFavoritesImpl();
    final set = result.$1.toSet()..add(uid);
    final file = result.$2;
    await file.writeAsString(_toYaml(set));
  }

  @override
  Future<void> deleteFavorite(String uid) async {
    final result = await _getFavoritesImpl();
    final set = result.$1.toSet()..add(uid);
    final file = result.$2;
    set.remove(uid);
    await file.writeAsString(_toYaml(set));
  }

  @override
  Future<void> createImage(ImageModel image) async {
    final page = File(
      p.join(
        directory.path,
        'assets',
        '${image.uid}.${image.title.split('.').last}',
      ),
    );
    if (!await page.exists()) {
      await page.create();
    }
    await page.writeAsBytes(await image.bytes);
  }

  @override
  Future<void> deleteImage(String uid) => _deleteItem('assets', uid);

  @override
  Future<List<ImageModel>> getImages() async {
    final modelsDir = Directory(p.join(directory.path, 'assets'));
    if (!await modelsDir.exists()) {
      await modelsDir.create();
      return [];
    }
    final list = modelsDir.list();

    final models = <ImageModel>[];
    await for (final item in list) {
      if (item is! File) continue;
      final content = item.readAsBytes();
      final fragments = item.path.split('/');
      String uid = fragments.last.split('.').first;

      models.add(
        ImageModel(
          bytes: content,
          title: fragments.last,
          uid: uid,
        ),
      );
    }
    return models;
  }
}
