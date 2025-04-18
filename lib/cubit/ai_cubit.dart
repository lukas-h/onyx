import 'package:onyx/service/ai_service.dart';
import 'package:replay_bloc/replay_bloc.dart';

class AiCubit extends Cubit<List<OpenAiResponse>> {
  final AiService service;

  AiCubit(super.initialState, {required this.service});

  Future<bool> request(String input) async {
    final response = await service.request(input);

    if (response != null) {
      final newState = List.of(state, growable: true);
      newState.add(response);
      emit(newState);
      return true;
    }

    return false;
  }
}
