# RoutePilot

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%5E3.0.0-blue.svg)](https://flutter.dev/)
[![Pub Version](https://img.shields.io/pub/v/route_pilot)](https://pub.dev/packages/route_pilot)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20MacOS%20%7C%20Windows%20%7C%20Linux-green)

**RoutePilot** is a lightweight yet powerful routing and navigation package for Flutter. It provides a clean, singleton-based API for page navigation, custom transitions, async middleware guards, deep linking with web URL sync, typed routes, route groups, overlay management, and URL launching — all without code generation.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
  - [Option A: Navigator 2.0 (Router API)](#option-a-navigator-20-router-api---recommended)
  - [Option B: Navigator 1.0 (Classic)](#option-b-navigator-10-classic)
- [Navigation](#navigation)
  - [Push & Pop](#push--pop)
  - [Replace & Clear Stack](#replace--clear-stack)
  - [Pop Until](#pop-until)
  - [Direct Widget Navigation](#direct-widget-navigation)
- [Custom Transitions](#custom-transitions)
- [Passing Arguments](#passing-arguments)
  - [Map Arguments](#map-arguments)
  - [Typed Object Arguments](#typed-object-arguments)
- [Path & Query Parameters](#path--query-parameters)
- [Typed Routes](#typed-routes)
- [Async Middleware](#async-middleware)
- [Route Groups](#route-groups)
- [Unknown Route Handling (404)](#unknown-route-handling-404)
- [Overlays & UI Helpers](#overlays--ui-helpers)
  - [Dialogs](#dialogs)
  - [Bottom Sheets](#bottom-sheets)
  - [SnackBars](#snackbars)
  - [Loading Overlay](#loading-overlay)
- [Route Observer](#route-observer)
- [URL Launching](#url-launching)
- [System Intents](#system-intents)
- [Platform Configuration](#platform-configuration)
  - [Android](#android)
  - [iOS](#ios)
- [Full API Reference](#full-api-reference)
- [Example](#example)
- [License](#license)

---

## Features

| Category          | Capabilities                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------ |
| **Navigation**    | Push, pop, replace, clear stack, pop-until by name or predicate                                  |
| **Transitions**   | 9 built-in transitions (fade, slide, scale, rotate, size, iOS Cupertino) with custom curves      |
| **Deep Linking**  | Navigator 2.0 Router API with automatic browser URL sync                                        |
| **Middleware**    | Async middleware guards with `FutureOr<String?>` redirect — supports auth checks, loading states |
| **Typed Routes**  | `PilotRoute<TArgs, TReturn>` for compile-safe navigation with path & query params               |
| **Route Groups**  | Shared prefix, middleware, and transition via `PilotRouteGroup`                                  |
| **Arguments**     | Pass `Map`, custom objects, or any type between routes                                           |
| **Path Params**   | Dynamic segments (`:id`) and query parameters parsed automatically                              |
| **404 Fallback**  | Built-in unknown route handling with `notFoundPage`                                              |
| **Overlays**      | Dialogs, bottom sheets, snackbars, and loading overlays — all without `BuildContext`             |
| **URL Launcher**  | Open browser, in-app browser, WebView, phone calls, SMS, and email                               |
| **Observer**      | Built-in `PilotObserver` tracks the full route stack with lifecycle callbacks                    |

---

## Installation

Add `route_pilot` to your `pubspec.yaml`:

```yaml
dependencies:
  route_pilot: ^0.1.0
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

Import the package:

```dart
import 'package:route_pilot/route_pilot.dart';
```

RoutePilot provides a global singleton instance `routePilot` — no setup boilerplate needed.

### Option A: Navigator 2.0 (Router API) — Recommended

Best for **web apps** and apps that need **deep linking** and **browser URL synchronization**.

```dart
abstract class PilotRoutes {
  static const String Home = '/';
  static const String Profile = '/profile';
}

class PilotPages {
  static final List<dynamic> pages = [
    PilotPage(
      name: PilotRoutes.Home,
      page: (context) => const HomePage(),
      transition: Transition.ios,
    ),
    PilotPage(
      name: PilotRoutes.Profile,
      page: (context) => const ProfilePage(),
      transition: Transition.fadeIn,
    ),
  ];
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: routePilot.getRouterConfig(
        notFoundPage: PilotPage(
          name: '/404',
          page: (context) => const NotFoundPage(),
        ),
        pages: PilotPages.pages,
      ),
    );
  }
}
```

### Option B: Navigator 1.0 (Classic)

Simpler setup for **mobile-only** apps.

```dart
class PilotPages {
  static PilotPage onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PilotRoutes.Home:
        return PilotPage(
          name: PilotRoutes.Home,
          page: (context) => const HomePage(),
          transition: Transition.ios,
        );
      case PilotRoutes.Profile:
        return PilotPage(
          name: PilotRoutes.Profile,
          page: (context) => const ProfilePage(),
          transition: Transition.fadeIn,
        );
      default:
        return PilotPage(
          name: 'error',
          page: (context) => const NotFoundPage(),
        );
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: routePilot.navigatorKey,
      navigatorObservers: [routePilot.observer],
      onGenerateRoute: (settings) => routePilot.onGenerateRoute(
        settings,
        pages: [PilotPages.onGenerateRoute(settings)],
      ),
      initialRoute: PilotRoutes.Home,
    );
  }
}
```

---

## Navigation

### Push & Pop

```dart
// Push a named route
routePilot.toNamed('/profile');

// Go back
routePilot.back();

// Go back with a result
routePilot.back('result_value');
```

### Replace & Clear Stack

```dart
// Replace the current route
routePilot.off('/new-page');

// Clear the entire stack and navigate (e.g., after login)
routePilot.offAll('/home');
```

### Pop Until

```dart
// Pop until a specific route
routePilot.backUntil('/home');

// Pop until a custom predicate
routePilot.backUntilPredicate((route) => route.isFirst);
```

### Direct Widget Navigation

Navigate to a widget directly without a named route:

```dart
routePilot.to(
  const ProfilePage(),
  transition: Transition.scale,
  transitionDuration: const Duration(milliseconds: 500),
  curve: Curves.easeInOut,
);
```

---

## Custom Transitions

RoutePilot supports **9 built-in transitions** on every `PilotPage`:

| Transition              | Description                               |
| ----------------------- | ----------------------------------------- |
| `Transition.fadeIn`     | Fade in                                   |
| `Transition.rightToLeft`| Slide from right to left                  |
| `Transition.leftToRight`| Slide from left to right                  |
| `Transition.topToBottom`| Slide from top to bottom                  |
| `Transition.bottomToTop`| Slide from bottom to top                  |
| `Transition.scale`      | Scale up from center                      |
| `Transition.rotate`     | Rotation transition                       |
| `Transition.size`       | Size expansion transition                 |
| `Transition.ios`        | Native iOS Cupertino swipe-back transition |

```dart
PilotPage(
  name: '/details',
  page: (context) => const DetailsPage(),
  transition: Transition.bottomToTop,
  transitionDuration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  fullscreenDialog: true,
)
```

---

## Passing Arguments

### Map Arguments

```dart
// Send
routePilot.toNamed(PilotRoutes.Second, arguments: {
  'name': 'John Doe',
  'age': 25,
});

// Receive in your widget using RoutePilot
final name = routePilot.arg<String>('name');  // 'John Doe'
final age = routePilot.arg<int>('age');        // 25
```

### Typed Object Arguments

Pass any Dart object — no serialization required:

```dart
class PersonData {
  final int id;
  final String title;
  PersonData({required this.id, required this.title});
}

// Send a typed object directly
routePilot.toNamed(PilotRoutes.Second, arguments: PersonData(id: 1, title: 'Dev'));

// Receive the object
final person = routePilot.getArguments<PersonData>();
```

You can also pass objects inside a map:

```dart
// Send object inside map
routePilot.toNamed(PilotRoutes.Second, arguments: {
  'name': 'John',
  'personData': PersonData(id: 1, title: 'Dev'),
});

// Receive specific object from map
final person = routePilot.arg<PersonData>('personData');
```

Access the raw arguments directly:

```dart
final rawArgs = routePilot.args; // dynamic
```

### Displaying Extracted Arguments in UI

Here's an example of how you can extract and display the arguments cleanly inside a `StatelessWidget`:

```dart
class SecondPage extends StatelessWidget {
  // Option 1: Pass arguments via constructor from PilotPages generator
  final String name;
  final int age;
  final PersonData personData;

  const SecondPage({
    super.key,
    required this.name,
    required this.age,
    required this.personData,
  });

  @override
  Widget build(BuildContext context) {
    // Option 2: Alternatively, retrieve them directly inside build()
    // final directName = routePilot.arg<String>('name');

    return Scaffold(
      appBar: AppBar(title: const Text('Second Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Name Passed: $name', style: const TextStyle(fontSize: 22)),
            Text('Age Passed: $age', style: const TextStyle(fontSize: 22)),
            const Divider(),
            Text('PersonData ID: ${personData.id}'),
            Text('PersonData Title: ${personData.title}'),
          ],
        ),
      ),
    );
  }
}
```

---

## Path & Query Parameters

Define dynamic path segments using `:param` syntax:

```dart
PilotPage(
  name: '/user/:id',
  page: (context) => const UserPage(),
)
```

Navigate and read parameters:

```dart
// Navigate to /user/42?tab=settings
routePilot.toNamed('/user/42?tab=settings');

// Read parameters
final id = routePilot.param('id');     // '42'
final tab = routePilot.param('tab');   // 'settings'
```

---

## Typed Routes

Use `PilotRoute<TArgs, TReturn>` for type-safe navigation with automatic path/query param substitution:

```dart
// Define
final userRoute = PilotRoute<PersonData, bool>('/user/:id');

// Navigate
final result = await userRoute.push(
  arguments: PersonData(id: 42, title: 'Eldho'),
  pathParams: {'id': '42'},
  queryParams: {'tab': 'settings'},
);
// Navigates to: /user/42?tab=settings
```

---

## Async Middleware

Create guards that run asynchronously before a route is displayed. Return a route string to redirect, or `null` to allow navigation.

```dart
class AuthGuard extends PilotMiddleware {
  @override
  FutureOr<String?> redirect(String? route) async {
    final isLoggedIn = await checkAuthToken();
    if (!isLoggedIn) return '/login'; // Redirect
    return null; // Allow
  }
}
```

Attach middleware to individual pages:

```dart
PilotPage(
  name: '/dashboard',
  page: (context) => const DashboardPage(),
  middlewares: [AuthGuard()],
)
```

Display a custom loading widget while async middlewares resolve:

```dart
routePilot.middlewareLoadingWidget = const Center(
  child: CircularProgressIndicator(),
);
```

---

## Route Groups

Group routes that share a common prefix, middleware, or transition:

```dart
PilotRouteGroup(
  prefix: '/dashboard',
  middlewares: [AuthGuard()],
  transition: Transition.fadeIn,
  transitionDuration: const Duration(milliseconds: 300),
  children: [
    PilotPage(name: '/home', page: (context) => const DashboardHome()),
    PilotPage(name: '/settings', page: (context) => const SettingsPage()),
    // Resolves to: /dashboard/home, /dashboard/settings
  ],
)
```

Route groups can be **nested** — prefixes, middlewares, and transitions cascade automatically.

---

## Unknown Route Handling (404)

Provide a `notFoundPage` to handle any unmatched routes:

```dart
routePilot.getRouterConfig(
  notFoundPage: PilotPage(
    name: '/404',
    page: (context) => const NotFoundPage(),
  ),
  pages: [ /* ... */ ],
)
```

---

## Overlays & UI Helpers

All overlay APIs work without requiring a `BuildContext` — just call them from anywhere.

### Dialogs

```dart
final result = await routePilot.dialog(
  AlertDialog(
    title: const Text('Confirm'),
    content: const Text('Are you sure?'),
    actions: [
      TextButton(onPressed: () => routePilot.back(false), child: const Text('No')),
      TextButton(onPressed: () => routePilot.back(true), child: const Text('Yes')),
    ],
  ),
  barrierDismissible: false,
);
```

### Bottom Sheets

```dart
routePilot.bottomSheet(
  const MyBottomSheetWidget(),
  isScrollControlled: true,
  isDismissible: true,
);
```

### SnackBars

Queue-safe — automatically clears previous snackbars before showing a new one:

```dart
routePilot.snackBar(
  'Item saved successfully!',
  duration: const Duration(seconds: 3),
  backgroundColor: Colors.green,
);
```

### Loading Overlay

A non-dismissible, full-screen loading overlay:

```dart
// Show
routePilot.showLoading();
// Or with a custom indicator
routePilot.showLoading(indicator: const MyCustomSpinner());

// Hide
routePilot.hideLoading();
```

---

## Route Observer

RoutePilot includes a built-in `PilotObserver` that tracks the full navigation stack:

```dart
// Get the current route name
final current = routePilot.currentRoute;  // e.g., '/profile'

// Get the previous route name
final previous = routePilot.previousRoute;  // e.g., '/'

// Access the full route stack
final stack = routePilot.observer.routeStack;
```

Wire it into your app (automatically done with Router API):

```dart
MaterialApp(
  navigatorObservers: [routePilot.observer],
  // ...
);
```

---

## URL Launching

```dart
// Open in default browser
await routePilot.launchInBrowser(Uri.parse('https://flutter.dev'));

// Open in in-app browser
await routePilot.launchInAppBrowser(Uri.parse('https://dart.dev'));

// Open in embedded WebView
await routePilot.launchInAppWebView(Uri.parse('https://pub.dev'));

// WebView with custom headers
await routePilot.launchInAppWithCustomHeaders(
  Uri.parse('https://api.example.com'),
  {'Authorization': 'Bearer token123'},
);

// WebView without JavaScript
await routePilot.launchInAppWithoutJavaScript(Uri.parse('https://example.com'));

// WebView without DOM Storage
await routePilot.launchInAppWithoutDomStorage(Uri.parse('https://example.com'));

// iOS Universal Link (falls back to in-app browser)
await routePilot.launchUniversalLinkIOS(Uri.parse('https://example.com'));
```

---

## System Intents

```dart
// Make a phone call
await routePilot.makePhoneCall('+1-234-567-8900');

// Send an SMS
await routePilot.sendSms('+1-234-567-8900', body: 'Hello from Flutter!');

// Send an email
await routePilot.sendEmail(
  'hello@example.com',
  subject: 'Greetings',
  body: 'Sent via RoutePilot!',
);
```

---

## Platform Configuration

### Android

**1. Predictive Back Gesture (Android 13+)**

Enable predictive back navigation in `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    ...
    android:enableOnBackInvokedCallback="true">
```

**2. URL Launcher Queries**

Add schemes your app queries to `AndroidManifest.xml`:

```xml
<queries>
  <!-- SMS -->
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="sms" />
  </intent>
  <!-- Phone -->
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="tel" />
  </intent>
  <!-- In-App Browser (Chrome Custom Tabs) -->
  <intent>
    <action android:name="android.support.customtabs.action.CustomTabsService" />
  </intent>
</queries>
```

### iOS

Add queried URL schemes to `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>sms</string>
  <string>tel</string>
</array>
```

---

## Full API Reference

### `RoutePilot` (singleton via `routePilot`)

| Method / Property                                   | Description                                           |
| --------------------------------------------------- | ----------------------------------------------------- |
| `navigatorKey`                                      | Global `GlobalKey<NavigatorState>`                     |
| `observer`                                          | Built-in `PilotObserver` for route tracking            |
| `currentRoute`                                      | Current route name from the stack                      |
| `previousRoute`                                     | Previous route name from the stack                     |
| `middlewareLoadingWidget`                            | Widget shown while async middlewares resolve           |
| `getRouterConfig({pages, notFoundPage})`            | Creates `RouterConfig` for `MaterialApp.router`        |
| `onGenerateRoute(settings, {pages, notFoundPage})`  | Route generator for classic `MaterialApp`              |
| `to(Widget, {arguments, transition, ...})`          | Push a widget directly                                 |
| `toNamed(String, {arguments})`                      | Push a named route                                     |
| `back([result])`                                    | Pop the current route                                  |
| `backUntil(String)`                                 | Pop until a named route                                |
| `backUntilPredicate(RoutePredicate)`                | Pop until predicate returns true                       |
| `off(String, {arguments})`                          | Replace current route                                  |
| `offAll(String, {arguments})`                       | Clear stack and push                                   |
| `dialog(Widget, {barrierDismissible})`              | Show a dialog                                          |
| `bottomSheet(Widget, {isScrollControlled, ...})`    | Show a modal bottom sheet                              |
| `snackBar(String, {duration, backgroundColor})`     | Show a queue-safe snackbar                             |
| `showLoading({indicator})`                          | Show non-dismissible loading overlay                   |
| `hideLoading()`                                     | Dismiss loading overlay                                |
| `args`                                              | Raw dynamic arguments                                  |
| `arg<T>(String key)`                                | Get a typed value from map arguments                   |
| `getArguments<T>()`                                 | Get the full arguments cast to type `T`                |
| `param(String key)`                                 | Get a path or query parameter                          |
| `launchInBrowser(Uri)`                              | Open URL in external browser                           |
| `launchInAppBrowser(Uri)`                           | Open URL in in-app browser                             |
| `launchInAppWebView(Uri)`                           | Open URL in embedded WebView                           |
| `launchInAppWithCustomHeaders(Uri, Map)`            | WebView with custom headers                            |
| `launchInAppWithoutJavaScript(Uri)`                 | WebView without JavaScript                             |
| `launchInAppWithoutDomStorage(Uri)`                 | WebView without DOM storage                            |
| `launchUniversalLinkIOS(Uri)`                       | iOS Universal Link with fallback                       |
| `makePhoneCall(String)`                             | Initiate a phone call                                  |
| `sendSms(String, {body})`                           | Send an SMS                                            |
| `sendEmail(String, {subject, body})`                | Compose an email                                       |

### `PilotPage<T>`

| Property              | Type                    | Description                                  |
| ---------------------- | ----------------------- | -------------------------------------------- |
| `name`                | `String`                | Route name / path                            |
| `page`                | `PilotPageBuilder`      | Widget builder `(BuildContext) → Widget`     |
| `transition`          | `Transition?`           | Transition animation type                    |
| `transitionDuration`  | `Duration?`             | Animation duration (default: 300ms)          |
| `curve`               | `Curve`                 | Animation curve (default: `Curves.linear`)   |
| `fullscreenDialog`    | `bool`                  | Present as full-screen dialog                |
| `maintainState`       | `bool`                  | Keep state when inactive                     |
| `opaque`              | `bool`                  | Whether the route is opaque                  |
| `parameters`          | `Map<String, String>?`  | Optional route parameters                    |
| `arguments`           | `Object?`               | Optional route arguments                     |
| `middlewares`         | `List<PilotMiddleware>?`| Guards to run before building                |

### `PilotMiddleware`

| Method                            | Description                                                                        |
| --------------------------------- | ---------------------------------------------------------------------------------- |
| `FutureOr<String?> redirect(String? route)` | Return a route string to redirect, or `null` to proceed                  |

### `PilotRoute<TArgs, TReturn>`

| Method                                                        | Description                                      |
| ------------------------------------------------------------- | ------------------------------------------------ |
| `Future<TReturn?> push({arguments, pathParams, queryParams})` | Navigate with type-safe params & arguments       |

### `PilotRouteGroup`

| Property              | Type                    | Description                                  |
| ---------------------- | ----------------------- | -------------------------------------------- |
| `prefix`              | `String?`               | Prefix applied to all children               |
| `middlewares`         | `List<PilotMiddleware>?`| Shared middlewares for all children           |
| `transition`          | `Transition?`           | Shared transition for all children           |
| `transitionDuration`  | `Duration?`             | Shared transition duration                   |
| `children`            | `List<dynamic>`         | Child pages or nested groups                 |

---

## Example

Check the [example project](example/) for a full working demo showcasing:

- Navigator 2.0 Router API setup with deep linking
- Map arguments and typed object argument passing
- Path parameters and query parameters
- Typed routes with `PilotRoute`
- Async middleware auth guard with redirect
- Route groups with shared prefix & middleware
- 404 unknown route fallback
- Dialogs, bottom sheets, snackbars, and loading overlays

Run the example:

```bash
cd example
flutter run
```

---

## Contributing

Contributions are welcome! Please see the [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

Maintained by [Eldho Paulose](https://github.com/eldhopaulose).

- **GitHub:** [eldhopaulose](https://github.com/eldhopaulose)
- **Website:** [eldhopaulose.github.io](https://eldhopaulose.github.io)
- **Resizo:** [resizo.in](https://resizo.in/)

Feel free to reach out for questions, suggestions, or contributions! ⭐ If you find qRoutePilot useful, please star the repo on GitHub.
