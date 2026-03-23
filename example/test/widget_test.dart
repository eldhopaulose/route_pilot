// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:route_pilot_example/main.dart';

void main() {
  testWidgets('Route Pilot example app navigation test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that we are on HomePage.
    expect(find.text('RoutePilot Example'), findsOneWidget);
    expect(find.text('Second Page'), findsNothing);

    // Tap the 'Go to Second Page' button and trigger a frame.
    await tester.tap(find.text('Go to Second Page'));
    await tester.pumpAndSettle();

    // Verify that we navigated to SecondPage.
    expect(find.text('RoutePilot Example'), findsNothing);
    expect(find.text('Second Page'), findsOneWidget);

    // Tap the 'Go Back' button and trigger a frame.
    await tester.tap(find.text('Go Back'));
    await tester.pumpAndSettle();

    // Verify that we are back on HomePage.
    expect(find.text('RoutePilot Example'), findsOneWidget);
    expect(find.text('Second Page'), findsNothing);
  });
}
