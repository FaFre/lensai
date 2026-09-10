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

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/settings/domain/providers/log_filter.dart';
import 'package:weblibre/features/settings/presentation/dialogs/log_details_dialog.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/utils/ui_helper.dart';

IconData _levelIcon(Level level) {
  return switch (level) {
    Level.trace => Icons.blur_circular,
    Level.debug => Icons.bug_report,
    Level.info => Icons.info,
    Level.warning => Icons.warning,
    Level.error => Icons.error,
    Level.fatal => Icons.dangerous,
    Level.all => Icons.notes,
    Level.verbose => Icons.chat_bubble_outline,
    Level.wtf => Icons.question_mark,
    Level.nothing => Icons.close,
    Level.off => Icons.offline_bolt,
  };
}

Color _levelColor(Level level) {
  return switch (level) {
    Level.trace => Colors.grey,
    Level.debug => Colors.blue,
    Level.info => Colors.cyan,
    Level.warning => Colors.orange,
    Level.error => Colors.red,
    Level.fatal => Colors.purple,
    Level.all => Colors.grey,
    Level.verbose => Colors.teal,
    Level.wtf => Colors.brown,
    Level.nothing => Colors.grey,
    Level.off => Colors.grey,
  };
}

Color _levelBackgroundColor(Level level, BuildContext context) {
  return switch (level) {
    Level.trace => Colors.grey.withValues(alpha: 0.1),
    Level.debug => Colors.blue.withValues(alpha: 0.05),
    Level.info => Colors.cyan.withValues(alpha: 0.05),
    Level.warning => Colors.orange.withValues(alpha: 0.1),
    Level.error => Colors.red.withValues(alpha: 0.1),
    Level.fatal => Colors.purple.withValues(alpha: 0.1),
    Level.all => Colors.grey.withValues(alpha: 0.1),
    Level.verbose => Colors.teal.withValues(alpha: 0.05),
    Level.wtf => Colors.brown.withValues(alpha: 0.1),
    Level.nothing => Colors.grey.withValues(alpha: 0.05),
    Level.off => Colors.grey.withValues(alpha: 0.05),
  };
}

class ErrorLogsScreen extends HookConsumerWidget {
  const ErrorLogsScreen({super.key});

  String _logsText() {
    final logs = loggerMemory.buffer;
    return logs.map((e) => e.lines.join('\n')).join('\n\n');
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _logsText()));
    if (context.mounted) {
      showInfoMessage(context, 'Logs copied');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minLogLevel = ref.watch(logFilterProvider);
    final search = useSettingsSearch();
    final query = search.normalizedQuery;

    final allLogs = useMemoized(() => loggerMemory.buffer.toList());

    final sortedLogs = useMemoized(
      () => allLogs.reversed
          .where((e) => e.level.value >= minLogLevel.value)
          .where((e) {
            if (query.isEmpty) return true;
            return matchesSettingsSearch(query, [
              if (e.origin.message != null) e.origin.message.toString(),
              if (e.origin.error != null) e.origin.error.toString(),
            ]);
          })
          .toList(),
      [allLogs, minLogLevel.value, query],
    );

    return SettingsCustomScrollScaffold(
      title: 'Error Logs',
      searchController: search.controller,
      searchHintText: 'Search log messages',
      actions: [
        MenuAnchor(
          builder: (context, controller, childAnchor) {
            return TextButton.icon(
              onPressed: controller.open,
              icon: const Icon(Icons.filter_list),
              label: Text(minLogLevel.name.toUpperCase()),
            );
          },
          menuChildren: [
            const Divider(height: 0),
            _buildLevelFilterMenuItem(context, ref, minLogLevel, Level.trace),
            _buildLevelFilterMenuItem(context, ref, minLogLevel, Level.debug),
            _buildLevelFilterMenuItem(context, ref, minLogLevel, Level.info),
            _buildLevelFilterMenuItem(context, ref, minLogLevel, Level.warning),
            _buildLevelFilterMenuItem(context, ref, minLogLevel, Level.error),
            _buildLevelFilterMenuItem(context, ref, minLogLevel, Level.fatal),
          ],
        ),
        IconButton(
          onPressed: () => _copyToClipboard(context),
          icon: const Icon(Icons.copy),
          tooltip: 'Copy logs',
        ),
      ],
      slivers: [
        if (sortedLogs.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No logs available')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 20),
            // Log lines render as their own _LogEntryTile cards rather than
            // settings-section entries because they have nothing to do with
            // settings semantically — the SettingsSection abstraction was
            // overkill here. We keep the SettingsSearchField + filtering for
            // free via the shared scaffold.
            sliver: SliverList.builder(
              itemCount: sortedLogs.length,
              itemBuilder: (context, index) =>
                  _LogEntryTile(event: sortedLogs[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildLevelFilterMenuItem(
    BuildContext context,
    WidgetRef ref,
    Level minLogLevel,
    Level level,
  ) {
    final levelColor = _levelColor(level);

    // The minimum level is a single choice, so these are radios rather than
    // checkboxes: tapping one always selects it and deselects the others.
    return RadioMenuButton<Level>(
      trailingIcon: Icon(_levelIcon(level), color: levelColor),
      value: level,
      groupValue: minLogLevel,
      onChanged: (value) {
        if (value != null) {
          ref.read(logFilterProvider.notifier).setFilter(value);
        }
      },
      child: Text(level.name.toUpperCase()),
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.event});

  final OutputEvent event;

  @override
  Widget build(BuildContext context) {
    final logEvent = event.origin;

    final level = logEvent.level;
    final message = logEvent.message?.toString() ?? '';
    final error = logEvent.error?.toString();
    final stackTrace = logEvent.stackTrace?.toString();
    final time = logEvent.time;

    final iconData = _levelIcon(level);
    final iconColor = _levelColor(level);
    final backgroundColor = _levelBackgroundColor(level, context);

    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: InkWell(
        onTap: () async {
          await showLogDetailsDialog(
            context,
            level: level,
            message: message,
            error: error,
            stackTrace: stackTrace,
            time: time,
          );
        },
        child: ListTile(
          leading: Icon(iconData, color: iconColor, size: 24),
          title: Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.robotoMono(fontSize: 12),
          ),
          subtitle: _buildTime(time, context),
        ),
      ),
    );
  }

  Widget? _buildTime(DateTime? time, BuildContext context) {
    if (time == null) return null;

    return Text(
      timeago.format(time),
      style: TextStyle(
        fontSize: 10,
        fontStyle: FontStyle.italic,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
