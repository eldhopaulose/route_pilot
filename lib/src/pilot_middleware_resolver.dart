import 'package:flutter/material.dart';
import 'pilot_middleware.dart';
import 'route_pilot.dart';

/// A widget that resolves async middlewares before displaying the actual page.
class PilotMiddlewareResolver extends StatefulWidget {
  final List<PilotMiddleware> middlewares;
  final String? routeName;
  final WidgetBuilder builder;

  const PilotMiddlewareResolver({
    Key? key,
    required this.middlewares,
    required this.routeName,
    required this.builder,
  }) : super(key: key);

  @override
  State<PilotMiddlewareResolver> createState() => _PilotMiddlewareResolverState();
}

class _PilotMiddlewareResolverState extends State<PilotMiddlewareResolver> {
  bool _isLoading = true;
  String? _redirectRoute;

  @override
  void initState() {
    super.initState();
    _resolveMiddlewares();
  }

  Future<void> _resolveMiddlewares() async {
    for (final middleware in widget.middlewares) {
      final redirect = await middleware.redirect(widget.routeName);
      if (redirect != null) {
        if (mounted) {
          setState(() {
            _redirectRoute = redirect;
            _isLoading = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(redirect);
          });
        }
        return;
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return routePilot.middlewareLoadingWidget ??
          const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
    }

    if (_redirectRoute != null) {
      return const SizedBox.shrink(); // Awaiting redirect push
    }

    return widget.builder(context);
  }
}
