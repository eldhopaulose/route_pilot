import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:route_pilot/route_pilot.dart';

class AsyncTestingMiddleware extends PilotMiddleware {
  @override
  FutureOr<String?> redirect(String? route) async {
    if (route == '/admin') {
      await Future.delayed(const Duration(milliseconds: 50));
      return '/login';
    }
    return null;
  }
}

void main() {
  testWidgets('RoutePilot v2 advanced routing tests', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: routePilot.getRouterConfig(
        notFoundPage: PilotPage(name: '/404', page: (_) => const Scaffold(body: Text('404 Not Found'))),
        pages: [
          PilotPage(name: '/', page: (_) => const Scaffold(body: Text('Home'))),
          PilotRouteGroup(
            prefix: '/nested',
            middlewares: [AsyncTestingMiddleware()],
            children: [
              PilotPage(name: '/page', page: (_) => const Scaffold(body: Text('Nested Page'))),
            ],
          ),
          PilotPage(name: '/admin', page: (_) => const Scaffold(body: Text('Admin')), middlewares: [AsyncTestingMiddleware()]),
          PilotPage(name: '/login', page: (_) => const Scaffold(body: Text('Login'))),
        ],
      )
    ));

    expect(find.text('Home'), findsOneWidget);

    // Test Typed Route push (URL sync)
    final nestedRoute = PilotRoute<void, void>('/nested/page');
    nestedRoute.push();
    await tester.pumpAndSettle();
    expect(find.text('Nested Page'), findsOneWidget);

    // Async Middleware redirect test
    routePilot.toNamed('/admin');
    await tester.pumpAndSettle(); // Finish resolving and redirect
    expect(find.text('Login'), findsOneWidget);

    final handledByRouter = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handledByRouter, isTrue);
    expect(find.text('Nested Page'), findsOneWidget);

    // Pop again to go back to Home
    final handledAgain = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handledAgain, isTrue);
    expect(find.text('Home'), findsOneWidget);

    // Not Found Page test
    routePilot.toNamed('/does-not-exist');
    await tester.pumpAndSettle();
    expect(find.text('404 Not Found'), findsOneWidget);
  });
}
