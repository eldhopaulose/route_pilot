import 'package:flutter/material.dart';

class RoutePilot {
  static final RoutePilot _instance = RoutePilot._internal();
  factory RoutePilot() => _instance;
  RoutePilot._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  dynamic _arguments;

  Future<dynamic> to(Widget page, {dynamic arguments}) {
    if (arguments is Map<String, dynamic>) {
      _arguments = [arguments];
    } else if (arguments is List<Map<String, dynamic>>) {
      _arguments = arguments;
    } else {
      _arguments = null;
    }
    return navigatorKey.currentState!
        .push(MaterialPageRoute(builder: (_) => page));
  }

  Future<dynamic> toNamed(String routeName, {dynamic arguments}) {
    if (arguments is Map<String, dynamic>) {
      _arguments = [arguments];
    } else if (arguments is List<Map<String, dynamic>>) {
      _arguments = arguments;
    } else {
      _arguments = null;
    }
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  void back() {
    _arguments = null;
    navigatorKey.currentState!.pop();
  }

  Future<dynamic> offAll(String routeName, {dynamic arguments}) {
    if (arguments is Map<String, dynamic>) {
      _arguments = [arguments];
    } else if (arguments is List<Map<String, dynamic>>) {
      _arguments = arguments;
    } else {
      _arguments = null;
    }
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  Future<dynamic> off(String routeName, {dynamic arguments}) {
    if (arguments is Map<String, dynamic>) {
      _arguments = [arguments];
    } else if (arguments is List<Map<String, dynamic>>) {
      _arguments = arguments;
    } else {
      _arguments = null;
    }
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  List<Map<String, dynamic>>? get args {
    return _arguments as List<Map<String, dynamic>>?;
  }

  T? arg<T>(String key, {int index = 0}) {
    if (_arguments is List && _arguments.length > index) {
      final map = _arguments[index];
      if (map is Map<String, dynamic> && map.containsKey(key)) {
        return map[key] as T?;
      }
    }
    return null;
  }

  Map<String, dynamic>? argsAt(int index) {
    if (_arguments is List && _arguments.length > index) {
      return _arguments[index] as Map<String, dynamic>?;
    }
    return null;
  }
}

final RoutePilot routePilot = RoutePilot();
