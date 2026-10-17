import 'package:flutter_test/flutter_test.dart';
import 'package:first_project/features/lokasi/logic/countdown_controller.dart';

void main() {
  group('CountdownController Thresholds & Boundaries', () {
    final fixedNow = DateTime(2026, 10, 18, 12, 0, 0);

    test('Just above 10 min (> 10m) is normal', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow.add(const Duration(minutes: 10, seconds: 1)),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.level, CountdownLevel.normal);
      expect(controller.formattedTimer, '00:10:01');
    });

    test('At 10 min boundary (10m 00s) is warning', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow.add(const Duration(minutes: 10)),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.level, CountdownLevel.warning);
      expect(controller.formattedTimer, '00:10:00');
    });

    test('Just below 10 min (9m 59s) is warning', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow.add(const Duration(minutes: 9, seconds: 59)),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.level, CountdownLevel.warning);
      expect(controller.formattedTimer, '00:09:59');
    });

    test('Just above 3 min (3m 01s) is warning', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow.add(const Duration(minutes: 3, seconds: 1)),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.level, CountdownLevel.warning);
      expect(controller.formattedTimer, '00:03:01');
    });

    test('At 3 min boundary (3m 00s) is warning', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow.add(const Duration(minutes: 3)),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.level, CountdownLevel.warning);
      expect(controller.formattedTimer, '00:03:00');
    });

    test('Just below 3 min (2m 59s) is critical', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow.add(const Duration(minutes: 2, seconds: 59)),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.level, CountdownLevel.critical);
      expect(controller.formattedTimer, '00:02:59');
    });

    test('Just above 0 (0m 01s) is critical', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow.add(const Duration(seconds: 1)),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.level, CountdownLevel.critical);
      expect(controller.formattedTimer, '00:00:01');
    });

    test('At 0 boundary (0m 00s) is expired and timer stops at 00:00:00', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow,
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.level, CountdownLevel.expired);
      expect(controller.formattedTimer, '00:00:00');
      expect(controller.remaining, Duration.zero);
      expect(controller.progress, 0.0);
    });

    test('Below 0 (past deadline) is expired and stays at 00:00:00', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow.subtract(const Duration(seconds: 15)),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.level, CountdownLevel.expired);
      expect(controller.formattedTimer, '00:00:00');
      expect(controller.remaining, Duration.zero);
      expect(controller.progress, 0.0);
    });
  });

  group('CountdownController Progress and Formats', () {
    final fixedNow = DateTime(2026, 10, 18, 12, 0, 0);

    test('Computes progress ratio correctly within window', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow.add(const Duration(minutes: 15)),
        totalWindow: const Duration(minutes: 30),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.progress, closeTo(0.5, 0.001));
    });

    test('Progress is 1.0 when full window remains and 0.0 when expired', () {
      final fullController = CountdownController(
        pickupDeadline: fixedNow.add(const Duration(minutes: 30)),
        totalWindow: const Duration(minutes: 30),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );
      expect(fullController.progress, closeTo(1.0, 0.001));

      final expiredController = CountdownController(
        pickupDeadline: fixedNow.subtract(const Duration(minutes: 5)),
        totalWindow: const Duration(minutes: 30),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );
      expect(expiredController.progress, 0.0);
    });

    test('Formats hours, minutes, seconds nicely', () {
      final controller = CountdownController(
        pickupDeadline: fixedNow.add(
          const Duration(hours: 1, minutes: 24, seconds: 35),
        ),
        nowProvider: () => fixedNow,
        autoStartTimer: false,
      );

      expect(controller.formattedTimer, '01:24:35');
    });
  });

  group('CountdownController Dynamic Updates & Timer', () {
    test('Resetting deadline changes state and notifies listeners', () {
      var simulatedTime = DateTime(2026, 10, 18, 12, 0, 0);
      final controller = CountdownController(
        pickupDeadline: simulatedTime.add(const Duration(minutes: 30)),
        nowProvider: () => simulatedTime,
        autoStartTimer: false,
      );

      expect(controller.level, CountdownLevel.normal);

      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.setRemaining(const Duration(minutes: 2));
      expect(controller.level, CountdownLevel.critical);
      expect(notifyCount, 1);

      controller.setRemaining(Duration.zero);
      expect(controller.level, CountdownLevel.expired);
      expect(notifyCount, 2);
    });

    test('Timer ticks every second and recomputes remaining', () async {
      var simulatedTime = DateTime(2026, 10, 18, 12, 0, 0);
      final controller = CountdownController(
        pickupDeadline: simulatedTime.add(const Duration(seconds: 3)),
        nowProvider: () => simulatedTime,
        autoStartTimer: true,
      );

      int tickCount = 0;
      controller.addListener(() => tickCount++);

      expect(controller.formattedTimer, '00:00:03');

      // Advance simulated clock
      simulatedTime = simulatedTime.add(const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 1050));
      expect(tickCount, greaterThanOrEqualTo(1));
      expect(controller.formattedTimer, '00:00:02');

      controller.dispose();
    });
  });
}
