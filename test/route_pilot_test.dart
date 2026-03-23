import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:route_pilot/route_pilot.dart';

class TestAuthMiddleware extends PilotMiddleware {
  @override
  String? redirect(String? route) {
    if (route == '/protected') return '/login';
    return null;
  }
}

void main() {
  testWidgets('RoutePilot new router engine, params, and middleware test',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      navigatorKey: routePilot.navigatorKey,
      navigatorObservers: [routePilot.observer],
      initialRoute: '/',
      onGenerateRoute: (settings) => routePilot.onGenerateRoute(
        settings,
        pages: [
          PilotPage(
              name: '/', page: (context) => const Scaffold(body: Text('Home'))),
          PilotPage(
              name: '/user/:id',
              page: (context) => Scaffold(
                  body: Text(
                      'User ${routePilot.param('id')} - ${routePilot.param('role')}',
                      key: const Key('user_text')))),
          PilotPage(
              name: '/protected',
              page: (context) => const Scaffold(body: Text('Secret')),
              middlewares: [TestAuthMiddleware()]),
          PilotPage(
              name: '/login',
              page: (context) => const Scaffold(body: Text('Login'))),
        ],
      ),
    ));

    expect(find.text('Home'), findsOneWidget);

    // Test Path and Query Params correctly routing
    routePilot.toNamed('/user/123?role=admin');
    await tester.pumpAndSettle();
    expect(find.text('User 123 - admin'), findsOneWidget);

    // Test Middleware Redirect triggered over Protected
    routePilot.toNamed('/protected');
    await tester.pumpAndSettle();
    expect(find.text('Secret'), findsNothing);
    expect(find.text('Login'), findsOneWidget);

    // Test Observer capabilities
    expect(routePilot.currentRoute, '/login');
  });
}
