import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';

abstract class OriginService {
  void close();

  Future<List<String>> getFavorites();

  Future<List<PageModel>> getPages();

  Future<PageModel> getPage(String uid);

  void subscribeToPages();

  Future<List<PageModel>> getJournals();

  Future<PageModel> getJournal(String uid);

  void subscribeToJournals();

  Future<void> createPage(PageModel model);

  Future<void> createJournal(PageModel model);

  Future<void> updatePage(PageModel model);

  Future<void> updateJournal(PageModel model);

  Future<void> deletePage(String uid);

  // Only used for conflict resolution; journals cannot be deleted by UI actions.
  Future<void> deleteJournal(String uid);

  Future<void> createFavorite(String uid);

  Future<void> deleteFavorite(String uid);

  Future<void> createImage(ImageModel image);

  Future<void> deleteImage(String uid);

  Future<List<ImageModel>> getImages();

  void markConflictResolved();

  List<String> getCommitHashes() => List.empty();

  Future<PageModel> getModelAtVersion(String uid, bool isJournal, String versionHash) async => isJournal ? await getPage(uid) : await getJournal(uid);

  void commitChanges() {}
}
