import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';

abstract class OriginService {
  Future<List<String>> getFavorites();

  Future<List<PageModel>> getPages();

  Future<List<PageModel>> getJournals();

  Future<void> createPage(PageModel model);

  Future<void> createJournal(PageModel model);

  Future<void> updatePage(PageModel model);

  Future<void> updateJournal(PageModel model);

  Future<void> deletePage(String uid);

  Future<void> createFavorite(String uid);

  Future<void> deleteFavorite(String uid);

  Future<void> createImage(ImageModel image);

  Future<void> deleteImage(String uid);

  Future<List<ImageModel>> getImages();
}
