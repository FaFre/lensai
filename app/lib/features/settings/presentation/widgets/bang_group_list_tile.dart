import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/bangs/data/models/bang.dart';
import 'package:lensai/features/bangs/domain/providers.dart';
import 'package:lensai/features/bangs/domain/repositories/sync.dart';
import 'package:lensai/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:lensai/features/settings/presentation/widgets/sync_details_table.dart';

class BangGroupListTile extends HookConsumerWidget {
  final BangGroup group;

  final String title;
  final String subtitle;

  const BangGroupListTile({
    required this.group,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastSync = ref.watch(
      lastSyncOfGroupProvider(group).select((value) => value.valueOrNull),
    );

    final count = ref.watch(
      bangCountOfGroupProvider(group).select((value) => value.valueOrNull),
    );

    return CustomListTile(
      title: title,
      subtitle: subtitle,
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SyncDetailsTable(count, lastSync),
      ),
      suffix: FilledButton.icon(
        onPressed: () async {
          await ref
              .read(bangSyncRepositoryProvider.notifier)
              .syncBangGroup(group, null);
        },
        icon: const Icon(Icons.sync),
        label: const Text('Sync'),
      ),
    );
  }
}
