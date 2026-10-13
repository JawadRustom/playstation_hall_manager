import 'package:flutter_test/flutter_test.dart';
import 'package:playstation_hall_manager/models/playstation_model.dart';
import 'package:playstation_hall_manager/models/session_model.dart';
import 'package:playstation_hall_manager/services/session_billing.dart';

void main() {
  group('selectHourlyPrice', () {
    const playstation = PlayStationModel(
      id: 1,
      name: 'Test PlayStation',
      controllersCount: 4,
      priceForTwo: 10000,
      priceForThree: 12000,
      priceForFour: 14000,
      isAvailable: true,
    );

    final supportedPlayerCounts = <int, int>{2: 10000, 3: 12000, 4: 14000};

    for (final entry in supportedPlayerCounts.entries) {
      test('returns the configured rate for ${entry.key} players', () {
        expect(selectHourlyPrice(playstation, entry.key), entry.value);
      });
    }

    test('returns zero for unsupported player counts', () {
      const unsupportedPlayerCounts = [0, 1, 5];

      for (final playersCount in unsupportedPlayerCounts) {
        expect(
          selectHourlyPrice(playstation, playersCount),
          0,
          reason: '$playersCount players is unsupported',
        );
      }
    });
  });

  group('calculateElapsedDuration', () {
    final startTime = DateTime.utc(2026, 10, 13, 12);

    test('returns the actual elapsed duration', () {
      final endTime = startTime.add(
        const Duration(minutes: 30, microseconds: 123),
      );

      expect(
        calculateElapsedDuration(startTime: startTime, endTime: endTime),
        const Duration(minutes: 30, microseconds: 123),
      );
    });

    test('returns zero when both timestamps are equal', () {
      expect(
        calculateElapsedDuration(startTime: startTime, endTime: startTime),
        Duration.zero,
      );
    });

    test('clamps a future start time to zero elapsed duration', () {
      final endTime = startTime.subtract(const Duration(microseconds: 1));

      expect(
        calculateElapsedDuration(startTime: startTime, endTime: endTime),
        Duration.zero,
      );
    });
  });

  group('calculateSessionCharge', () {
    SessionModel session({
      required int hourlyPrice,
      Duration? plannedDuration,
    }) {
      return SessionModel(
        playstationId: 1,
        playersCount: 2,
        hourlyPrice: hourlyPrice,
        startTime: DateTime.utc(2026, 10, 13, 12),
        type: plannedDuration == null ? SessionType.open : SessionType.timed,
        duration: plannedDuration,
      );
    }

    test('returns zero for zero and negative elapsed durations', () {
      final testSession = session(hourlyPrice: 10000);

      expect(calculateSessionCharge(testSession, Duration.zero), 0);
      expect(
        calculateSessionCharge(testSession, const Duration(microseconds: -1)),
        0,
      );
    });

    test('truncates sub-pound boundaries at 10000 SYP per hour', () {
      final testSession = session(hourlyPrice: 10000);
      final cases = <(Duration, int)>[
        (Duration.zero, 0),
        (const Duration(microseconds: 1), 0),
        (const Duration(microseconds: 180), 0),
        (const Duration(microseconds: 359), 0),
        (const Duration(microseconds: 360), 0),
        (const Duration(milliseconds: 359), 0),
        (const Duration(milliseconds: 360), 1),
        (const Duration(seconds: 1), 2),
      ];

      for (final (duration, expectedCharge) in cases) {
        expect(
          calculateSessionCharge(testSession, duration),
          expectedCharge,
          reason: duration.toString(),
        );
      }
    });

    test('uses actual elapsed time without a minimum or duration rounding', () {
      final testSession = session(hourlyPrice: 10000);
      final cases = <Duration, int>{
        const Duration(minutes: 30): 5000,
        const Duration(hours: 1): 10000,
      };

      for (final entry in cases.entries) {
        expect(
          calculateSessionCharge(testSession, entry.key),
          entry.value,
          reason: entry.key.toString(),
        );
      }
    });

    test('discards every fractional pound at 3600 SYP per hour', () {
      final testSession = session(hourlyPrice: 3600);
      final cases = <Duration, int>{
        const Duration(seconds: 240, milliseconds: 200): 240,
        const Duration(seconds: 240, milliseconds: 500): 240,
        const Duration(seconds: 240, milliseconds: 900): 240,
        const Duration(seconds: 241, milliseconds: 900): 241,
      };

      for (final entry in cases.entries) {
        expect(
          calculateSessionCharge(testSession, entry.key),
          entry.value,
          reason: entry.key.toString(),
        );
      }
    });

    test('bills supplied actual time beyond a timed session plan', () {
      final timedSession = session(
        hourlyPrice: 3600,
        plannedDuration: const Duration(minutes: 4),
      );

      expect(
        calculateSessionCharge(
          timedSession,
          const Duration(minutes: 4, seconds: 1, milliseconds: 900),
        ),
        241,
      );
    });
  });

  group('createCompletedSession', () {
    final startTime = DateTime.utc(2026, 10, 13, 12);

    SessionModel session() {
      return SessionModel(
        playstationId: 1,
        playersCount: 3,
        hourlyPrice: 12000,
        startTime: startTime,
        type: SessionType.open,
        duration: null,
      );
    }

    test(
      'preserves the session snapshot, amounts, timestamps, and trimmed reason',
      () {
        final testSession = session();
        final endTime = startTime.add(const Duration(minutes: 30));
        final trimmedReason = '  خصم للزبون  '.trim();

        final completedSession = createCompletedSession(
          session: testSession,
          endTime: endTime,
          calculatedAmount: 6000,
          collectedAmount: 5500,
          adjustmentReason: trimmedReason,
        );

        expect(completedSession.session, same(testSession));
        expect(completedSession.endTime, endTime);
        expect(completedSession.actualDuration, const Duration(minutes: 30));
        expect(completedSession.calculatedAmount, 6000);
        expect(completedSession.collectedAmount, 5500);
        expect(completedSession.adjustmentReason, 'خصم للزبون');
      },
    );

    test('keeps equal calculated and collected amounts with no reason', () {
      final completedSession = createCompletedSession(
        session: session(),
        endTime: startTime,
        calculatedAmount: 0,
        collectedAmount: 0,
      );

      expect(completedSession.calculatedAmount, 0);
      expect(completedSession.collectedAmount, 0);
      expect(completedSession.adjustmentReason, isNull);
    });

    test('preserves a normalized whitespace-only reason as absent', () {
      const rawReason = '   ';
      final trimmedReason = rawReason.trim();

      final completedSession = createCompletedSession(
        session: session(),
        endTime: startTime,
        calculatedAmount: 0,
        collectedAmount: 0,
        adjustmentReason: trimmedReason.isEmpty ? null : trimmedReason,
      );

      expect(completedSession.adjustmentReason, isNull);
    });

    test(
      'keeps a collected amount above the calculated amount independent',
      () {
        final completedSession = createCompletedSession(
          session: session(),
          endTime: startTime.add(const Duration(hours: 1)),
          calculatedAmount: 12000,
          collectedAmount: 15000,
        );

        expect(completedSession.calculatedAmount, 12000);
        expect(completedSession.collectedAmount, 15000);
      },
    );

    test('clamps elapsed time when the session starts after the end time', () {
      final completedSession = createCompletedSession(
        session: session(),
        endTime: startTime.subtract(const Duration(microseconds: 1)),
        calculatedAmount: 0,
        collectedAmount: 0,
      );

      expect(completedSession.actualDuration, Duration.zero);
    });
  });
}
