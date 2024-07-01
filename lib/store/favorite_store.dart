import 'package:onyx/service/pb_service.dart';

class FavoriteStore {
  PocketBaseService? _pbService;
  final Set<String> _favorites = {};

  FavoriteStore({PocketBaseService? pbService}) : _pbService = pbService;

  set pbService(PocketBaseService pbService) {
    _pbService = pbService;
  }

  Future<void> init() async {
    final dbFavorites = await _pbService?.getFavorites() ?? [];
    _favorites.addAll(dbFavorites);
  }

  Future<void> addFavorite(String uid) async {
    _favorites.add(uid);
    _pbService?.createFavorite(uid);
  }

  void removeFavorite(String uid) {
    _favorites.remove(uid);
    _pbService?.deleteFavorite(uid);
  }

  List<String> get favorites => _favorites.toList();
}
