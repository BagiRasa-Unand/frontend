import 'dart:async';
import 'package:flutter/foundation.dart';

/// The four visual states for the countdown screen.
enum CountdownLevel {
  /// Remaining time > 10 minutes. Primary teal visual theme.
  normal,

  /// Remaining time between 3 and 10 minutes (<= 10 min and >= 3 min). Warning amber theme.
  warning,

  /// Remaining time under 3 minutes (> 0 and < 3 min). Critical red theme.
  critical,

  /// Remaining time <= 0. Expired/hangus gray theme.
  expired,
}

/// Controller that manages countdown state and updates every second.
///
/// Follows the specification:
/// - Recomputes `remaining = deadline - now()` every second using [Timer.periodic].
/// - Never decrements an internal counter.
/// - Cancels timer in [dispose].
/// - Exposes [level] and normalized [progress] between 0.0 and 1.0.
/// - Allows injecting a custom clock provider [nowProvider] for deterministic testing.
class CountdownController extends ChangeNotifier {
  CountdownController({
    required DateTime pickupDeadline,
    this._totalWindow = const Duration(minutes: 30),
    DateTime Function()? nowProvider,
    bool autoStartTimer = true,
  })  : _deadline = pickupDeadline,
        _nowProvider = nowProvider ?? DateTime.now {


    if (autoStartTimer) {
      _startTimer();
    }
  }

  DateTime _deadline;
  Duration _totalWindow;
  final DateTime Function() _nowProvider;
  Timer? _timer;
  bool _isDisposed = false;

  /// The deadline when the pickup expires.
  DateTime get deadline => _deadline;

  /// The total pickup time window (default 30 minutes).
  Duration get totalWindow => _totalWindow;

  /// Current clock time provided by the clock provider.
  DateTime get now => _nowProvider();

  /// Raw duration between deadline and current time. Can be negative if expired.
  Duration get rawRemaining => _deadline.difference(_nowProvider());

  /// Clamped duration remaining. Stops at [Duration.zero].
  Duration get remaining {
    final raw = rawRemaining;
    return raw > Duration.zero ? raw : Duration.zero;
  }

  /// Current visual level according to thresholds:
  /// - remaining > 10 min = normal
  /// - 3 to 10 min = warning
  /// - 0 to 3 min = critical
  /// - <= 0 = expired
  CountdownLevel get level {
    final raw = rawRemaining;
    if (raw <= Duration.zero) {
      return CountdownLevel.expired;
    }
    if (raw < const Duration(minutes: 3)) {
      return CountdownLevel.critical;
    }
    if (raw <= const Duration(minutes: 10)) {
      return CountdownLevel.warning;
    }
    return CountdownLevel.normal;
  }

  /// Progress value between 0.0 and 1.0 representing the remaining ratio of the total window.
  /// When expired or totalWindow <= 0, returns 0.0.
  double get progress {
    if (_totalWindow.inMilliseconds <= 0) return 0.0;
    final rem = rawRemaining;
    if (rem <= Duration.zero) return 0.0;
    final ratio = rem.inMilliseconds / _totalWindow.inMilliseconds;
    return ratio.clamp(0.0, 1.0);
  }

  /// Formatted timer string in HH:MM:SS format (e.g. 00:24:35).
  /// Stops at 00:00:00 when expired.
  String get formattedTimer {
    final rem = remaining;
    final hours = rem.inHours.toString().padLeft(2, '0');
    final minutes = (rem.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (rem.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Formatted remaining label for subtext (e.g. "> 10 Menit tersisa").
  String get stateSubtitle {
    return switch (level) {
      CountdownLevel.normal => '> 10 Menit tersisa',
      CountdownLevel.warning => '< 10 Menit (Segera)',
      CountdownLevel.critical => '< 3 Menit (Gawat!)',
      CountdownLevel.expired => 'Waktu berakhir',
    };
  }

  /// Resets the deadline (used by DEMO controls to switch states live).
  void resetDeadline(DateTime newDeadline, {Duration? newTotalWindow}) {
    _deadline = newDeadline;
    if (newTotalWindow != null) {
      _totalWindow = newTotalWindow;
    }
    notifyListeners();
  }

  /// Sets remaining time relative to current now.
  void setRemaining(Duration rem, {Duration? newTotalWindow}) {
    _deadline = _nowProvider().add(rem);
    if (newTotalWindow != null) {
      _totalWindow = newTotalWindow;
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed) return;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
