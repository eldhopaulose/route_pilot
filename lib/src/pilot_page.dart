import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

typedef PilotPageBuilder = Widget Function(BuildContext context);

class PilotPage<T> extends Page<T> {
  final PilotPageBuilder page;
  final String name;
  final bool fullscreenDialog;
  final Duration? transitionDuration;
  final Transition? transition;
  final bool maintainState;
  final bool opaque;
  final Map<String, String>? parameters;
  final Object? arguments;

  PilotPage({
    required this.name,
    required this.page,
    this.fullscreenDialog = false,
    this.transitionDuration,
    this.transition,
    this.maintainState = true,
    this.opaque = true,
    this.parameters,
    this.arguments,
  }) : super(
          key: ValueKey(name),
          name: name,
          arguments: arguments,
        );

  @override
  Route<T> createRoute(BuildContext context) {
    if (transition == Transition.ios) {
      return CupertinoPageRoute<T>(
        builder: (context) => page(context),
        settings: this,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
      );
    }
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page(context),
      settings: this,
      transitionDuration:
          transitionDuration ?? const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transition) {
          case Transition.fadeIn:
            return FadeTransition(opacity: animation, child: child);
          case Transition.rightToLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case Transition.leftToRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case Transition.topToBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case Transition.bottomToTop:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case Transition.scale:
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          case Transition.rotate:
            return RotationTransition(
              turns: animation,
              child: child,
            );
          case Transition.size:
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );
          case Transition.ios:
            // This case is handled above with CupertinoPageRoute
            return child;
          default:
            return child;
        }
      },
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      opaque: opaque,
    );
  }
}

enum Transition {
  fadeIn,
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
  scale,
  rotate,
  size,
  ios,
}
