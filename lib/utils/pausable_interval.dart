import 'dart:async';
import 'package:flutter/foundation.dart';

typedef IntervalMethod = Future<Null> Function();

class PausableInterval {
  final Duration interval;
  final IntervalMethod method;

  Timer? _currentTimer;
  bool _isRunning = false;

  PausableInterval(this.interval, this.method);

  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _currentTimer = Timer.periodic(interval, (timer) {
      method();
    });
  }

  void pause() {
    if (!_isRunning) return;
    _currentTimer?.cancel();
    _isRunning = false;
  }

  void resume() {
    if (!_isRunning) start();
  }

  void stop() {
    pause();
  }

  bool get isRunning => _isRunning;
}
