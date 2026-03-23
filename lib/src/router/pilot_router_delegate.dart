import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../route_pilot.dart';
import '../pilot_page.dart';

class PilotRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final List<dynamic> pagesConfig;
  final PilotPage? notFoundPage;

  PilotRouterDelegate({
    required this.navigatorKey,
    required this.pagesConfig,
    this.notFoundPage,
  });

  /// Allows RoutePilot to manually trigger rebuilds/URL syncs (e.g., from Observer)
  void notify() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  String? get currentConfiguration => routePilot.currentRoute ?? '/';

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: [routePilot.observer],
      onGenerateRoute: (settings) => routePilot.onGenerateRoute(
        settings,
        pages: pagesConfig,
        notFoundPage: notFoundPage,
      ),
    );
  }

  @override
  Future<bool> popRoute() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return SynchronousFuture(false);
    }

    return navigator.maybePop();
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    // When the browser URL changes, push the new route
    // To prevent deep loops or redundant pushes, we might just use offAll or check currentRoute.
    if (routePilot.currentRoute != configuration) {
      routePilot.toNamed(configuration);
    }
  }
}
