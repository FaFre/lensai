/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:pigeon/pigeon.dart';

class Intent {
  final String? fromPackageName;
  final String? action;
  final String? data;
  final List<String> categories;
  final String? mimeType;
  final Map<String, Object?> extra;

  Intent({
    required this.fromPackageName,
    required this.action,
    required this.data,
    required this.categories,
    required this.mimeType,
    required this.extra,
  });
}

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/intent.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/simple_intent_receiver/pigeons/Intent.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.simple_intent_receiver.pigeons',
    ),
    dartPackageName: 'simple_intent_receiver',
  ),
)
@HostApi()
abstract class IntentHost {
  /// Declares Dart ready for live delivery and returns every intent that
  /// arrived before it was, oldest first.
  ///
  /// The two halves are one call on purpose. Readiness is what the native side
  /// cannot observe for itself — an engine outlives the activity that hosted
  /// it, so "an activity just attached" says nothing about whether anything is
  /// listening — and a drain that did not flip it would leave a window between
  /// the last buffered intent and the first live one in which a launch reaches
  /// a handler that is not registered yet and is lost without a trace.
  ///
  /// Idempotent: a second call drains an empty buffer and leaves the side
  /// ready.
  List<Intent> takePendingIntents();
}

@FlutterApi()
abstract class IntentEvents {
  void onIntentReceived(int sequence, Intent intent);
}

@HostApi()
abstract class IntentGatekeeperHostApi {
  /// Replicates the blocked-packages policy to the native side so the
  /// [IntentReceiverActivity] can reject intents without launching Flutter.
  void setConfig(bool enabled, List<String> blockedPackages);

  /// Replicates whether the Custom Tabs feature is enabled to the native side.
  /// When disabled, [IntentReceiverActivity] routes external Custom Tab and
  /// share-with-URL intents to the main browser instead of launching the
  /// stripped-down custom-tab activity. Defaults to enabled on the native side.
  void setCustomTabsEnabled(bool enabled);

  /// Resolves a package name to its user-visible application label via
  /// [PackageManager]. Returns `null` if the package is not installed or the
  /// label cannot be resolved.
  String? resolvePackageLabel(String packageName);

  /// Returns the list of packages for which the user tapped "Always allow"
  /// via a blocked-intent notification while WebLibre was not running.
  /// Callers must acknowledge persisted packages via
  /// [ackPendingAlwaysAllows] after Flutter settings were updated
  /// successfully.
  List<String> getPendingAlwaysAllows();

  /// Removes the given packages from the pending "Always allow" set after
  /// Flutter has successfully persisted them into its own policy store.
  void ackPendingAlwaysAllows(List<String> packageNames);
}
