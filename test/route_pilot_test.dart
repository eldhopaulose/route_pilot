import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:route_pilot/route_pilot.dart';

void main() {
  testWidgets('RoutePilot basic navigation methods test', (WidgetTester tester) async {
    // Setup a MaterialApp with RoutePilot's navigatorKey
    await tester.pumpWidget(MaterialApp(
      navigatorKey: routePilot.navigatorKey,
      home: Scaffold(
        body: Center(child: Text('Home')),
      ),
    ));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Next'), findsNothing);

    // Test routePilot.to
    routePilot.to(Scaffold(
      body: Center(child: Text('Next')),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsNothing);
    expect(find.text('Next'), findsOneWidget);

    // Test routePilot.back
    routePilot.back();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });
}
