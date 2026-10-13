import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playstation_hall_manager/main.dart';

const _durationValidationMessage =
    'أدخل مدة صحيحة أكبر من صفر، والدقائق بين 0 و59';

void main() {
  group('session start lifecycle', () {
    testWidgets(
      'starts a timed session, counts down, expires, and stays active',
      (tester) async {
        final clock = await _pumpHall(tester);

        final playstationTile = _playstationTile('PlayStation 1');
        expect(
          find.descendant(
            of: playstationTile,
            matching: find.text('متاح للعب'),
          ),
          findsOneWidget,
        );

        await _openStartDialog(tester, clock, 'PlayStation 1');
        await tester.tap(find.text('3 لاعبين'));
        await tester.pump();
        await tester.enterText(_durationField('الساعات'), '0');
        await tester.enterText(_durationField('الدقائق'), '1');
        await tester.tap(find.widgetWithText(ElevatedButton, 'فتح جلسة'));
        await tester.pump();
        await _pumpFor(tester, clock, const Duration(milliseconds: 300));

        expect(find.text('فتح جلسة - PlayStation 1'), findsNothing);
        expect(
          find.descendant(of: playstationTile, matching: find.text('مشغول')),
          findsOneWidget,
        );
        expect(find.text('عدد اللاعبين: 3'), findsOneWidget);
        expect(find.text('سعر ساعة الجلسة: 15000 ل.س'), findsOneWidget);
        expect(find.text('الوقت المتبقي: 00:01:00'), findsOneWidget);

        await _pumpFor(
          tester,
          clock,
          const Duration(seconds: 4, milliseconds: 700),
        );
        expect(find.text('الوقت المتبقي: 00:00:55'), findsOneWidget);

        await _pumpFor(tester, clock, const Duration(seconds: 55));
        expect(
          find.text('انتهى الوقت — بانتظار الإنهاء أو التمديد'),
          findsOneWidget,
        );
        expect(find.text('إنهاء الجلسة'), findsOneWidget);
        expect(
          find.descendant(of: playstationTile, matching: find.text('مشغول')),
          findsOneWidget,
        );

        await tester.tap(playstationTile);
        await _pumpFor(tester, clock, const Duration(milliseconds: 300));
        expect(find.text('فتح جلسة - PlayStation 1'), findsNothing);
      },
    );

    testWidgets('starts an open session and displays elapsed time', (
      tester,
    ) async {
      final clock = await _pumpHall(tester);
      await _openStartDialog(tester, clock, 'PlayStation 1');

      await tester.tap(find.text('4 لاعبين'));
      await tester.pump();
      await tester.tap(find.text('وقت مفتوح'));
      await tester.pump();

      expect(_durationField('الساعات'), findsNothing);
      expect(_durationField('الدقائق'), findsNothing);

      await tester.tap(find.widgetWithText(ElevatedButton, 'فتح جلسة'));
      await tester.pump();
      await _pumpFor(tester, clock, const Duration(milliseconds: 300));

      final playstationTile = _playstationTile('PlayStation 1');
      expect(
        find.descendant(of: playstationTile, matching: find.text('مشغول')),
        findsOneWidget,
      );
      expect(find.text('عدد اللاعبين: 4'), findsOneWidget);
      expect(find.text('سعر ساعة الجلسة: 20000 ل.س'), findsOneWidget);
      expect(find.text('الوقت المنقضي: 00:00:00'), findsOneWidget);

      await _pumpFor(
        tester,
        clock,
        const Duration(seconds: 1, milliseconds: 700),
      );
      expect(find.text('الوقت المنقضي: 00:00:02'), findsOneWidget);
    });
  });

  final invalidDurations = <({String name, String hours, String minutes})>[
    (name: 'zero duration', hours: '0', minutes: '0'),
    (name: 'negative component', hours: '-1', minutes: '0'),
    (name: 'minutes above 59', hours: '0', minutes: '60'),
  ];

  for (final invalidDuration in invalidDurations) {
    testWidgets('rejects ${invalidDuration.name}', (tester) async {
      final clock = await _pumpHall(tester);
      await _openStartDialog(tester, clock, 'PlayStation 1');

      await tester.enterText(_durationField('الساعات'), invalidDuration.hours);
      await tester.enterText(
        _durationField('الدقائق'),
        invalidDuration.minutes,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'فتح جلسة'));
      await tester.pump();

      expect(find.text(_durationValidationMessage), findsOneWidget);
      expect(find.text('فتح جلسة - PlayStation 1'), findsOneWidget);
      expect(find.text('عدد اللاعبين: 2'), findsNothing);
      expect(
        find.descendant(
          of: _playstationTile('PlayStation 1'),
          matching: find.text('متاح للعب'),
        ),
        findsOneWidget,
      );
    });
  }
}

Future<_TestClock> _pumpHall(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  final clock = _TestClock(DateTime.utc(2026, 10, 13, 12));

  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
  });

  await tester.pumpWidget(PlayStationApp(clock: clock.now));
  return clock;
}

Future<void> _openStartDialog(
  WidgetTester tester,
  _TestClock clock,
  String playstationName,
) async {
  await tester.tap(_playstationTile(playstationName));
  await tester.pump();
  await _pumpFor(tester, clock, const Duration(milliseconds: 300));

  expect(find.text('فتح جلسة - $playstationName'), findsOneWidget);
}

Finder _playstationTile(String name) {
  return find.ancestor(of: find.text(name), matching: find.byType(ListTile));
}

Finder _durationField(String label) {
  return find.widgetWithText(TextFormField, label);
}

Future<void> _pumpFor(
  WidgetTester tester,
  _TestClock clock,
  Duration duration,
) async {
  clock.advance(duration);
  await tester.pump(duration);
}

class _TestClock {
  _TestClock(this._current);

  DateTime _current;

  DateTime now() => _current;

  void advance(Duration duration) {
    _current = _current.add(duration);
  }
}
