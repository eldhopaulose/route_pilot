import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Private variable to store navigation arguments
  dynamic _arguments;

  /// Navigates to a new page
  ///
  /// [page]: The widget to navigate to
  /// [arguments]: Optional arguments to pass to the new route
  /// Returns a Future that completes with the result of the push
  Future<dynamic> to(Widget page, {dynamic arguments}) {
    _setArguments(arguments);
    return navigatorKey.currentState!
        .push(MaterialPageRoute(builder: (_) => page));
  }

  /// Navigates to a named route
  ///
  /// [routeName]: The name of the route to navigate to
  /// [arguments]: Optional arguments to pass to the new route
  /// Returns a Future that completes with the result of the push
  Future<dynamic> toNamed(String routeName, {dynamic arguments}) {
    _setArguments(arguments);
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  /// Navigates back to the previous route
  void back() {
    _arguments = null;
    navigatorKey.currentState!.pop();
  }

  /// Removes all existing routes and navigates to a new named route
  ///
  /// [routeName]: The name of the route to navigate to
  /// [arguments]: Optional arguments to pass to the new route
  /// Returns a Future that completes with the result of the push
  Future<dynamic> offAll(String routeName, {dynamic arguments}) {
    _setArguments(arguments);
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  /// Replaces the current route with a new named route
  ///
  /// [routeName]: The name of the route to navigate to
  /// [arguments]: Optional arguments to pass to the new route
  /// Returns a Future that completes with the result of the push
  Future<dynamic> off(String routeName, {dynamic arguments}) {
    _setArguments(arguments);
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
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
  /// Returns a Future<bool> indicating whether the URL can be launched
  Future<bool> canLaunchUrl(Uri url) => canLaunchUrl(url);

  /// Sets the navigation arguments
  ///
  /// [arguments]: The arguments to set
  /// If arguments is a Map<String, dynamic>, it's wrapped in a List
  /// If arguments is a List<Map<String, dynamic>>, it's set as is
  /// Otherwise, arguments are set to null
  void _setArguments(dynamic arguments) {
    if (arguments is Map<String, dynamic>) {
      _arguments = [arguments];
    } else if (arguments is List<Map<String, dynamic>>) {
      _arguments = arguments;
    } else {
      _arguments = null;
    }
  }

  /// Gets the navigation arguments
  ///
  /// Returns a List<Map<String, dynamic>>? containing the arguments
  List<Map<String, dynamic>>? get args {
    return _arguments as List<Map<String, dynamic>>?;
  }

  /// Gets a specific argument by key
  ///
  /// [key]: The key of the argument to retrieve
  /// [index]: The index of the argument map in the list (default: 0)
  /// Returns the argument value of type T, or null if not found
  T? arg<T>(String key, {int index = 0}) {
    if (_arguments is List && _arguments.length > index) {
      final map = _arguments[index];
      if (map is Map<String, dynamic> && map.containsKey(key)) {
        return map[key] as T?;
      }
    }
    return null;
  }

  /// Gets the argument map at a specific index
  ///
  /// [index]: The index of the argument map to retrieve
  /// Returns the Map<String, dynamic>? at the specified index, or null if not found
  Map<String, dynamic>? argsAt(int index) {
    if (_arguments is List && _arguments.length > index) {
      return _arguments[index] as Map<String, dynamic>?;
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
