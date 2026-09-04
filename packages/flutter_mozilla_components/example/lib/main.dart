import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  /// Receives the native state events, of which [GeckoView] needs the
  /// view-ready reports to know when it may attach the browser fragment.
  final _eventService = GeckoEventService.setUp();

  @override
  void dispose() {
    unawaited(_eventService.dispose());
    super.dispose();
  }

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
                icon: const Icon(Icons.menu),
              ),
              menuChildren: [
                MenuItemButton(
                  onPressed: () async {
                    await GeckoSessionService.forActiveTab().reload();
                  },
                  child: const Text('Reload'),
                ),
                MenuItemButton(
                  onPressed: () async {
                    await GeckoSessionService.forActiveTab().goBack();
                  },
                  child: const Text('Back'),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: GeckoView(
              viewReadyEvents: _eventService.viewReadyStateEvents,
            ),
          ),
        ),
      ),
    );
  }
}
