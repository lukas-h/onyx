import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';

abstract class OriginService {
  void close();

  // --- FAVORITES ---

  Future<List<String>> getFavorites();
  Future<List<PageModel>> getPages();

  void subscribeToPages();

  Future<List<PageModel>> getJournals();

  void subscribeToJournals();

  Future<void> createPage(PageModel model);

  Future<void> createJournal(PageModel model);

  Future<void> updatePage(PageModel model);

  Future<void> updateJournal(PageModel model);

  Future<void> deletePage(String uid);

  // Only used for conflict resolution; journals cannot be deleted by UI actions.
  Future<void> deleteJournal(String uid);

  Future<List<PageModel>> getPageVersions();

  PageModel usePageVersion();

  void commitPage(PageModel model);

  Future<List<PageModel>> getJournalVersions();

  PageModel useJournalVersion(model);

  void commitJournal(PageModel model);
}
