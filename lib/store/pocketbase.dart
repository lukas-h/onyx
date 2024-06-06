import 'dart:async';

import 'package:counter_note/store/page_store.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  final PocketBase pb;

  PocketBaseService(this.pb);

  Future<List<PageModel>> _getModels(String collection) async {
    final list = await pb.collection(collection).getList();
    return list.items
        .map(
          (e) => PageModel(
            uid: e.id,
            title: e.data['title'],
            fullText: e.data['body'].toString().split('\n'),
            created: DateTime.tryParse(e.created) ?? DateTime.now(),
          ),
        )
        .toList();
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
}
