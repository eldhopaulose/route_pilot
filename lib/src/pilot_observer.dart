import 'package:flutter/widgets.dart';

/// A NavigatorObserver that tracks the route stack for RoutePilot.
class PilotObserver extends NavigatorObserver {
  /// The current stack of routes navigated by the application.
  final List<Route<dynamic>> routeStack = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      final index = routeStack.indexOf(oldRoute);
      if (index != -1) {
        if (newRoute != null) {
          routeStack[index] = newRoute;
        } else {
          routeStack.removeAt(index);
        }
      }
    }
  }
}
