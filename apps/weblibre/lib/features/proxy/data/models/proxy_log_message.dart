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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_tor/flutter_tor.dart';

enum ProxyLogSource { singBox, tor }

extension ProxyLogSourceX on ProxyLogSource {
  String get label => switch (this) {
    ProxyLogSource.singBox => 'sing-box',
    ProxyLogSource.tor => 'tor',
  };
}

/// How serious one log line is, in the one vocabulary the log viewer speaks.
///
/// The two runtimes do not agree on a spelling — sing-box writes `warn` and
/// `fatal`, Tor writes `WARN`, `ERR` and `NOTICE` — and neither is a closed set
/// this build controls. So the raw string stays on [ProxyLogMessage] as the
/// thing to *show*, and this is what the viewer filters and colours by.
///
/// Ordered least to most serious, which is what makes "at least this level" a
/// comparison rather than a table.
enum ProxyLogSeverity {
  trace,
  debug,
  info,
  warn,
  error;

  /// The severity [raw] names.
  ///
  /// A level this build has never heard of is read as [info] rather than
  /// dropped: it came from a runtime that thought it worth writing, and a
  /// viewer that silently hides lines is worse than one that ranks a rare one
  /// slightly wrong.
  static ProxyLogSeverity parse(String raw) =>
      switch (raw.trim().toLowerCase()) {
        'trace' => trace,
        'debug' => debug,
        'info' || 'notice' => info,
        'warn' || 'warning' => warn,
        'error' || 'err' || 'fatal' || 'panic' => error,
        _ => info,
      };

  /// Label for the viewer's filter. Plural because it selects a range: picking
  /// [warn] shows warnings *and* everything worse.
  String get filterLabel => switch (this) {
    ProxyLogSeverity.trace => 'Trace',
    ProxyLogSeverity.debug => 'Debug',
    ProxyLogSeverity.info => 'Info',
    ProxyLogSeverity.warn => 'Warnings',
    ProxyLogSeverity.error => 'Errors',
  };

  bool get isAtLeastWarn => index >= ProxyLogSeverity.warn.index;

  bool isAtLeast(ProxyLogSeverity minimum) => index >= minimum.index;
}

class ProxyLogMessage with FastEquatable {
  final ProxyLogSource source;
  final String level;
  final String message;
  final int timestamp;
  final String? profileId;

  // Derived from `level`, which is already in `hashParameters`; listing it too
  // would only force the lazy parse on every comparison.
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  /// [level] ranked, computed once per line rather than on every filter pass.
  late final ProxyLogSeverity severity = ProxyLogSeverity.parse(level);

  ProxyLogMessage({
    required this.source,
    required this.level,
    required this.message,
    required this.timestamp,
    this.profileId,
  });

  factory ProxyLogMessage.fromSingbox(SingboxProxyLogMessage message) {
    return ProxyLogMessage(
      source: ProxyLogSource.singBox,
      level: message.level,
      message: message.message,
      timestamp: message.timestamp,
      profileId: message.profileId,
    );
  }

  factory ProxyLogMessage.fromTor(TorLogMessage message) {
    return ProxyLogMessage(
      source: ProxyLogSource.tor,
      level: _torSeverityToLevel(message.severity),
      message: message.message,
      timestamp: message.timestamp,
    );
  }

  @override
  List<Object?> get hashParameters => [
    source,
    level,
    message,
    timestamp,
    profileId,
  ];
}

String _torSeverityToLevel(String severity) {
  return switch (severity.toUpperCase()) {
    'ERR' => 'error',
    'WARN' => 'warn',
    'DEBUG' => 'debug',
    'INFO' || 'NOTICE' => 'info',
    _ => severity.toLowerCase(),
  };
}
