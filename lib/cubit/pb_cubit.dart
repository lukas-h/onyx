import 'package:counter_note/store/pocketbase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:replay_bloc/replay_bloc.dart';

class PocketBaseState {}

class PocketBaseError extends PocketBaseState {
  final String message;
  final String url;
  final String email;
  final String password;

  PocketBaseError({
    required this.message,
    required this.url,
    required this.email,
    required this.password,
  });
}

class PocketBasePrompt extends PocketBaseState {}

class PocketBaseSuccess extends PocketBaseState {
  final String url;
  final String email;
  final String password;
  final PocketBase pocketBase;
  PocketBaseService get service => PocketBaseService(pocketBase);

  PocketBaseSuccess({
    required this.url,
    required this.email,
    required this.password,
    required this.pocketBase,
  });
}

class PocketBaseLoading extends PocketBaseState {}

class PocketBaseCubit extends Cubit<PocketBaseState> {
  PocketBaseCubit() : super(PocketBaseLoading()) {
    init();
  }
  static const storage = FlutterSecureStorage();

  Future<void> init() async {
    try {
      emit(PocketBaseLoading());
      final url = await storage.read(key: 'url');
      final email = await storage.read(key: 'email');
      final password = await storage.read(key: 'password');

      if (url != null && email != null && password != null) {
        final pb = PocketBase(url);
        await pb.admins.authWithPassword(email, password);
        emit(
          PocketBaseSuccess(
            url: url,
            email: email,
            password: password,
            pocketBase: pb,
          ),
        );
      } else {
        emit(PocketBasePrompt());
      }
    } catch (e) {
      emit(
        PocketBaseError(
          message: e.toString(),
          url: '',
          email: '',
          password: '',
        ),
      );
    }
  }

  Future<void> setCredentials({
    required String url,
    required String email,
    required String password,
  }) async {
    try {
      emit(PocketBaseLoading());
      await storage.write(key: 'url', value: url);
      await storage.write(key: 'email', value: email);
      await storage.write(key: 'password', value: password);
      final pb = PocketBase(url);
      await pb.admins.authWithPassword(email, password);
      emit(
        PocketBaseSuccess(
          url: url,
          email: email,
          password: password,
          pocketBase: pb,
        ),
      );
    } catch (e) {
      emit(
        PocketBaseError(
          message: e.toString(),
          url: url,
          email: email,
          password: password,
        ),
      );
    }
  }
}
