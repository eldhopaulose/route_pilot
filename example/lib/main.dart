import 'package:flutter/material.dart';
import 'package:route_pilot/route_pilot.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: routePilot.navigatorKey,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RoutePilot Example')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Go to Second Page'),
                onPressed: () => routePilot.to(SecondPage()),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Launch URL in Browser'),
                onPressed: () => routePilot
                    .launchInBrowser(Uri.parse('https://flutter.dev')),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Launch URL in App'),
                onPressed: () => routePilot
                    .launchInAppBrowser(Uri.parse('https://dart.dev')),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Launch URL in WebView'),
                onPressed: () =>
                    routePilot.launchInAppWebView(Uri.parse('https://pub.dev')),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Make Phone Call'),
                onPressed: () => routePilot.makePhoneCall('123-456-7890'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Send SMS'),
                onPressed: () => routePilot.sendSms('123-456-7890',
                    body: 'Hello from Flutter!'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Send Email'),
                onPressed: () => routePilot.sendEmail(
                  'example@example.com',
                  subject: 'Test Email',
                  body: 'This is a test email sent from a Flutter app.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Second Page')),
      body: Center(
        child: ElevatedButton(
          child: Text('Go Back'),
          onPressed: () => routePilot.back(),
        ),
      ),
    );
  }
}
