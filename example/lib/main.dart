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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: routePilot.navigatorKey,
      navigatorObservers: [routePilot.observer],
      onGenerateRoute: (settings) => routePilot.onGenerateRoute(
        settings,
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
              transition: Transition.scale),
          PilotPage(name: '/param/:id', page: (context) => const ParamPage()),
        ],
      ),
      initialRoute: '/',
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RoutePilot Advanced Example')),
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
                child: const Text(
                    'Go to Second Page (Named w/ Raw Object Argument)'),
                onPressed: () => routePilot.toNamed('/second',
                    arguments:
                        PersonData(id: 103, title: 'Direct Object Passed')),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Go to Params Page (/param/42?query=hello)'),
                onPressed: () => routePilot.toNamed('/param/42?query=hello'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Show Dialog'),
                onPressed: () => routePilot.dialog(
                  AlertDialog(
                    title: const Text('Hello RoutePilot'),
                    actions: [
                      TextButton(
                          onPressed: () => routePilot.back(),
                          child: const Text('Close'))
                    ],
                  ),
                ),
              ),
            ],
          ),
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
              child: const Text('Go Back'),
              onPressed: () => routePilot.back(),
            ),
          ],
        ),
      ),
    );
  }
}
