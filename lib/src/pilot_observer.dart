import 'package:flutter/material.dart';

/// PilotObserver tracks the route stack and lifecycle natively
class PilotObserver extends RouteObserver<PageRoute<dynamic>> {
  final List<Route<dynamic>> _routeStack = [];
  final VoidCallback? onRouteChanged;

  PilotObserver({this.onRouteChanged});

  /// A list of routes currently in the navigator stack
  List<Route<dynamic>> get routeStack => List.unmodifiable(_routeStack);

  void _notify() {
    if (onRouteChanged != null) onRouteChanged!();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      _routeStack.add(route);
      _notify();
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      _routeStack.remove(route);
      _notify();
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      _routeStack.remove(route);
      _notify();
    }
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      final index = _routeStack.indexOf(oldRoute);
      if (index != -1 && newRoute?.settings.name != null) {
        _routeStack[index] = newRoute!;
      } else if (newRoute?.settings.name != null) {
        _routeStack.add(newRoute!);
      } else {
        _routeStack.remove(oldRoute);
      }
      _notify();
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
