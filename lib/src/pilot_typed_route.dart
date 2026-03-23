import 'route_pilot.dart';

/// A helper class for generating and pushing strongly-typed routes.
class PilotRoute<TArgs, TReturn> {
  /// The base route name (e.g., '/user/:id')
  final String path;

  const PilotRoute(this.path);

  /// Navigates to this route.
  /// Substitutes any `:key` in [path] with values from [pathParams].
  /// Appends [queryParams] to the URL.
  /// Passes strongly-typed [arguments] to the route.
  Future<TReturn?> push({
    TArgs? arguments,
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
  }) {
    String finalRoute = path;

    if (pathParams != null && pathParams.isNotEmpty) {
      pathParams.forEach((key, value) {
        finalRoute = finalRoute.replaceAll(':$key', value);
      });
    }

    if (queryParams != null && queryParams.isNotEmpty) {
      final uri = Uri.parse(finalRoute).replace(queryParameters: queryParams);
      finalRoute = uri.toString();
    }

    return routePilot.toNamed<TReturn>(finalRoute, arguments: arguments);
  }
}
