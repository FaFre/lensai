import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/content_block/data/models/host.dart';
import 'package:lensai/features/content_block/domain/providers.dart';
import 'package:lensai/features/content_block/domain/repositories/sync.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/presentation/controllers/save_settings.dart';
import 'package:lensai/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:lensai/features/settings/presentation/widgets/sync_details_table.dart';

class HostListTile extends HookConsumerWidget {
  final bool enabled;

  final bool enableContentBlocking;
  final Set<HostSource> enableHostLists;
  final HostSource source;

  final String title;
  final String subtitle;

  const HostListTile({
    required this.enableContentBlocking,
    required this.enableHostLists,
    required this.source,
    required this.title,
    required this.subtitle,
    this.enabled = true,
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = enableHostLists.contains(source);

    final lastSync = ref.watch(
      lastSyncOfSourceProvider(source).select((value) => value.valueOrNull),
    );

    final count = ref.watch(
      hostCountOfSourceProvider(source).select((value) => value.valueOrNull),
    );

    Future<void> toggleHostLists(HostSource source) async {
      final lists = enabled
          ? ({...enableHostLists}..remove(source))
          : {...enableHostLists, source};

      await ref.read(saveSettingsControllerProvider.notifier).save(
            (currentSettings) => currentSettings.copyWith.enableHostList(lists),
          );
    }

    return CustomListTile(
      enabled: enableContentBlocking,
      title: title,
      subtitle: subtitle,
      prefix: Checkbox.adaptive(
        value: enableHostLists.contains(source),
        onChanged: enableContentBlocking
            ? (_) async {
                await toggleHostLists(source);
              }
            : null,
      ),
      suffix: FilledButton.icon(
        onPressed: (enabled && enableContentBlocking)
            ? () async {
                await ref
                    .read(hostSyncRepositoryProvider.notifier)
                    .syncHostSource(source, null);
              }
            : null,
        icon: const Icon(Icons.sync),
        label: const Text('Sync'),
      ),
      content: (enabled && enableContentBlocking)
          ? Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SyncDetailsTable(count, lastSync),
            )
          : null,
    );
  }
}
