import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onyx/service/origin_service.dart';

enum OriginConflictResolutionType { useInternal, useExternal }

class OriginState {}

class OriginError<C> extends OriginState {
  final String message;
  final C? credentials;

  OriginError({
    required this.message,
    required this.credentials,
  });
}

class OriginPrompt extends OriginState {}

class OriginSuccess<C, S extends OriginService> extends OriginState {
  final C credentials;
  final S service;

  OriginSuccess({
    required this.credentials,
    required this.service,
  });
}

class OriginLoading extends OriginState {}

class OriginConflict extends OriginState {
  final String conflictUid;
  final bool isJournal;
  final String internalValue;
  final String externalValue;

  OriginConflict({
    required this.conflictUid,
    required this.isJournal,
    required this.internalValue,
    required this.externalValue,
  });
}

abstract class OriginCubit<C> extends Cubit<OriginState> {
  OriginCubit() : super(OriginLoading()) {
    _init();
  }
  static const storage = FlutterSecureStorage();

  Future<OriginState> init(FlutterSecureStorage storage);

  Future<void> _init() async {
    try {
      emit(OriginLoading());

      final newState = await init(storage);

      emit(newState);
    } catch (e) {
      emit(
        OriginError(
          message: e.toString(),
          credentials: null,
        ),
      );
    }
  }

  Future<OriginSuccess> reInit(FlutterSecureStorage storage, C credentials);

  Future<void> setCredentials(C credentials) async {
    try {
      emit(OriginLoading());

      final newState = await reInit(storage, credentials);

      emit(newState);
    } catch (e) {
      emit(
        OriginError(
          message: e.toString(),
          credentials: credentials,
        ),
      );
    }
  }

  void triggerConflict(String uid, bool isJournal, String internalValue, String externalValue) {
    emit(OriginConflict(conflictUid: uid, isJournal: isJournal, internalValue: internalValue, externalValue: externalValue));
  }

  // Future<void> resolveConflict(String uid) {

  // }
}
