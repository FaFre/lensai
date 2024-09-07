import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Fragment Example'),
          actions: [
            MenuAnchor(
                builder: (context, controller, child) => IconButton(
                    onPressed: () {
                      controller.open();
                    },
                    icon: const Icon(Icons.menu)),
                menuChildren: [
                  MenuItemButton(
                    onPressed: () async {
                      await GeckoSessionService.forCurrentTab().reload();
                    },
                    child: const Text('Reload'),
                  ),
                  MenuItemButton(
                    onPressed: () async {
                      await GeckoSessionService.forCurrentTab().goBack();
                    },
                    child: const Text('Back'),
                  )
                ])
          ],
        ),
        body: const SafeArea(
          child: Center(
            child: GeckoView(),
          ),
        ),
      ),
    );
  }
}
