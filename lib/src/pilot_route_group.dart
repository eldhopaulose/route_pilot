import 'pilot_middleware.dart';
import 'pilot_page.dart';

/// A group of routes that share common properties like prefixes,
/// middlewares, and transitions.
class PilotRouteGroup {
  /// The prefix applied to all children routes. Example: '/dashboard'
  final String? prefix;

  /// Shared middlewares applied to all children.
  final List<PilotMiddleware>? middlewares;

  /// Shared transition for all children.
  final Transition? transition;

  /// Shared transition duration for all children.
  final Duration? transitionDuration;

  /// The list of child pages or nested groups.
  final List<dynamic> children;

  PilotRouteGroup({
    this.prefix,
    this.middlewares,
    this.transition,
    this.transitionDuration,
    required this.children,
  });

  /// Flattens this group (and any nested groups) into a flat list of PilotPages.
  List<PilotPage> flatten() {
    return _flattenGroup(this, '', [], null, null);
  }

  static List<PilotPage> _flattenGroup(
    PilotRouteGroup group,
    String currentPrefix,
    List<PilotMiddleware> currentMiddlewares,
    Transition? currentTransition,
    Duration? currentDuration,
  ) {
    final List<PilotPage> result = [];
    final String newPrefix = group.prefix != null
        ? '$currentPrefix${group.prefix}'
        : currentPrefix;
    final List<PilotMiddleware> newMiddlewares = [
      ...currentMiddlewares,
      if (group.middlewares != null) ...group.middlewares!
    ];
    final Transition? newTransition = group.transition ?? currentTransition;
    final Duration? newDuration =
        group.transitionDuration ?? currentDuration;

    for (final child in group.children) {
      if (child is PilotPage) {
        String? finalName = child.name != null ? '$newPrefix${child.name}' : null;
        // Fix double slashes if any
        if (finalName != null) {
          finalName = finalName.replaceAll('//', '/');
        }

        result.add(PilotPage(
          name: finalName ?? '',
          page: child.page,
          fullscreenDialog: child.fullscreenDialog,
          transitionDuration: child.transitionDuration ?? newDuration,
          transition: child.transition ?? newTransition,
          curve: child.curve,
          maintainState: child.maintainState,
          opaque: child.opaque,
          parameters: child.parameters,
          middlewares: child.middlewares != null
              ? [...newMiddlewares, ...child.middlewares!]
              : newMiddlewares.isEmpty ? null : newMiddlewares,
          arguments: child.arguments,
        ));
      } else if (child is PilotRouteGroup) {
        result.addAll(_flattenGroup(
          child,
          newPrefix,
          newMiddlewares,
          newTransition,
          newDuration,
        ));
      }
    }
    return result;
  }
}
