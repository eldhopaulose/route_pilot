import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:route_pilot_example/main.dart';

void main() {
  testWidgets('Route Pilot advanced example app navigation test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('RoutePilot Advanced Example'), findsOneWidget);

    // Tap Direct Constructor
    await tester.tap(find.text('Go to Second Page (Direct Constructor)'));
    await tester.pumpAndSettle();

    expect(find.text('Name Passed: Eldho (Direct)'), findsOneWidget);

    // Go Back
    await tester.tap(find.text('Go Back'));
    await tester.pumpAndSettle();

    expect(find.text('RoutePilot Advanced Example'), findsOneWidget);
  });
}
