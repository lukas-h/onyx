import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityCubit extends Cubit<bool> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit() : super(false) {
    _subscription = Connectivity().onConnectivityChanged.listen(
      (result) {
        emit(
          result.contains(ConnectivityResult.wifi) ||
              result.contains(ConnectivityResult.ethernet) ||
              result.contains(ConnectivityResult.mobile),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
