import 'package:onyx/service/service.dart';

class FavoriteStore {
  List<OriginService>? _originServices;
  final Set<String> _favorites = {};

  FavoriteStore({List<OriginService>? originServices})
      : _originServices = originServices;

  set originServices(List<OriginService> originServices) {
    _originServices = originServices;
  }

  Future<void> init() async {
    final dbFavorites =
        await _originServices?.firstOrNull?.getFavorites() ?? [];
    _favorites.addAll(dbFavorites);
  }

  Future<void> addFavorite(String uid) async {
    _favorites.add(uid);
    _originServices?.firstOrNull?.createFavorite(uid);
  }

  void removeFavorite(String uid) {
    _favorites.remove(uid);
    _originServices?.firstOrNull?.deleteFavorite(uid);
  }

  List<String> get favorites => _favorites.toList();
}
