import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playstation_hall_manager/main.dart';

void main() {
  testWidgets('renders the initial PlayStation hall state', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PlayStationApp());

    expect(find.text('إدارة صالة البلايستيشن'), findsOneWidget);
    expect(find.text('PlayStation 1'), findsOneWidget);
    expect(find.text('PlayStation 2'), findsOneWidget);
    expect(find.text('PlayStation 3'), findsOneWidget);
    expect(find.text('PlayStation 4'), findsOneWidget);
    expect(find.text('متاح للعب'), findsNWidgets(3));
    expect(find.text('مشغول'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
