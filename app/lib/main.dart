import 'package:bang_navigator/core/error_observer.dart';
import 'package:bang_navigator/domain/services/app_initialization.dart';
import 'package:bang_navigator/features/settings/data/models/settings.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/presentation/hooks/on_initialization.dart';
import 'package:bang_navigator/presentation/widgets/main_app.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HomeWidget.setAppGroupId('bang_navigator');

  // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
  //   await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  // }

  runApp(
    ProviderScope(
      observers: const [ErrorObserver()],
      child: HookConsumer(
        builder: (context, ref, child) {
          final themeMode = ref.watch(
            settingsRepositoryProvider.select(
              (value) =>
                  (value.valueOrNull ?? Settings.withDefaults()).themeMode,
            ),
          );

          useOnInitialization(
            () async {
              await ref
                  .read(appInitializationServiceProvider.notifier)
                  .initialize();
            },
          );

          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              return MainApp(
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: lightDynamic?.harmonized(),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorScheme: darkDynamic?.harmonized(),
                ),
                themeMode: themeMode,
              );
            },
          );
        },
      ),
    ),
  );
}
