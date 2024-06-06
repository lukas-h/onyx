class FavoriteStore {
  final Set<String> _favorites;

  FavoriteStore(List<String> favorites) : _favorites = favorites.toSet();

  Future<void> init() async {
    _favorites.addAll([]);
  }

  Future<void> addFavorite(String uid) async {
    _favorites.add(uid);
  }

  void removeFavorite(String uid) {
    _favorites.remove(uid);
  }

  List<String> get favorites => _favorites.toList();
}
