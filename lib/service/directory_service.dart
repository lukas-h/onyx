import 'dart:async';
import 'dart:io';

import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';
import 'package:onyx/service/service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as y;

class DirectoryService extends OriginService {
  final Directory directory;
  DirectoryService(this.directory);

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
  Future<List<PageModel>> getPages() => _getModels('_pages');

  @override
  Future<List<PageModel>> getJournals() => _getModels('_journals');

  Future<void> _writePage(String collection, PageModel model) async {
    final page = File(
      p.join(
        directory.path,
        collection,
        '${model.uid}.md',
      ),
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
        'assets',
        '$uid.md',
      ),
    );
    if (await page.exists()) {
      await page.delete();
    }
  }

  @override
  Future<void> createPage(PageModel model) => _writePage('_pages', model);

  @override
  Future<void> createJournal(PageModel model) => _writePage('_journals', model);

  @override
  Future<void> updatePage(PageModel model) => _writePage('_pages', model);

  @override
  Future<void> updateJournal(PageModel model) => _writePage('_journals', model);

  @override
  Future<void> deletePage(String uid) => _deleteItem('_pages', uid);

  Future<(List<String>, File)> _getFavoritesImpl() async {
    final file = File(p.join(directory.path, 'favorites.md'));
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
