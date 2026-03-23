## 0.1.0
### Added
- **Async Middleware**: `redirect()` now returns `FutureOr<String?>`. Optional global `middlewareLoadingWidget` added.
- **Navigator 2.0 Web URL Sync**: `RoutePilot.getRouterConfig()` introduced for advanced Deep Linking and Browser URL Sync out of the box.
- **Typed Routes**: `PilotRoute<TArgs, TReturn>` class added for strongly-typed routing and execution.
- **Route Groups**: Added `PilotRouteGroup` for shared middleware, transition behavior, and path prefixes.
- **Unknown Route Fallback**: `notFoundPage` argument added to engine configuration.
- **Overlay APIs**: Added `showLoading()` and `hideLoading()`.

### Changed
- `snackBar()` now uses `clearSnackBars()` to be immediately queue-safe.
- Minor performance refactors to nested routes.


## 0.0.1

- initial release.

## 0.0.2

- README.md updated.
- CONTRIBUTING.md updated.
- Github Actions updated.

## 0.0.3

- README.md updated.
- URL launching capabilities
- System intent handling for phone calls, SMS, and email
