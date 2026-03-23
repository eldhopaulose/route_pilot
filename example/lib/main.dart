import 'package:flutter/material.dart';
import 'package:route_pilot/route_pilot.dart';

void main() {
  runApp(const MyApp());
}

class PersonData {
  final int id;
  final String title;
  PersonData({required this.id, required this.title});
}

// ----------------------------------------------------
// 1. Defining an Async Middleware Guard
// ----------------------------------------------------
bool isAuthenticated = false; // Mock Authentication State

class AsyncAuthGuard extends PilotMiddleware {
  @override
  Future<String?> redirect(String? route) async {
    if (!isAuthenticated) {
      // Simulate fake network request for token check
      await Future.delayed(const Duration(milliseconds: 1000));
      return '/login'; // Redirect if not authenticated
    }
    return null; // Proceed normal routing
  }
}

// ----------------------------------------------------
// 2. Strongly Typed Route Definition
// ----------------------------------------------------
final paramRoute = PilotRoute<void, void>('/param/:id');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Use RoutePilot's new Router API configuration for Web URL sync & Deep Linking
      routerConfig: routePilot.getRouterConfig(
        notFoundPage: PilotPage(
          name: '/404',
          page: (context) => const NotFoundPage(),
        ),
        pages: [
          PilotPage(name: '/', page: (context) => const HomePage()),
          
          PilotPage(
            name: '/second',
            page: (context) => SecondPage(
              name: routePilot.arg<String>('name') ?? 'Guest',
              age: routePilot.arg<int>('age') ?? 0,
              personData: routePilot.getArguments<PersonData>() ??
                  routePilot.arg<PersonData>('personData') ??
                  PersonData(id: -1, title: 'No Data'),
            ),
            transition: Transition.scale,
          ),
          
          PilotPage(
            name: '/param/:id',
            page: (context) => const ParamPage(),
          ),
          
          PilotPage(
            name: '/third', 
            page: (context) => const ThirdPage(),
          ),

          // ----------------------------------------------------
          // 3. Using Route Groups
          // ----------------------------------------------------
          PilotRouteGroup(
            prefix: '/dashboard',
            middlewares: [AsyncAuthGuard()], // Secure all routes in dashboard
            transition: Transition.fadeIn,
            children: [
              PilotPage(name: '/home', page: (context) => const ProtectedPage()),
              PilotPage(name: '/settings', page: (context) => const Scaffold(body: Center(child: Text('Settings')))),
            ],
          ),

          PilotPage(name: '/login', page: (context) => const LoginPage()),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RoutePilot v2.0 Example')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Go to Second Page (Direct Constructor)'),
                onPressed: () => routePilot.to(SecondPage(
                    name: 'Eldho (Direct)',
                    age: 26,
                    personData: PersonData(id: 101, title: 'Flutter Dev'))),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Go to Second Page (Named w/ Map Arguments)'),
                onPressed: () => routePilot.toNamed('/second', arguments: {
                  'name': 'Paulose (Named)',
                  'age': 30,
                  'personData': PersonData(id: 102, title: 'Dart Engineer'),
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Go to Params Page (/param/42?query=hello)'),
                // Using Strongly typed PilotRoute wrapper!
                onPressed: () => paramRoute.push(
                  pathParams: {'id': '42'},
                  queryParams: {'query': 'hello'},
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Show Global Loading Overlay (Closes after 2s)'),
                onPressed: () async {
                  routePilot.showLoading();
                  await Future.delayed(const Duration(seconds: 2));
                  routePilot.hideLoading();
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Show Queue-Safe SnackBar'),
                onPressed: () => routePilot.snackBar('This overwrites previous Snackbars immediately!'),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const Text('Middleware & Route Group Showcase:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white),
                child: const Text('Go to Dashboard (Async Auth Guard)'),
                onPressed: () => routePilot.toNamed('/dashboard/home'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white),
                child: const Text('Go to Unknown Route (Triggers 404 Fallback)'),
                onPressed: () => routePilot.toNamed('/random-broken-path'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404 Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text('Oops! That page does not exist.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => routePilot.offAll('/'),
              child: const Text('Return Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class ParamPage extends StatelessWidget {
  const ParamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Param Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ID Path Param: ${routePilot.param('id')}',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text('Query Param: ${routePilot.param('query')}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Go Back'),
              onPressed: () => routePilot.back(),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Second Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Name Passed: $name', style: const TextStyle(fontSize: 22)),
            Text('Age Passed: $age', style: const TextStyle(fontSize: 22)),
            const Divider(),
            Text('PersonData ID: ${personData.id}',
                style: const TextStyle(fontSize: 18)),
            Text('PersonData Title: ${personData.title}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              child: const Text('Go to Third Page'),
              onPressed: () => routePilot.toNamed('/third'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Go Back'),
              onPressed: () => routePilot.back(),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Third Page (Deep)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are deep in the navigation stack!',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              child: const Text('Go back to Second Page (Single Pop)'),
              onPressed: () => routePilot.back(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white),
              child: const Text('Pop until Home Page (backUntil)'),
              onPressed: () => routePilot.backUntil('/'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProtectedPage extends StatelessWidget {
  const ProtectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protected Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text('You bypassed the guard!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              child: const Text('Go Back'),
              onPressed: () => routePilot.back(),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Guard Triggered')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text('AuthGuard blocked access!',
                style: TextStyle(fontSize: 22, color: Colors.redAccent)),
            const SizedBox(height: 10),
            const Text('You were redirected to Login after an Async Check.'),
            const SizedBox(height: 40),
            ElevatedButton(
              child: const Text('Mock Login & Return Home'),
              onPressed: () {
                isAuthenticated = true; // Login successfully
                routePilot.back();
                routePilot.snackBar(
                    'Logged in successfully! You can now access the Protected Page.');
              },
            ),
          ],
        ),
      ),
    );
  }
}
