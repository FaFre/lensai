import 'package:bang_navigator/core/providers.dart';
import 'package:bang_navigator/domain/services/app_initialization.dart';
import 'package:bang_navigator/presentation/widgets/failure_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainApp extends HookConsumerWidget {
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;

  const MainApp({
    required this.theme,
    required this.darkTheme,
    required this.themeMode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializationResult = ref.watch(appInitializationServiceProvider);
    final router = ref.watch(routerProvider);

    return initializationResult.fold(
      (initializationState) {
        if (!initializationState.initialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    if (initializationState.stage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(initializationState.stage!),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          routerConfig: router,
        );
      },
      onFailure: (errorMessage) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Initiallization Error'),
            ),
            body: Center(
              child: FailureWidget(
                title: 'Could not initialize App',
                exception: errorMessage.toString(),
                onRetry: () async {
                  await ref
                      .read(appInitializationServiceProvider.notifier)
                      .reinitialize();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
