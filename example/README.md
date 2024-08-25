# RoutePilot

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%5E3.0.0-blue.svg)](https://flutter.dev/)
[![Pub Version](https://img.shields.io/pub/v/route_pilot)](https://pub.dev/packages/route_pilot)
![Flutter Favorite](https://img.shields.io/badge/Flutter-Favorite-blue)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20MacOS%20%7C%20Windows%20%7C%20Linux-green)

**RoutePilot** is a powerful Flutter package that simplifies navigation and URL handling in your Flutter applications. It provides an easy-to-use interface for navigating between screens, launching URLs, and handling various system intents like making phone calls or sending emails.

## Table of Contents

1. [Features](#features)
2. [Installation](#installation)
3. [Usage](#usage)
   - [Setup](#setup)
   - [Navigation](#navigation)
   - [Passing Arguments](#passing-arguments)
   - [URL Launching](#url-launching)
   - [System Intents](#system-intents)
4. [API Reference](#api-reference)
   - [RoutePilot Class](#routepilot-class)
   - [PilotPage Class](#pilotpage-class)
   - [Transition Enum](#transition-enum)
5. [Configuration](#configuration)
   - [iOS Configuration](#ios-configuration)
   - [Android Configuration](#android-configuration)
6. [Example](#example)
7. [License](#license)

## Features

- Simple and intuitive navigation API
- Custom page transitions
- URL launching (browser, in-app browser, WebView)
- Phone call initiation
- SMS sending
- Email composition
- Argument passing between routes

## Installation

Add `route_pilot` to your `pubspec.yaml` file:

```yaml
dependencies:
  route_pilot: ^1.0.0
```

Then run:

```
flutter pub get
```

## Usage

### Setup

To use RoutePilot, set up your `MaterialApp` with the `navigatorKey` and `onGenerateRoute`:

```dart
import 'package:flutter/material.dart';
import 'package:route_pilot/route_pilot.dart';
import 'package:your_app/routes/pilot_pages.dart';
import 'package:your_app/routes/pilot_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoutePilot Demo',
      navigatorKey: routePilot.navigatorKey,
      onGenerateRoute: (settings) {
        final page = PilotPages.onGenerateRoute(settings);
        return page.createRoute(context);
      },
      initialRoute: PilotRoutes.Home,
    );
  }
}
```

Define your routes:

```dart
abstract class PilotRoutes {
  static const String Home = '/';
  static const String ScreenOne = '/screen_one';
  static const String ScreenTwo = '/screen_two';
  static const String ScreenThree = '/screen_three';
  static const String ScreenFour = '/screen_four';
}
```

Set up your `PilotPages`:

```dart
import 'package:flutter/material.dart';
import 'package:route_pilot/route_pilot.dart';
import 'package:your_app/screens/home_screen.dart';
import 'package:your_app/screens/screen_one.dart';
// Import other screens...

class PilotPages {
  static PilotPage onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PilotRoutes.Home:
        return PilotPage(
          name: PilotRoutes.Home,
          page: (context) => HomeScreen(),
          transition: Transition.ios,
        );
      case PilotRoutes.ScreenOne:
        return PilotPage(
          name: PilotRoutes.ScreenOne,
          page: (context) => ScreenOne(),
          transition: Transition.ios,
        );
      // Define other routes...
      default:
        return PilotPage(
          name: 'error',
          page: (context) => ErrorPage(),
        );
    }
  }
}
```

### Navigation

Navigate between screens:

```dart
// Navigate to a named route
routePilot.toNamed('/screen_one');

// Navigate back
routePilot.back();

// Replace the current route
routePilot.off('/screen_two');

// Remove all existing routes and navigate
routePilot.offAll('/home');
```

### Passing Arguments

Pass arguments when navigating:

```dart
routePilot.toNamed('/screen_three', arguments: {'name': 'John Doe', 'age': 25});
```

Retrieve arguments in the destination screen:

```dart
final name = routePilot.arg<String>('name');
final age = routePilot.arg<int>('age');
```

### URL Launching

Launch URLs using RoutePilot:

```dart
// Launch in default browser
routePilot.launchInBrowser(Uri.parse('https://flutter.dev'));

// Launch in in-app browser
routePilot.launchInAppBrowser(Uri.parse('https://dart.dev'));

// Launch in WebView
routePilot.launchInAppWebView(Uri.parse('https://pub.dev'));
```

### System Intents

Trigger system intents:

```dart
// Make a phone call
routePilot.makePhoneCall('123-456-7890');

// Send an SMS
routePilot.sendSms('123-456-7890', body: 'Hello from Flutter!');

// Send an email
routePilot.sendEmail(
  'example@example.com',
  subject: 'Test Email',
  body: 'This is a test email sent from a Flutter app.',
);
```

## API Reference

### RoutePilot Class

The main class for navigation and URL handling.

Methods:

- `to(Widget page, {dynamic arguments})`
- `toNamed(String routeName, {dynamic arguments})`
- `back()`
- `offAll(String routeName, {dynamic arguments})`
- `off(String routeName, {dynamic arguments})`
- `launchInBrowser(Uri url)`
- `launchInAppBrowser(Uri url)`
- `launchInAppWebView(Uri url)`
- `launchInAppWithCustomHeaders(Uri url, Map<String, String> headers)`
- `launchInAppWithoutJavaScript(Uri url)`
- `launchInAppWithoutDomStorage(Uri url)`
- `launchUniversalLinkIOS(Uri url)`
- `makePhoneCall(String phoneNumber)`
- `sendSms(String phoneNumber, {String? body})`
- `sendEmail(String email, {String? subject, String? body})`
- `canLaunchUrl(Uri url)`

### PilotPage Class

A custom implementation of the Page class for more control over transitions.

Properties:

- `page`: The function that builds the content of the page.
- `name`: The name of the route.
- `fullscreenDialog`: Whether the route is a full-screen dialog.
- `transitionDuration`: The duration of the transition animation.
- `transition`: The type of transition animation to use.
- `maintainState`: Whether to maintain the state of the route when it's inactive.
- `opaque`: Whether the route is opaque.
- `parameters`: Optional parameters to pass to the route.
- `arguments`: Optional arguments to pass to the route.

### Transition Enum

Defines the types of transitions available:

- `fadeIn`
- `rightToLeft`
- `leftToRight`
- `topToBottom`
- `bottomToTop`
- `scale`
- `rotate`
- `size`
- `ios`

## Configuration

### iOS Configuration

Add any URL schemes passed to `canLaunchUrl` as `LSApplicationQueriesSchemes` entries in your `Info.plist` file:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>sms</string>
  <string>tel</string>
</array>
```

### Android Configuration

Add any URL schemes passed to `canLaunchUrl` as `<queries>` entries in your `AndroidManifest.xml`:

```xml
<queries>
  <!-- If your app checks for SMS support -->
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="sms" />
  </intent>
  <!-- If your app checks for call support -->
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="tel" />
  </intent>
  <!-- If your application checks for inAppBrowserView launch mode support -->
  <intent>
    <action android:name="android.support.customtabs.action.CustomTabsService" />
  </intent>
</queries>
```

## Example

Here's a simple example of how to use RoutePilot in a Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:route_pilot/route_pilot.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: routePilot.navigatorKey,
      onGenerateRoute: (settings) {
        final page = PilotPages.onGenerateRoute(settings);
        return page.createRoute(context);
      },
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RoutePilot Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Go to ScreenOne'),
              onPressed: () => routePilot.toNamed('/screen_one'),
            ),
            ElevatedButton(
              child: Text('Launch URL in Browser'),
              onPressed: () => routePilot.launchInBrowser(Uri.parse('https://flutter.dev')),
            ),
            ElevatedButton(
              child: Text('Make Phone Call'),
              onPressed: () => routePilot.makePhoneCall('123-456-7890'),
            ),
          ],
        ),
      ),
    );
  }
}

class PilotPages {
  static PilotPage onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return PilotPage(
          name: '/',
          page: (context) => HomeScreen(),
        );
      case '/screen_one':
        return PilotPage(
          name: '/screen_one',
          page: (context) => ScreenOne(),
          transition: Transition.fadeIn,
        );
      default:
        return PilotPage(
          name: 'error',
          page: (context) => Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}

class ScreenOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen One')),
      body: Center(
        child: Text('This is Screen One'),
      ),
    );
  }
}
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## About the Author

This project is maintained by [Eldho Paulose](https://github.com/eldhopaulose).

- **GitHub:** [eldhopaulose](https://github.com/eldhopaulose)
- **Website:** [Eldho Paulose](https://eldhopaulose.info)

Feel free to reach out for any questions or suggestions regarding this project!
