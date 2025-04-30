import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';

abstract class OriginService {
  void close();

  // --- FAVORITES ---

  Future<List<String>> getFavorites();
  Future<void> createFavorite(String uid);
  Future<void> deleteFavorite(String uid);

  // --- GET ---

  Future<List<PageModel>> getPages();
  Future<List<PageModel>> getJournals();
  Future<List<ImageModel>> getImages();

  // --- CREATE ---

  Future<void> createPage(PageModel model);
  Future<void> createJournal(PageModel model);
  Future<void> createImage(ImageModel image);

  // --- UPDATE ---

  Future<void> updatePage(PageModel model);
  Future<void> updateJournal(PageModel model);

  // --- DELETE ---

  Future<void> deletePage(String uid);
  Future<void> deleteImage(String uid);

  // --- WATCH CHANGES ---

  void subscribeToPages();
  void subscribeToJournals();

  void markConflictResolved();

  // --- VERSION CONTROL ---

  Future<List<PageModel>> getPageVersions();
  PageModel usePageVersion();
  void commitPage(PageModel model);

  Future<List<PageModel>> getJournalVersions();
  PageModel useJournalVersion(model);
  void commitJournal(PageModel model);
}
