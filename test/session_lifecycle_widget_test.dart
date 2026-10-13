import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playstation_hall_manager/main.dart';

const _durationValidationMessage =
    'أدخل مدة صحيحة أكبر من صفر، والدقائق بين 0 و59';
const _collectionValidationMessage = 'أدخل مبلغاً صحيحاً لا يقل عن صفر';

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

  group('session collection lifecycle', () {
    testWidgets(
      'opens completion with actual-time truncated charge and default collection',
      (tester) async {
        final clock = await _pumpHall(tester);
        await _startOpenSession(
          tester,
          clock,
          elapsed: const Duration(seconds: 1),
        );

        await _openEndDialog(tester, clock);

        final dialog = find.byType(AlertDialog);
        expect(find.text('إنهاء جلسة - PlayStation 1'), findsOneWidget);
        expect(find.text('المدة الفعلية: 00:00:01'), findsOneWidget);
        expect(find.text('المبلغ المحسوب تلقائياً'), findsOneWidget);
        expect(
          find.descendant(of: dialog, matching: find.text('2 ل.س')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: dialog,
            matching: find.textContaining(RegExp(r'\d+[\.,]\d+')),
          ),
          findsNothing,
        );
        expect(_fieldText(tester, _collectionField()), '2');
        expect(
          find.text('المبلغ المعتمد مطابق للحساب التلقائي.'),
          findsOneWidget,
        );
      },
    );

    final invalidCollections = <({String name, String value})>[
      (name: 'empty collection', value: ''),
      (name: 'negative collection', value: '-1'),
      (name: 'non-integer collection', value: '1.5'),
      (name: 'nonnumeric collection', value: 'abc'),
    ];

    for (final invalidCollection in invalidCollections) {
      testWidgets('rejects ${invalidCollection.name}', (tester) async {
        final clock = await _pumpHall(tester);
        await _startOpenSession(
          tester,
          clock,
          elapsed: const Duration(seconds: 1),
        );
        await _openEndDialog(tester, clock);

        await tester.enterText(_collectionField(), invalidCollection.value);
        await tester.pump();

        expect(find.text(_collectionValidationMessage), findsOneWidget);
        expect(
          tester
              .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'تأكيد الإنهاء'),
              )
              .onPressed,
          isNull,
        );
        expect(find.text('إنهاء جلسة - PlayStation 1'), findsOneWidget);
        expect(
          find.descendant(
            of: _playstationTile('PlayStation 1'),
            matching: find.text('مشغول'),
          ),
          findsOneWidget,
        );
      });
    }

    final acceptedCollections = <({String name, String value})>[
      (name: 'zero', value: '0'),
      (name: 'lower amount', value: '1'),
      (name: 'higher amount', value: '3'),
    ];

    for (final acceptedCollection in acceptedCollections) {
      testWidgets('accepts ${acceptedCollection.name}', (tester) async {
        final clock = await _pumpHall(tester);
        await _startOpenSession(
          tester,
          clock,
          elapsed: const Duration(seconds: 1),
        );
        await _openEndDialog(tester, clock);

        await tester.enterText(_collectionField(), acceptedCollection.value);
        await tester.pump();

        expect(find.text(_collectionValidationMessage), findsNothing);
        expect(
          find.text('تم تعديل المبلغ عن الحساب التلقائي.'),
          findsOneWidget,
        );

        await _confirmEnd(tester);
        _expectAvailable(tester);
      });
    }

    testWidgets('keeps the adjustment reason optional', (tester) async {
      final clock = await _pumpHall(tester);
      await _startOpenSession(tester, clock);
      await _openEndDialog(tester, clock);

      expect(_fieldText(tester, _reasonField()), isEmpty);

      await _confirmEnd(tester);
      _expectAvailable(tester);
    });

    testWidgets('accepts and trims a reason with surrounding whitespace', (
      tester,
    ) async {
      final clock = await _pumpHall(tester);
      await _startOpenSession(tester, clock);
      await _openEndDialog(tester, clock);

      await tester.enterText(_reasonField(), '  خصم للزبون  ');
      await _confirmEnd(tester);

      _expectAvailable(tester);
    });

    testWidgets('treats a whitespace-only reason as absent', (tester) async {
      final clock = await _pumpHall(tester);
      await _startOpenSession(tester, clock);
      await _openEndDialog(tester, clock);

      await tester.enterText(_reasonField(), '   ');
      await _confirmEnd(tester);

      _expectAvailable(tester);
    });

    testWidgets('cancels completion without ending the session', (
      tester,
    ) async {
      final clock = await _pumpHall(tester);
      await _startOpenSession(tester, clock);
      await _openEndDialog(tester, clock);

      await tester.tap(find.widgetWithText(TextButton, 'رجوع'));
      await tester.pumpAndSettle();

      expect(find.text('إنهاء جلسة - PlayStation 1'), findsNothing);
      expect(find.text('إنهاء الجلسة'), findsOneWidget);
      expect(
        find.descendant(
          of: _playstationTile('PlayStation 1'),
          matching: find.text('مشغول'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('completes manually and restores availability', (tester) async {
      final clock = await _pumpHall(tester);
      await _startOpenSession(tester, clock);
      await _openEndDialog(tester, clock);

      await _confirmEnd(tester);

      expect(find.text('إنهاء الجلسة'), findsNothing);
      _expectAvailable(tester);
    });
  });
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

Future<void> _startOpenSession(
  WidgetTester tester,
  _TestClock clock, {
  Duration elapsed = Duration.zero,
}) async {
  await _openStartDialog(tester, clock, 'PlayStation 1');
  await tester.tap(find.text('وقت مفتوح'));
  await tester.pump();
  await tester.tap(find.widgetWithText(ElevatedButton, 'فتح جلسة'));
  await tester.pump();
  await _pumpFor(tester, clock, elapsed);
}

Future<void> _openEndDialog(WidgetTester tester, _TestClock clock) async {
  await tester.tap(find.widgetWithText(OutlinedButton, 'إنهاء الجلسة'));
  await tester.pump();
  await _pumpFor(tester, clock, const Duration(milliseconds: 300));
}

Future<void> _confirmEnd(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'تأكيد الإنهاء'));
  await tester.pumpAndSettle();
}

Finder _playstationTile(String name) {
  return find.ancestor(of: find.text(name), matching: find.byType(ListTile));
}

Finder _durationField(String label) {
  return find.widgetWithText(TextFormField, label);
}

Finder _collectionField() {
  return find.widgetWithText(TextFormField, 'المبلغ المقبوض فعلياً');
}

Finder _reasonField() {
  return find.widgetWithText(TextFormField, 'سبب التعديل (اختياري)');
}

String _fieldText(WidgetTester tester, Finder field) {
  return tester
      .widget<EditableText>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      )
      .controller
      .text;
}

void _expectAvailable(WidgetTester tester) {
  expect(
    find.descendant(
      of: _playstationTile('PlayStation 1'),
      matching: find.text('متاح للعب'),
    ),
    findsOneWidget,
  );
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
