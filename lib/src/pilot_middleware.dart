/// An abstract class representing a middleware in the routing process.
/// Middlewares are executed sequentially before a route is pushed.
abstract class PilotMiddleware {
  /// Called before the route is built.
  /// Return a new route string (e.g., '/login') to redirect,
  /// or return null to allow the original navigation to proceed.
  String? redirect(String? route);
}
