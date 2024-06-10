import 'package:bang_navigator/core/logger.dart';
import 'package:bang_navigator/core/providers.dart';
import 'package:bang_navigator/features/about/data/repositories/package_info_repository.dart';
import 'package:bang_navigator/features/bangs/domain/repositories/bang.dart';
import 'package:bang_navigator/features/search_browser/domain/services/session.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/presentation/hooks/on_initialization.dart';
import 'package:flutter/material.dart';
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
              await ref.read(packageInfoProvider.future);

              await ref
                  .read(bangRepositoryProvider.notifier)
                  .syncAllBangGroups();

              final settings =
                  await ref.read(settingsRepositoryProvider.future);

              if (settings.incognitoMode) {
                await ref.read(sessionServiceProvider.notifier).clearAllData();
              }

              if (settings.kagiSession case final String session) {
                if (session.isNotEmpty) {
                  await ref
                      .read(sessionServiceProvider.notifier)
                      .setKagiSession(session);
                }
              }

              ref.read(sessionServiceProvider.notifier).initializationDone();
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
    final isInitialized = ref.watch(sessionServiceProvider);
    final router = ref.watch(routerProvider);

    if (!isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: const Color(0xFFFFB319),
        //   brightness: Brightness.dark,
        // ),
      ),
      routerConfig: router,
    );
  }
}
