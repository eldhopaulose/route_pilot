import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pilot_page.dart';
import 'pilot_observer.dart';
import 'pilot_route_group.dart';
import 'pilot_middleware_resolver.dart';
import 'router/pilot_router_delegate.dart';
import 'router/pilot_route_information_parser.dart';

/// RoutePilot is a singleton class that provides navigation and URL launching functionalities.
class RoutePilot {
  static final RoutePilot _instance = RoutePilot._internal();
  factory RoutePilot() => _instance;
  RoutePilot._internal();

  /// Global navigator key for accessing navigator state
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// The RouteObserver tracking navigation for RoutePilot
  late final PilotObserver observer = PilotObserver(onRouteChanged: _onRouteChanged);

  PilotRouterDelegate? _routerDelegate;

  void _onRouteChanged() {
    _routerDelegate?.notify();
  }

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

  /// Optional global loading widget to display while async middlewares are resolving.
  Widget? middlewareLoadingWidget;

  RouterConfig<Object> getRouterConfig({
    required List<dynamic> pages,
    PilotPage? notFoundPage,
    String? initialRoute,
  }) {
    _routerDelegate = PilotRouterDelegate(
      navigatorKey: navigatorKey,
      pagesConfig: pages,
      notFoundPage: notFoundPage,
    );
    return RouterConfig(
      routerDelegate: _routerDelegate!,
      routeInformationParser: PilotRouteInformationParser(),
      backButtonDispatcher: RootBackButtonDispatcher(),
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(
          uri: Uri.parse(initialRoute ??
              WidgetsBinding.instance.platformDispatcher.defaultRouteName),
        ),
      ),
    );
  }

  /// Internal engine for generating routes dynamically.
  Route<dynamic>? onGenerateRoute(
    RouteSettings settings, {
    required List<dynamic> pages,
    PilotPage? notFoundPage,
  }) {
    if (settings.name == null) return null;

    final uri = Uri.parse(settings.name!);
    _parameters = {...uri.queryParameters};

    PilotPage? matchedPage;

    // Flatten route groups and pages
    final List<PilotPage> flatPages = [];
    for (final p in pages) {
      if (p is PilotPage) {
        flatPages.add(p);
      } else if (p is PilotRouteGroup) {
        flatPages.addAll(p.flatten());
      }
    }

    // Attempt matching
    for (final page in flatPages) {
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

    if (matchedPage == null) {
      if (notFoundPage != null) {
        return notFoundPage.toRoute();
      }
      return null;
    }

    if (settings.arguments != null) {
      _setArguments(settings.arguments);
    }

    // Handle middlewares using resolver if there are any
    if (matchedPage.middlewares != null && matchedPage.middlewares!.isNotEmpty) {
      final originalBuilder = matchedPage.page;
      final originalMiddlewares = matchedPage.middlewares!;
      matchedPage = PilotPage(
        name: matchedPage.name ?? '',
        page: (context) => PilotMiddlewareResolver(
          middlewares: originalMiddlewares,
          routeName: settings.name,
          builder: originalBuilder,
        ),
        fullscreenDialog: matchedPage.fullscreenDialog,
        transitionDuration: matchedPage.transitionDuration,
        transition: matchedPage.transition,
        curve: matchedPage.curve,
        maintainState: matchedPage.maintainState,
        opaque: matchedPage.opaque,
        parameters: matchedPage.parameters,
        arguments: matchedPage.arguments,
        middlewares: null, // Middlewares are handled, don't pass again
      );
    }

    return matchedPage.toRoute();
  }

  /// Private variable to store navigation arguments
  dynamic _arguments;

  /// Navigates to a new page
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

    return navigatorKey.currentState!.push<T>(MaterialPageRoute(
      builder: (_) => page,
      settings: RouteSettings(name: page.runtimeType.toString()),
    ));
  }

  /// Navigates to a named route
  Future<T?> toNamed<T>(String routeName, {dynamic arguments}) {
    _setArguments(arguments);
    return navigatorKey.currentState!.pushNamed<T>(routeName);
  }

  /// Navigates back to the previous route
  void back<T>([T? result]) {
    _arguments = null;
    navigatorKey.currentState!.pop<T>(result);
  }

  /// Pops routes continuously until the predicate returns true.
  void backUntilPredicate(RoutePredicate predicate) {
    navigatorKey.currentState!.popUntil(predicate);
  }

  /// Pops routes continuously until the specified route name is found.
  void backUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  /// Removes all existing routes and navigates to a new named route
  Future<T?> offAll<T>(String routeName, {dynamic arguments}) {
    _setArguments(arguments);
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil<T>(routeName, (route) => false);
  }

  /// Replaces the current route with a new named route
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
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Shows a non-dismissible loading overlay dialog.
  void showLoading({Widget? indicator}) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false, // Prevent back button closing
        child: Center(
          child: indicator ?? const CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Hides the loading overlay dialog if one is open.
  void hideLoading() {
    navigatorKey.currentState!.pop();
  }

  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> launchInAppBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> launchInAppWebView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

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

  Future<void> launchInAppWithoutJavaScript(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(enableJavaScript: false),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> launchInAppWithoutDomStorage(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(enableDomStorage: false),
    )) {
      throw Exception('Could not launch $url');
    }
  }

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

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> sendSms(String phoneNumber, {String? body}) async {
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters:
          body != null ? {'body': Uri.encodeComponent(body)} : null,
    );
    await launchUrl(smsLaunchUri);
  }

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

  Future<bool> canLaunchUrl(Uri url) => canLaunchUrl(url);

  void _setArguments(dynamic arguments) {
    _arguments = arguments;
  }

  dynamic get args => _arguments;

  T? getArguments<T>() {
    if (_arguments is T) return _arguments as T;
    return null;
  }

  T? arg<T>(String key) {
    if (_arguments is Map && (_arguments as Map).containsKey(key)) {
      return (_arguments as Map)[key] as T?;
    }
    return null;
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

final RoutePilot routePilot = RoutePilot();
