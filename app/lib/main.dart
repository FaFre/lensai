import 'package:bang_navigator/core/logger.dart';
import 'package:bang_navigator/core/providers.dart';
import 'package:bang_navigator/domain/services/app_initialization.dart';
import 'package:bang_navigator/presentation/hooks/on_initialization.dart';
import 'package:bang_navigator/presentation/widgets/failure_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _ErrorObserver extends ProviderObserver {
  const _ErrorObserver();

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    logger.e('Provider $provider threw $error at $stackTrace');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HomeWidget.setAppGroupId('bang_navigator');

  // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
  //   await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  // }

  runApp(
    ProviderScope(
      observers: const [_ErrorObserver()],
      child: HookConsumer(
        builder: (context, ref, child) {
          useOnInitialization(
            () async {
              await ref
                  .read(appInitializationServiceProvider.notifier)
                  .initialize();
            },
          );

          return const MainApp();
        },
      ),
    ),
  );
}

class MainApp extends HookConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializationResult = ref.watch(appInitializationServiceProvider);
    final router = ref.watch(routerProvider);

    final themeData = useMemoized(
      () => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: const Color(0xFFFFB319),
        //   brightness: Brightness.dark,
        // ),
      ),
    );

    return initializationResult.fold(
      (initializationState) {
        if (!initializationState.initialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeData,
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
          theme: themeData,
          routerConfig: router,
        );
      },
      onFailure: (errorMessage) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeData,
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
