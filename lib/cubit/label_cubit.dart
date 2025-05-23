import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/store/label_store.dart';

class LabelCubit extends Cubit<List<String>> {
  final LabelStore store;
  LabelCubit({required this.store}) : super([]) {
    init();
  }

  Future<void> init() async {
    await store.init();
    emit(store.labels);
  }

  Future<void> addLabel(String label) async {
    await store.addLabel(label);
    emit(store.labels);
  }

  Future<void> removeLabel(String label) async {
    await store.removeLabel(label);
    emit(store.labels);
  }
}
