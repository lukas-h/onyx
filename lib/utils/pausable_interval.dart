import 'dart:async';

class PausableInterval {
  final Duration interval;
  final Function method;

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
    start();
  }

  void stop() {
    pause();
  }

  bool get isRunning => _isRunning;
}
