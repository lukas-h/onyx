import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:onyx/cubit/origin/pb_cubit.dart';
import 'package:onyx/editor/codeblock.dart';
import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';
import 'package:onyx/service/origin_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

import '../cubit/origin/origin_cubit.dart';

class PocketBaseService extends OriginService {
  static const pagesCollectionId = 'pages';
  static const journalsCollectionId = 'journals';
  static const favoritesCollectionId = 'favorites';
  static const assetsCollectionId = 'assets';

  final PocketBase pb;
  final PocketBaseCubit cubit;

  PocketBaseService(this.pb, this.cubit);

  @override
  Future<List<String>> getFavorites() async {
    final list = await pb.collection(favoritesCollectionId).getList();
    return list.items.map((e) => e.getStringValue('uid')).toList();
  }

  void _subscribeToRealtime(String collection) {
    pb.collection(collection).subscribe('*', (e) {
      if (e.record == null) {
        // TODO: Throw user-facing error?
        debugPrint('${e.action} file does not have a record.');
        return;
      }

      final PageModel modifiedPageObject = PageModel(
        uid: e.record?.id ?? '',
        title: e.record?.data['title'] ?? '',
        fullText: parseMarkdownBody((e.record?.data['body']).toString()),
        created: DateTime.tryParse(e.record?.created ?? '') ?? DateTime.now(),
        modified: DateTime.now(),
      );

      final fileIsJournal = collection == journalsCollectionId;

      switch (e.action) {
        case 'create':
          cubit.triggerConflict(modifiedPageObject.uid, fileIsJournal, OriginConflictType.add);
          break;
        case 'update':
          cubit.triggerConflict(modifiedPageObject.uid, fileIsJournal, OriginConflictType.modify);
          break;
        case 'delete':
          cubit.triggerConflict(modifiedPageObject.uid, fileIsJournal, OriginConflictType.delete);
          break;
      }
    });
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
          modified: DateTime.now(),
        );
      },
    ).toList();
  }

  @override
  Future<List<PageModel>> getPages() => _getModels(pagesCollectionId);

  @override
  void subscribeToPages() => _subscribeToRealtime(pagesCollectionId);

  @override
  Future<List<PageModel>> getJournals() => _getModels(journalsCollectionId);

  @override
  void subscribeToJournals() => _subscribeToRealtime(journalsCollectionId);

  @override
  Future<void> createPage(PageModel model) => pb.collection(pagesCollectionId).create(
        body: model.toJson(),
      );

  @override
  Future<void> createJournal(PageModel model) => pb.collection(journalsCollectionId).create(
        body: model.toJson(),
      );

  @override
  Future<void> updatePage(PageModel model) => pb.collection(pagesCollectionId).update(
        model.uid,
        body: model.toJson(),
      );

  @override
  Future<void> updateJournal(PageModel model) async {
    final coll = pb.collection(journalsCollectionId);
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

  @override
  Future<void> deletePage(String uid) => pb.collection(pagesCollectionId).delete(uid);

  @override
  Future<void> createFavorite(String uid) => pb.collection(favoritesCollectionId).create(body: {
        'uid': uid,
      });

  @override
  Future<void> deleteFavorite(String uid) async {
    final list = await pb.collection(favoritesCollectionId).getList(
          filter: 'uid = "$uid"',
          page: 1,
          perPage: 1,
        );
    if (list.items.isNotEmpty) {
      final id = list.items.first.id;
      await pb.collection(favoritesCollectionId).delete(id);
    }
  }

  @override
  Future<void> createImage(ImageModel image) async => pb.collection(assetsCollectionId).create(
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

  @override
  Future<void> deleteImage(String uid) => pb.collection(assetsCollectionId).delete(uid);

  @override
  Future<List<ImageModel>> getImages() async {
    final assets = await pb.collection(assetsCollectionId).getList();
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

  @override
  void close() {
    pb.collection(pagesCollectionId).unsubscribe();
    pb.collection(journalsCollectionId).unsubscribe();
  }

  @override
  void markConflictResolved() {
    cubit.markConflictResolved();
  }
}
