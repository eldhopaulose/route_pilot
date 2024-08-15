# RoutePilot

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%5E3.0.0-blue.svg)](https://flutter.dev/)
[![Pub Version](https://img.shields.io/pub/v/route_pilot)](https://pub.dev/packages/route_pilot)
![Flutter Favorite](https://img.shields.io/badge/Flutter-Favorite-blue)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20MacOS%20%7C%20Windows%20%7C%20Linux-green)

**RoutePilot** is a simple yet powerful routing package for Flutter, designed to simplify navigation across your Flutter apps. It provides custom transitions, argument handling, and easy-to-use navigation functions.

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Usage](#usage)
   - [Basic Setup](#basic-setup)
   - [Defining Routes](#defining-routes)
   - [Navigating Between Pages](#navigating-between-pages)
4. [RoutePilotPage](#routepilotpage)
5. [Custom Transitions](#custom-transitions)
6. [Argument Handling](#argument-handling)
7. [Examples](#examples)
   - [Basic Navigation Example](#basic-navigation-example)
   - [Passing Arguments Example](#passing-arguments-example)
   - [Retrieving Arguments Example](#retrieving-arguments-example)
8. [Contributing](#contributing)
9. [License](#license)
10. [About the Author](#about-the-author)

## Introduction

**RoutePilot** is a Flutter package that offers a complete routing solution, enabling you to manage your navigation effortlessly. With support for custom transitions, argument handling, and a flexible API, it helps you build sophisticated navigation flows with ease.

## Installation

To install RoutePilot, add the following dependency to your `pubspec.yaml`:

```yaml
dependencies:
  route_pilot: ^1.0.0
```

## Usage

#### Basic Setup

Start by initializing the `RoutePilot` instance in your `main.dart` file:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Service Example',
      navigatorKey: routePilot.navigatorKey,
      onGenerateRoute: (settings) {
        final page = AppPages.onGenerateRoute(settings);
        return page.createRoute(context);
      },
      initialRoute: PilotRoutes.home,
    );
  }
}

```

### Defining Routes

To organize your routes and make navigation more manageable, define all route names in an abstract class called `PilotRoutes`. This allows you to reference route names throughout your application with ease and consistency.

```dart
abstract class PilotRoutes {
  static const String home = '/home';
  static const String second = '/second';
  static const String third = '/third';
}
```

### Managing Route Generation with `AppPages`

The `AppPages` class centralizes the logic for generating routes in your Flutter application. By using the `onGenerateRoute` method, you can define how the app should respond to different navigation requests, including specifying the page to display and the transition to use.

Here’s an example of how to implement the `AppPages` class:

```dart
class AppPages {
  static RoutePilotPage onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PilotRoutes.Home:
        return RoutePilotPage(
          name: PilotRoutes.Home,
          page: (context) => HomeScreen(),
          transition: Transition.ios,
        );
      case PilotRoutes.Second:
        return RoutePilotPage(
          name: PilotRoutes.Second,
          page: (context) => SecondPage(),
          transition: Transition.ios,
        );
      case PilotRoutes.Third:
        return RoutePilotPage(
          name: PilotRoutes.Third,
          page: (context) => ThirdPage(),
          transition: Transition.scale,
        );
      default:
        return RoutePilotPage(
          name: 'notFound',
          page: (context) => NotFoundScreen(),
        );
    }
  }
}
```

#### Navigating Between Pages

Use `RoutePilot` to navigate between pages:

```dart
routePilot.to(SecondPage(), arguments: {'id': 1, 'name': 'John Doe'});

routePilot.toNamed('/third');

routePilot.offAll('/home');
```

## RoutePilotPage

#### Configuring RoutePilotPage: Key Parameters and Transition Effects

When creating a new `RoutePilotPage`, several parameters allow you to customize the behavior and appearance of the page transition. Below are the key parameters:

- **`PilotPageBuilder page`**:

  - The widget builder for the page. This is a required parameter and defines the content of the page to be displayed.

- **`String name`**:

  - The name of the route. This is a required parameter and is used to identify the route in the navigation stack.

- **`bool fullscreenDialog`**:

  - Whether the page should be shown as a full-screen dialog. This is an optional parameter, with a default value of `false`.

- **`Duration? transitionDuration`**:

  - The custom transition duration for the page. This is an optional parameter and can be used to override the default transition duration.

- **`Transition? transition`**:

  - The type of transition animation to use when navigating to this page. This is an optional parameter, allowing for a variety of predefined transitions such as `fadeIn`, `scale`, `ios`, etc.

- **`bool maintainState`**:

  - Whether to maintain the page's state when it is covered by another page. This is an optional parameter, with a default value of `true`.

- **`bool opaque`**:
  - Whether the page is opaque. This is an optional parameter, with a default value of `true`. When `false`, the page allows underlying content to be visible through it.

### Custom Transitions

`RoutePilot` supports a variety of custom transitions that can be applied when navigating between pages. These transitions control how the new page appears on the screen, providing a smooth and visually appealing experience.

Below are the available transitions:

- **`Transition.fadeIn`**:
  - The new page fades in from a completely transparent state to fully opaque.
- **`Transition.rightToLeft`**:

  - The new page slides in from the right side of the screen to the left, pushing the old page out of view.

- **`Transition.leftToRight`**:

  - The new page slides in from the left side of the screen to the right, pushing the old page out of view.

- **`Transition.topToBottom`**:

  - The new page slides down from the top of the screen, covering the old page.

- **`Transition.bottomToTop`**:

  - The new page slides up from the bottom of the screen, covering the old page.

- **`Transition.scale`**:

  - The new page scales up from a smaller size to its full size, creating a zoom-in effect.

- **`Transition.rotate`**:

  - The new page rotates into view, providing a spin or twist effect as it appears.

- **`Transition.size`**:

  - The new page grows or shrinks in size, transitioning smoothly to its final dimensions.

- **`Transition.ios`**:
  - A Cupertino-style transition, which slides the new page in from the right with a smooth, native iOS animation. This transition is commonly used on iOS devices.

#### Example Usage

When defining a route in `AppPages`, you can specify a transition like this:

```dart
RoutePilotPage(
  name: PilotRoutes.Home,
  page: (context) => HomeScreen(),
  transition: Transition.fadeIn,  // Applying the fadeIn transition
);
```

## Argument Handling

`RoutePilot` provides straightforward methods for passing and retrieving arguments between routes, enhancing the flexibility and functionality of your navigation flows. This feature allows you to easily pass data to pages and retrieve it when needed.

### Passing Arguments

To pass arguments to a route, use the `toNamed` method. You can include a map of key-value pairs as the `arguments` parameter:

```dart
// Passing arguments
routePilot.toNamed('/second', arguments: {'id': 1, 'name': 'John Doe'});
```

### Retrieving Arguments

When you need to access arguments on the target page, `RoutePilot` provides convenient methods to retrieve them. You can access all arguments at once or fetch specific values using their keys.

#### Retrieving All Arguments

To get all arguments passed to the current route, use the `routePilot.args` property. It returns a list of maps containing the arguments:

```dart
// Retrieving all arguments
final args = routePilot.args;
```

### Retrieving a Specific Argument

To retrieve a specific argument passed to a route, use the `routePilot.arg<T>(key)` method. In this method:

- `T` is the type you expect the argument to be.
- `key` is the name of the argument you want to retrieve.

#### Example

```dart
// Retrieving a specific argument
final id = routePilot.arg<int>('id');
```

- In this example, `routePilot.arg<int>('id') `retrieves the argument associated with the key `'id'` and casts it to an `int`. Ensure that the key used matches the key used when passing the argument.

## Examples

### Basic Navigation Example

To navigate to a different page, you can use the `routePilot.toNamed` method. This method allows you to navigate to a route specified by its name.

#### Example

```dart
ElevatedButton(
  onPressed: () {
    routePilot.toNamed(PilotRoutes.second);
  },
  child: Text('Go to Second Page'),
);
```

- In this example, pressing the `ElevatedButton` triggers navigation to the route named `PilotRoutes.Second`, which corresponds to the Second Page. This approach simplifies navigation by using route names defined in your `PilotRoutes` class.

#### Passing Arguments Example:

```dart
routePilot.to(SecondPage(), arguments: {'id': 1, 'name': 'John Doe'});
```

#### Retrieving Arguments Example:

```dart

final args = routePilot.args;
final id = routePilot.arg<int>('id');
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## About the Author

This project is maintained by [Eldho Paulose](https://github.com/eldhopaulose).

- **GitHub:** [eldhopaulose](https://github.com/eldhopaulose)
- **Website:** [Eldho Paulose](https://eldhopaulose.info)

Feel free to reach out for any questions or suggestions regarding this project!
