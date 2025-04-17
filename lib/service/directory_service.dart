import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:onyx/cubit/origin/directory_cubit.dart';
import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';
import 'package:onyx/service/origin_service.dart';
import 'package:onyx/utils/pausable_interval.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as y;
import 'package:watcher/watcher.dart';

typedef PageChangedRecord = ({DateTime lastModified, String folderName, PageModel pageContent});

class DirectoryService extends OriginService {
  static const pagesFolderName = '_pages';
  static const journalsFolderName = '_journals';

  final Directory directory;

  final Map<String, PageChangedRecord> pagesCache = {};

  // Time after Onyx writing to a file for the changeEvent to be associated with it.
  final fileModificationWindow = Duration(milliseconds: 100);

  late final PausableInterval writeInterval;

  DirectoryService(this.directory) {
    writeInterval = PausableInterval(Duration(seconds: 5), () async {
      for (final entry in pagesCache.entries) {
        String pageUid = entry.key;
        PageChangedRecord pageChangedRecord = entry.value;

        final page = File(
          p.join(
            directory.path,
            pageChangedRecord.folderName,
            '$pageUid.md',
          ),
        );

        if (!await page.exists()) {
          await page.create();
        }

        await page.writeAsString(pageChangedRecord.pageContent.copyWith(modified: DateTime.now()).toMarkdown());

        debugPrint("Written to file $pageUid / ${pageChangedRecord.pageContent.title.toString()} to ${page.path}.");
      }
    });
    writeInterval.start();
  }

  Future<List<PageModel>> _getModels(String collection) async {
    final modelsDir = Directory(p.join(directory.path, collection));
    if (!await modelsDir.exists()) {
      await modelsDir.create();
      return [];
    }

    final list = modelsDir.list();

    final models = <PageModel>[];
    await for (final item in list) {
      debugPrint('getModels: ${item.path}');
      if (item is File) {
        try {
          models.add(await _getModel(item));
        } catch (e) {
          // TODO: Do something with failed file parsing?
          debugPrint(e.toString());
        }
      }
    }

    debugPrint('Models length: ${models.length.toString()}');
    return models;
  }

  Future<PageModel> _getModel(File file) async {
    final content = await file.readAsString();
    return PageModel.fromMarkdown(content);
  }

  @override
  Future<List<PageModel>> getPages() => _getModels(pagesFolderName);

  @override
  void subscribeToPages() {
    debugPrint('Now watching $pagesFolderName directory.');
    DirectoryWatcher(p.join(
      directory.path,
      pagesFolderName,
    )).events.listen((WatchEvent event) async {
      writeInterval.pause();

      final pageUid = p.basenameWithoutExtension(event.path);

      debugPrint('Modified event: ${event.path}.');

      switch (event.type) {
        case ChangeType.ADD:
          // Create new page.case
          // Handle not being exactly Onyx format.
          break;
        case ChangeType.MODIFY:
          PageModel modifiedPageObject;

          try {
            modifiedPageObject = await _getModel(File(event.path));
          } catch (e) {
            debugPrint('Modified file ${event.path} ($pageUid) is not a parsable Onyx markdown file. Exception: $e.');
            return;
          }

          final onyxTriggeredModifyEvent = DateTime.now().difference(modifiedPageObject.modified) < fileModificationWindow;

          if (!onyxTriggeredModifyEvent) {
            debugPrint('Wow this is unexpected, $pageUid was modified! Throw the conflict dialog and pause writing to files!');
            writeInterval.pause();
            context.read<DirectoryCubit>().triggerConflict(modifiedPageObject.uid, modifiedPageObject);
          }
        case ChangeType.REMOVE:
          // Delete page.
          break;
      }

      writeInterval.resume();
    });
  }

  @override
  Future<List<PageModel>> getJournals() => _getModels(journalsFolderName);

  @override
  void subscribeToJournals() {}

  @override
  Future<void> createPage(PageModel model) => _writePage(pagesFolderName, model);

  @override
  Future<void> createJournal(PageModel model) => _writePage(journalsFolderName, model);

  @override
  Future<void> updatePage(PageModel model) => _writePage(pagesFolderName, model);

  @override
  Future<void> updateJournal(PageModel model) => _writePage(journalsFolderName, model);

  @override
  Future<void> deletePage(String uid) => _deleteItem(pagesFolderName, uid);

  Future<void> _writePage(String collection, PageModel model) async {
    pagesCache[model.uid] = (
      lastModified: model.modified,
      folderName: collection,
      pageContent: model,
    );
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

    List<String> list = [];
    if (yaml['favorites'] != null) {
      list = (yaml['favorites'] as List).cast<String>();
    }

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

  @override
  void close() {
    writeInterval.stop();
  }
}
