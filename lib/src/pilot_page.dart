import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// A typedef for a function that builds a widget given a BuildContext.
/// This is used to create the content of a PilotPage.
typedef PilotPageBuilder = Widget Function(BuildContext context);

/// PilotPage is a custom implementation of the Page class that provides
/// more control over page transitions and properties.
class PilotPage<T> extends Page<T> {
  /// The function that builds the content of the page.
  final PilotPageBuilder page;

  /// The name of the route, used for identification.
  final String name;

  /// Whether the route is a full-screen dialog.
  final bool fullscreenDialog;

  /// The duration of the transition animation.
  final Duration? transitionDuration;

  /// The type of transition animation to use.
  final Transition? transition;

  /// Whether to maintain the state of the route when it's inactive.
  final bool maintainState;

  /// Whether the route is opaque. This is used to determine whether the previous route should be built or not.
  final bool opaque;

  /// Optional parameters to pass to the route.
  final Map<String, String>? parameters;

  /// Optional arguments to pass to the route.
  final Object? arguments;

  /// Constructor for PilotPage.
  ///
  /// [name] is required and used as the route's name and key.
  /// [page] is required and is the builder function for the page's content.
  /// [fullscreenDialog] determines if the page is presented as a full-screen dialog.
  /// [transitionDuration] sets the duration of the transition animation.
  /// [transition] specifies the type of transition animation.
  /// [maintainState] determines if the route's state is maintained when inactive.
  /// [opaque] determines if the route is opaque.
  /// [parameters] are optional parameters passed to the route.
  /// [arguments] are optional arguments passed to the route.
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
    // If the transition is set to iOS, use CupertinoPageRoute
    if (transition == Transition.ios) {
      return CupertinoPageRoute<T>(
        builder: (context) => page(context),
        settings: this,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
      );
    }

    // For all other transitions, use PageRouteBuilder
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page(context),
      settings: this,
      transitionDuration:
          transitionDuration ?? const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Apply the specified transition effect
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

/// Enum defining the types of transitions available for PilotPage.
enum Transition {
  /// Fade in transition
  fadeIn,

  /// Slide from right to left
  rightToLeft,

  /// Slide from left to right
  leftToRight,

  /// Slide from top to bottom
  topToBottom,

  /// Slide from bottom to top
  bottomToTop,

  /// Scale transition
  scale,

  /// Rotate transition
  rotate,

  /// Size transition
  size,

  /// iOS-style transition (uses CupertinoPageRoute)
  ios,
}
