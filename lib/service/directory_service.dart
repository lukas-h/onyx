import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:onyx/cubit/origin/directory_cubit.dart';
import 'package:onyx/cubit/origin/origin_cubit.dart';
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
  final DirectoryCubit cubit;

  final Map<String, PageChangedRecord> pagesCache = {};

  // Time after Onyx writing to a file for the changeEvent to be associated with it.
  final fileModificationWindow = Duration(milliseconds: 100);

  late final PausableInterval writeInterval;

  DirectoryService(this.directory, this.cubit) {
    writeInterval = PausableInterval(Duration(seconds: 5), () async {
      // Deep copy pages cache to avoid modifying it while iterating.
      final pagesCacheCopy = pagesCache.map((key, value) {
        final copiedRecord = (
          lastModified: DateTime.fromMillisecondsSinceEpoch(value.lastModified.millisecondsSinceEpoch),
          folderName: value.folderName,
          pageContent: value.pageContent.copyWith()
        );
        return MapEntry(key, copiedRecord);
      });

      pagesCache.clear();
      for (final entry in pagesCacheCopy.entries) {
        String pageUid = entry.key;
        PageChangedRecord pageChangedRecord = entry.value;

        final page = File(
          p.join(
            directory.path,
            pageChangedRecord.folderName,
            // Need to replace slashes as the journal uid is the current date (eg. 18/04/2025);
            pageChangedRecord.folderName == journalsFolderName ? '${pageUid.replaceAll('/', '.')}.md' : '$pageUid.md',
          ),
        );

        if (!await page.exists()) {
          await page.create();
        }

        await page.writeAsString(pageChangedRecord.pageContent.copyWith(modified: DateTime.now()).toMarkdown());
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
      if (item is File) {
        try {
          models.add(await _getModel(item));
        } catch (e) {
          // TODO: Do something with failed file parsing?
          debugPrint('Failed to parse file "${item.path}". Error: ${e.toString()}.');
        }
      }
    }

    return models;
  }

  Future<PageModel> _getModel(File file) async {
    final content = await file.readAsString();
    return PageModel.fromMarkdown(content);
  }

  @override
  Future<List<PageModel>> getPages() => _getModels(pagesFolderName);

  @override
  Future<PageModel> getPage(String uid) {
    final pageFile = File(p.join(directory.path, pagesFolderName, '$uid.md'));
    return _getModel(pageFile);
  }

  @override
  void subscribeToPages() => _watchDirectory(pagesFolderName);

  @override
  Future<List<PageModel>> getJournals() => _getModels(journalsFolderName);

  @override
  Future<PageModel> getJournal(String uid) {
    final journalFile = File(p.join(directory.path, journalsFolderName, '$uid.md'));
    return _getModel(journalFile);
  }

  @override
  void subscribeToJournals() => _watchDirectory(journalsFolderName);

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

  @override
  Future<void> deleteJournal(String uid) => _deleteItem(journalsFolderName, uid);

  @override
  void markConflictResolved() {
    writeInterval.resume();
    cubit.markConflictResolved();
  }

  final Map<String, StreamSubscription<WatchEvent>> _watchDirectorySubscriptions = {};

  // Still potential for issues with concurrent changes (eg. selecting multiple files to delete).
  // TODO: Queue changes and wait for the conflict dialog to close before resolving the next one.
  void _watchDirectory(String directoryName) async {
    _watchDirectorySubscriptions[directoryName] = DirectoryWatcher(
            p.join(
              directory.path,
              directoryName,
            ),
            pollingDelay: Duration(seconds: 5))
        .events
        .listen((event) => _processDirectoryChangeEvent(event, directoryName));
  }

  void _cancelAllDirectoryWatchers() {
    for (final subscription in _watchDirectorySubscriptions.values) {
      subscription.cancel();
    }
  }

  void _restartAllDirectoryWatchers() {
    for (final directory in _watchDirectorySubscriptions.keys) {
      _watchDirectory(directory);
    }
  }

  @override
  void close() {
    writeInterval.stop();
  }

  void _processDirectoryChangeEvent(WatchEvent event, String directoryName) async {
    if (_watchDirectorySubscriptions[directoryName]?.isPaused ?? false) return;

    debugPrint('Change event.');

    final fileName = p.basenameWithoutExtension(event.path);

    // Ignore GLib temporary files in Linux.
    // See here: https://github.com/mate-desktop/caja/issues/1439#issuecomment-671674987.
    if (fileName.startsWith('.goutputstream')) {
      return;
    }

    final fileIsJournal = fileName.contains('.');
    final pageUid = fileIsJournal ? fileName.replaceAll('.', '/') : fileName;

    pagesCache.remove(pageUid);
    writeInterval.pause();

    switch (event.type) {
      case ChangeType.ADD:
      case ChangeType.MODIFY:
        late final PageModel modifiedPageObject;
        try {
          modifiedPageObject = await _getModel(File(event.path));
        } catch (e) {
          debugPrint('Modified file ${event.path} ($pageUid) is not a parsable Onyx markdown file. Exception: $e.');
          return;
        }

        final onyxTriggeredModifyEvent = DateTime.now().difference(modifiedPageObject.modified) < fileModificationWindow;
        if (!onyxTriggeredModifyEvent) {
          cubit.triggerConflict(
            modifiedPageObject.uid,
            fileIsJournal,
            event.type == ChangeType.ADD ? OriginConflictType.add : OriginConflictType.modify,
          );
        } else {
          writeInterval.resume();
        }
        break;
      case ChangeType.REMOVE:
        cubit.triggerConflict(pageUid, fileIsJournal, OriginConflictType.delete);
        break;
    }
  }

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
  Future<List<VersionRecord>> getVersions() async {
    try {
      final commandResult = await Process.run(
        'git',
        ['--no-pager', 'log', '--pretty=format:%H,%ad,%an,%s', '--date=iso'],
        runInShell: true,
        workingDirectory: directory.path,
      );
      if (commandResult.exitCode != 0) throw Exception('Git command failed: ${commandResult.stderr}');

      final gitCommitStrings = commandResult.stdout.toString().split('\n');

      return gitCommitStrings.map<VersionRecord>((commitString) {
        final splitCommitString = commitString.split(',');
        return (
          versionId: splitCommitString[0],
          versionDate: DateTime.parse(splitCommitString[1]),
          author: splitCommitString[2],
          commitMessage: splitCommitString.sublist(3).join(','), // Include author in commit message
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed to parse Git response. ${e.toString()}.');
      return [];
    }
  }

  @override
  Future<List<ChangeRecord>> getCurrentDiff() async {
    try {
      final commandResult = await Process.run(
        'git',
        ['--no-pager', 'status', '--porcelain'],
        runInShell: true,
        workingDirectory: directory.path,
      );
      if (commandResult.exitCode != 0) throw Exception('Git command failed: ${commandResult.stderr}');

      final gitChangesStrings = commandResult.stdout.toString().split('\n');
      gitChangesStrings.removeLast(); // Remove the trailing empty string after the final newline.

      return gitChangesStrings.map<ChangeRecord>((changeString) {
        return (
          changeType: changeString.substring(0, 2), // First two characters (plus the joining space) describe the change type.
          filePath: changeString.substring(3), // The rest of the string is the filepath.
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed to get Git diff. ${e.toString()}.');
      return [];
    }
  }

  @override
  Future<void> revertToVersion(String versionId) async {
    try {
      // Cancel to avoid throwing the conflict dialog when reverting.
      _cancelAllDirectoryWatchers();

      var commandResult = await Process.run(
        'git',
        ['reset', '--hard', versionId],
        runInShell: true,
        workingDirectory: directory.path,
      );
      if (commandResult.exitCode != 0) throw Exception('Git command failed: ${commandResult.stderr}');
    } catch (e) {
      debugPrint('Failed to revert. ${e.toString()}.');
    } finally {
      _restartAllDirectoryWatchers();
    }
  }

  @override
  void commitChanges(String message) async {
    try {
      var addResult = await Process.run('git', ['add', '-A'], runInShell: true, workingDirectory: directory.path);
      if (addResult.exitCode != 0) throw Exception('Failed to add untracked files: ${addResult.stderr}');

      var commitResult = await Process.run('git', ['commit', '-m', message], runInShell: true, workingDirectory: directory.path);
      if (commitResult.exitCode != 0) throw Exception('Failed to commit changes: ${commitResult.stderr}');

      var pushResult = await Process.run('git', ['push'], runInShell: true, workingDirectory: directory.path);
      if (pushResult.exitCode != 0) throw Exception('Failed to push commit: ${pushResult.stderr}');
    } catch (e) {
      debugPrint('Failed to commit changes. ${e.toString()}.');
    }
  }
}
