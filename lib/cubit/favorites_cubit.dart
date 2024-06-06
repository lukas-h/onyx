import 'package:onyx/store/favorite_store.dart';
import 'package:replay_bloc/replay_bloc.dart';

class FavoritesCubit extends Cubit<List<String>> {
  final FavoriteStore store;
  FavoritesCubit({required this.store}) : super([]);

  Future<void> init() async {
    await store.init();
    emit(store.favorites);
  }

  Future<void> add(String uid) async {
    store.addFavorite(uid);
    emit(store.favorites);
  }

  Future<void> remove(String uid) async {
    store.removeFavorite(uid);
    emit(store.favorites);
  }
}
