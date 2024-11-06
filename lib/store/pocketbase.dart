import 'dart:async';

import 'package:onyx/editor/codeblock.dart';
import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

class PocketBaseService {
  final PocketBase pb;

  PocketBaseService(this.pb);

  Future<List<String>> getFavorites() async {
    final list = await pb.collection('favorites').getList();
    return list.items.map((e) => e.getStringValue('uid')).toList();
  }

  Future<List<PageModel>> _getModels(String collection) async {
    final list = await pb.collection(collection).getList();
    return list.items.map(
      (e) {
        return PageModel(
          uid: e.id,
          title: e.data['title'],
          fullText: parseMarkdownBody(e.data['body'].toString()),
          created: DateTime.tryParse(e.created) ?? DateTime.now(),
        );
      },
    ).toList();
  }

  Future<List<PageModel>> getPages() => _getModels('pages');

  Future<List<PageModel>> getJournals() => _getModels('journals');

  Future<void> createPage(PageModel model) => pb.collection('pages').create(
        body: model.toJson(),
      );

  Future<void> createJournal(PageModel model) =>
      pb.collection('journals').create(
            body: model.toJson(),
          );

  Future<void> updatePage(PageModel model) => pb.collection('pages').update(
        model.uid,
        body: model.toJson(),
      );

  Future<void> updateJournal(PageModel model) async {
    final coll = pb.collection('journals');
    try {
      final item = await coll.getFirstListItem('title = "${model.title}"');
      final id = item.id;
      final updatedModel = model.copyWith(uid: id);
      await coll.update(
        id,
        body: updatedModel.toJson(),
      );
    } catch (e) {
      await coll.create(body: model.toJson());
    }
  }

  Future<void> deletePage(String uid) => pb.collection('pages').delete(uid);

  Future<void> createFavorite(String uid) =>
      pb.collection('favorites').create(body: {
        'uid': uid,
      });

  Future<void> deleteFavorite(String uid) async {
    final list = await pb.collection('favorites').getList(
          filter: 'uid = "$uid"',
          page: 1,
          perPage: 1,
        );
    if (list.items.isNotEmpty) {
      final id = list.items.first.id;
      await pb.collection('favorites').delete(id);
    }
  }

  Future<void> createImage(ImageModel image) async =>
      pb.collection('assets').create(
        body: {
          'title': image.title,
          'id': image.uid,
        },
        files: [
          http.MultipartFile.fromBytes(
            'file',
            await image.bytes,
            filename: image.title,
          ),
        ],
      );

  Future<void> deleteImage(String uid) => pb.collection('assets').delete(uid);

  Future<List<ImageModel>> getImages() async {
    final assets = await pb.collection('assets').getList();
    final list = <ImageModel>[];
    for (final item in assets.items) {
      final fileName = item.getStringValue('file');

      final url = pb.files.getUrl(item, fileName, download: true);

      final resp = http.get(url).then((v) => v.bodyBytes);

      list.add(
        ImageModel(
          bytes: resp,
          title: item.getStringValue('title'),
          uid: item.id,
        ),
      );
    }
    return list;
  }
}
