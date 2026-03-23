import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pilot_page.dart';
import 'pilot_observer.dart';

/// RoutePilot is a singleton class that provides navigation and URL launching functionalities.
/// It encapsulates Flutter's navigation methods and url_launcher package functionality.
class RoutePilot {
  // Singleton instance
  static final RoutePilot _instance = RoutePilot._internal();

  /// Factory constructor to return the singleton instance
  factory RoutePilot() => _instance;

  /// Private constructor for singleton pattern
  RoutePilot._internal();

  /// Global navigator key for accessing navigator state
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// The RouteObserver tracking navigation for RoutePilot
  final PilotObserver observer = PilotObserver();

  /// Gets the current route name from the observer stack
  String? get currentRoute => observer.routeStack.isNotEmpty
      ? observer.routeStack.last.settings.name
      : null;

  /// Gets the previous route name from the observer stack
  String? get previousRoute => observer.routeStack.length > 1
      ? observer.routeStack[observer.routeStack.length - 2].settings.name
      : null;

  /// Private map storing parsed path and query parameters
  Map<String, String> _parameters = {};

  /// Retrieves a parsed path or query parameter securely
  String? param(String key) => _parameters[key];

  /// Internal engine for generating routes dynamically.
  /// Handles matching paths, parsing path/query parameters, and running middlewares.
  Route<dynamic>? onGenerateRoute(RouteSettings settings,
      {required List<PilotPage> pages}) {
    if (settings.name == null) return null;

    final uri = Uri.parse(settings.name!);
    _parameters = {...uri.queryParameters};

    PilotPage? matchedPage;

    // Attempt matching
    for (final page in pages) {
      if (page.name == uri.path) {
        matchedPage = page;
        break;
      }

      if (page.name == null) continue;
      final routeSegments = page.name!.split('/');
      final pathSegments = uri.path.split('/');

      if (routeSegments.length == pathSegments.length) {
        bool match = true;
        Map<String, String> pathParams = {};
        for (int i = 0; i < routeSegments.length; i++) {
          if (routeSegments[i].startsWith(':')) {
            pathParams[routeSegments[i].substring(1)] = pathSegments[i];
          } else if (routeSegments[i] != pathSegments[i]) {
            match = false;
            break;
          }
        }
        if (match) {
          _parameters.addAll(pathParams);
          matchedPage = page;
          break;
        }
      }
    }

    if (matchedPage == null) return null;

    // Run custom middlewares
    if (matchedPage.middlewares != null) {
      for (final middleware in matchedPage.middlewares!) {
        final redirectRoute = middleware.redirect(settings.name);
        if (redirectRoute != null) {
          // Redirect triggers the system recursively
          return onGenerateRoute(
            RouteSettings(name: redirectRoute, arguments: settings.arguments),
            pages: pages,
          );
        }
      }
    }

    if (settings.arguments != null) {
      _setArguments(settings.arguments);
    }

    return matchedPage.toRoute();
  }

  /// Private variable to store navigation arguments
  dynamic _arguments;

  /// Navigates to a new page
  ///
  /// [page]: The widget to navigate to
  /// [arguments]: Optional arguments to pass to the new route
  /// Returns a Future that completes with the result of the push
  Future<T?> to<T>(
    Widget page, {
    dynamic arguments,
    Transition? transition,
    Duration? transitionDuration,
    Curve? curve,
  }) {
    _setArguments(arguments);

    if (transition != null) {
      final pilotPage = PilotPage<T>(
        name: page.runtimeType.toString(),
        page: (_) => page,
        arguments: arguments,
        transition: transition,
        transitionDuration: transitionDuration,
        curve: curve ?? Curves.linear,
      );

      return navigatorKey.currentState!
          .push<T>(pilotPage.createRoute(navigatorKey.currentContext!));
    }

    return navigatorKey.currentState!
        .push<T>(MaterialPageRoute(builder: (_) => page));
  }

  /// Navigates to a named route
  ///
  /// [routeName]: The name of the route to navigate to
  /// [arguments]: Optional arguments to pass to the new route
  /// Returns a Future that completes with the result of the push
  Future<T?> toNamed<T>(String routeName, {dynamic arguments}) {
    _setArguments(arguments);
    return navigatorKey.currentState!.pushNamed<T>(routeName);
  }

  /// Navigates back to the previous route
  void back<T>([T? result]) {
    _arguments = null;
    navigatorKey.currentState!.pop<T>(result);
  }

  /// Removes all existing routes and navigates to a new named route
  ///
  /// [routeName]: The name of the route to navigate to
  /// [arguments]: Optional arguments to pass to the new route
  /// Returns a Future that completes with the result of the push
  Future<T?> offAll<T>(String routeName, {dynamic arguments}) {
    _setArguments(arguments);
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil<T>(routeName, (route) => false);
  }

  /// Replaces the current route with a new named route
  ///
  /// [routeName]: The name of the route to navigate to
  /// [arguments]: Optional arguments to pass to the new route
  /// Returns a Future that completes with the result of the push
  Future<T?> off<T, TO>(String routeName, {dynamic arguments}) {
    _setArguments(arguments);
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(routeName);
  }

  /// Displays a dialog above the current contents of the app.
  Future<T?> dialog<T>(Widget dialogWidget, {bool barrierDismissible = true}) {
    return showDialog<T>(
      context: navigatorKey.currentContext!,
      barrierDismissible: barrierDismissible,
      builder: (_) => dialogWidget,
    );
  }

  /// Shows a modal material design bottom sheet.
  Future<T?> bottomSheet<T>(Widget bottomSheetWidget,
      {bool isScrollControlled = false, bool isDismissible = true}) {
    return showModalBottomSheet<T>(
      context: navigatorKey.currentContext!,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      builder: (_) => bottomSheetWidget,
    );
  }

  /// Shows a SnackBar with the provided message.
  void snackBar(String message,
      {Duration duration = const Duration(seconds: 4),
      Color? backgroundColor}) {
    final context = navigatorKey.currentContext!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Launches a URL in the device's default browser
  ///
  /// [url]: The URL to launch
  /// Throws an exception if the URL cannot be launched
  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  /// Launches a URL in an in-app browser
  ///
  /// [url]: The URL to launch
  /// Throws an exception if the URL cannot be launched
  Future<void> launchInAppBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  /// Launches a URL in an in-app WebView
  ///
  /// [url]: The URL to launch
  /// Throws an exception if the URL cannot be launched
  Future<void> launchInAppWebView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  /// Launches a URL in an in-app WebView with custom headers
  ///
  /// [url]: The URL to launch
  /// [headers]: A map of custom headers to send with the request
  /// Throws an exception if the URL cannot be launched
  Future<void> launchInAppWithCustomHeaders(
      Uri url, Map<String, String> headers) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: WebViewConfiguration(headers: headers),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  /// Launches a URL in an in-app WebView with JavaScript disabled
  ///
  /// [url]: The URL to launch
  /// Throws an exception if the URL cannot be launched
  Future<void> launchInAppWithoutJavaScript(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(enableJavaScript: false),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  /// Launches a URL in an in-app WebView with DOM storage disabled
  ///
  /// [url]: The URL to launch
  /// Throws an exception if the URL cannot be launched
  Future<void> launchInAppWithoutDomStorage(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(enableDomStorage: false),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  /// Launches a Universal Link on iOS
  ///
  /// [url]: The URL to launch
  /// Attempts to launch the URL in a native app first, then falls back to an in-app browser
  Future<void> launchUniversalLinkIOS(Uri url) async {
    final bool nativeAppLaunchSucceeded = await launchUrl(
      url,
      mode: LaunchMode.externalNonBrowserApplication,
    );
    if (!nativeAppLaunchSucceeded) {
      await launchUrl(
        url,
        mode: LaunchMode.inAppBrowserView,
      );
    }
  }

  /// Initiates a phone call
  ///
  /// [phoneNumber]: The phone number to call
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  /// Sends an SMS
  ///
  /// [phoneNumber]: The phone number to send the SMS to
  /// [body]: Optional body text for the SMS
  Future<void> sendSms(String phoneNumber, {String? body}) async {
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters:
          body != null ? {'body': Uri.encodeComponent(body)} : null,
    );
    await launchUrl(smsLaunchUri);
  }

  /// Sends an email
  ///
  /// [email]: The email address to send to
  /// [subject]: Optional subject for the email
  /// [body]: Optional body text for the email
  Future<void> sendEmail(String email, {String? subject, String? body}) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );
    await launchUrl(emailLaunchUri);
  }

  /// Checks if a URL can be launched
  ///
  /// [url]: The URL to check
  /// Returns a `Future<bool>` indicating whether the URL can be launched
  Future<bool> canLaunchUrl(Uri url) => canLaunchUrl(url);

  /// Sets the navigation arguments
  ///
  /// [arguments]: The arguments to set
  void _setArguments(dynamic arguments) {
    _arguments = arguments;
  }

  /// Gets the raw navigation arguments
  ///
  /// Returns the raw object (e.g., Map, custom class, etc.) passed.
  dynamic get args => _arguments;

  /// Tries to get the raw arguments casted to a specific type
  T? getArguments<T>() {
    if (_arguments is T) return _arguments as T;
    return null;
  }

  /// Gets a specific argument by key (assumes arguments is a Map)
  ///
  /// [key]: The key of the argument to retrieve
  /// Returns the argument value of type T, or null if not found
  T? arg<T>(String key) {
    if (_arguments is Map && (_arguments as Map).containsKey(key)) {
      return (_arguments as Map)[key] as T?;
    }
    return null;
  }

  /// Encodes query parameters for URL construction
  ///
  /// [params]: A map of query parameters to encode
  /// Returns a String of encoded query parameters
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

/// Global instance of RoutePilot for easy access throughout the app
final RoutePilot routePilot = RoutePilot();
