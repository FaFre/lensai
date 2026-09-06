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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/features/addons/domain/providers.dart';
import 'package:weblibre/features/addons/presentation/widgets/addon_listing_card.dart';
import 'package:weblibre/features/addons/utils/permissions.dart';
import 'package:weblibre/utils/number_format.dart';
import 'package:weblibre/utils/ui_helper.dart';

class AddonListingDetailsScreen extends ConsumerWidget {
  final AddonListing listing;

  const AddonListingDetailsScreen({required this.listing, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final installedAsync = ref.watch(addonListProvider);

    final isInstalled = installedAsync.maybeWhen(
      data: (addons) => addons.any((a) => a.id == listing.id && a.isInstalled),
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(title: Text(listing.name)),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AddonListingIcon(iconUrl: listing.iconUrl, size: 64),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(listing.name, style: theme.textTheme.titleLarge),
                          if (listing.authorName != null) ...[
                            const SizedBox(height: 4),
                            _AuthorLink(
                              name: listing.authorName!,
                              url: listing.authorUrl,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Version ${listing.latestVersion}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InstallButton(listing: listing, isInstalled: isInstalled),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    if (listing.promoted == AddonStorePromoted.recommended)
                      const Chip(
                        avatar: Icon(Icons.verified, size: 16),
                        label: Text('Recommended'),
                      ),
                    if (listing.ratingAverage != null)
                      Chip(
                        avatar: const Icon(Icons.star, size: 16),
                        label: Text(
                          '${listing.ratingAverage!.toStringAsFixed(1)}'
                          '${listing.ratingReviews != null ? ' (${formatCompactNumber(listing.ratingReviews!)})' : ''}',
                        ),
                      ),
                    if (listing.averageDailyUsers != null)
                      Chip(
                        avatar: const Icon(Icons.group_outlined, size: 16),
                        label: Text(
                          '${formatCompactNumber(listing.averageDailyUsers!)} users',
                        ),
                      ),
                  ],
                ),
                if (listing.previews.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _ScreenshotsSection(previews: listing.previews),
                ],
                if ((listing.summary ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(listing.summary!, style: theme.textTheme.bodyLarge),
                ],
                if ((listing.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'About this extension'),
                  const SizedBox(height: 8),
                  _ExpandableDescription(html: listing.description!),
                ],
                if (_hasFriendlyPermissions(listing)) ...[
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Permissions'),
                  const SizedBox(height: 8),
                  _PermissionsSection(listing: listing),
                ],
                if (_hasTechnicalPermissions(listing)) ...[
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Technical permissions'),
                  const SizedBox(height: 8),
                  _TechnicalPermissionsSection(listing: listing),
                ],
                const SizedBox(height: 24),
                const _SectionHeader(title: 'More information'),
                const SizedBox(height: 8),
                _MoreInformationSection(listing: listing),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _AuthorLink extends StatelessWidget {
  final String name;
  final String? url;

  const _AuthorLink({required this.name, required this.url});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    if (url == null) return Text('by $name', style: style);
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url!)),
      child: Text(
        'by $name',
        style: style?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class _InstallButton extends ConsumerWidget {
  final AddonListing listing;
  final bool isInstalled;

  const _InstallButton({required this.listing, required this.isInstalled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(addonBusyIdsProvider).contains(listing.id);

    if (isInstalled) {
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check),
        label: const Text('Installed'),
      );
    }

    return FilledButton.icon(
      onPressed: busy
          ? null
          : () async {
              // Busy flag and invalidations belong to the provider, not to
              // this button: leaving the screen mid-install used to reach a
              // `WidgetRef` whose widget was already gone.
              try {
                await ref
                    .read(addonListProvider.notifier)
                    .installListing(listing);
                if (!context.mounted) return;
                showInfoMessage(context, '${listing.name} installed');
              } catch (error) {
                if (!context.mounted) return;
                showInfoMessage(context, 'Install failed: $error');
              }
            },
      icon: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download_outlined),
      label: const Text('Install'),
    );
  }
}

class _ScreenshotsSection extends StatelessWidget {
  final List<AddonListingPreview> previews;
  const _ScreenshotsSection({required this.previews});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: FadingScroll(
        fadingSize: 15,
        builder: (context, controller) {
          return ListView.separated(
            controller: controller,
            scrollDirection: Axis.horizontal,
            itemCount: previews.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final p = previews[index];
              return GestureDetector(
                onTap: () => showDialog<void>(
                  context: context,
                  barrierColor: Colors.black87,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.zero,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: InteractiveViewer(
                        child: Hero(
                          tag: p.imageUrl,
                          child: Image.network(p.imageUrl, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Hero(
                    tag: p.imageUrl,
                    child: Image.network(
                      p.thumbnailUrl ?? p.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 300,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ExpandableDescription extends HookConsumerWidget {
  final String html;
  const _ExpandableDescription({required this.html});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);
    final markdownAsync = ref.watch(addonHtmlMarkdownProvider(html));
    final body = markdownAsync.when(
      skipLoadingOnReload: true,
      data: (markdown) => MarkdownBody(
        data: markdown.isEmpty ? html : markdown,
        onTapLink: (_, href, _) async {
          if (href != null) await launchUrl(Uri.parse(href));
        },
      ),
      loading: () => Text(html),
      error: (_, _) => Text(html),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: expanded.value ? double.infinity : 160,
            ),
            child: ShaderMask(
              shaderCallback: (bounds) {
                if (expanded.value) {
                  return const LinearGradient(
                    colors: [Colors.black, Colors.black],
                  ).createShader(bounds);
                }
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.black, Colors.transparent],
                  stops: [0.0, 0.75, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: body,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => expanded.value = !expanded.value,
          child: Text(expanded.value ? 'Show less' : 'Read more'),
        ),
      ],
    );
  }
}

typedef _PermissionGroup = ({String title, List<String> perms});

class _PermissionsSection extends StatelessWidget {
  final AddonListing listing;
  const _PermissionsSection({required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Widget>[];

    final groups = <_PermissionGroup>[
      (title: 'Required', perms: listing.permissions),
      (title: 'Websites', perms: listing.hostPermissions),
      (title: 'Optional', perms: listing.optionalPermissions),
      (title: 'Data collection', perms: listing.dataCollectionPermissions),
    ];

    for (final group in groups) {
      final friendly = group.perms
          .map(describePermission)
          .where((d) => !d.technical)
          .toList();
      if (friendly.isEmpty) continue;
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(group.title, style: theme.textTheme.titleSmall),
        ),
      );
      for (final d in friendly) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('\u2022  ${d.text}', style: theme.textTheme.bodyMedium),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }
}

class _TechnicalPermissionsSection extends StatelessWidget {
  final AddonListing listing;
  const _TechnicalPermissionsSection({required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Widget>[];

    final groups = <_PermissionGroup>[
      (title: 'Required', perms: listing.permissions),
      (title: 'Websites', perms: listing.hostPermissions),
      (title: 'Optional', perms: listing.optionalPermissions),
      (title: 'Data collection', perms: listing.dataCollectionPermissions),
    ];

    final monoStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) - 1,
      color: theme.colorScheme.onSurfaceVariant,
    );

    for (final group in groups) {
      final technical = group.perms
          .map(describePermission)
          .where((d) => d.technical)
          .toList();
      if (technical.isEmpty) continue;
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(group.title, style: theme.textTheme.titleSmall),
        ),
      );
      for (final d in technical) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: '\u2022  '),
                  TextSpan(text: d.text, style: monoStyle),
                ],
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }
}

bool _hasTechnicalPermissions(AddonListing l) {
  bool any(List<String> list) =>
      list.any((p) => describePermission(p).technical);
  return any(l.permissions) ||
      any(l.hostPermissions) ||
      any(l.optionalPermissions) ||
      any(l.dataCollectionPermissions);
}

bool _hasFriendlyPermissions(AddonListing l) {
  bool any(List<String> list) =>
      list.any((p) => !describePermission(p).technical);
  return any(l.permissions) ||
      any(l.hostPermissions) ||
      any(l.optionalPermissions) ||
      any(l.dataCollectionPermissions);
}

class _MoreInformationSection extends StatelessWidget {
  final AddonListing listing;
  const _MoreInformationSection({required this.listing});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    rows.add(_InfoRow(label: 'Version', value: listing.latestVersion));

    if (listing.fileSize != null) {
      rows.add(_InfoRow(label: 'Size', value: formatBytes(listing.fileSize!)));
    }

    if (listing.lastUpdated != null) {
      rows.add(
        _InfoRow(
          label: 'Last updated',
          value: formatIsoDate(listing.lastUpdated!),
        ),
      );
    }

    if (listing.categories.isNotEmpty) {
      rows.add(
        _InfoRow(label: 'Categories', value: listing.categories.join(', ')),
      );
    }

    if (listing.licenseName != null) {
      rows.add(
        _InfoRow(
          label: 'License',
          value: listing.licenseName!,
          url: listing.licenseUrl,
        ),
      );
    }

    final links = <Widget>[];
    if (listing.homepageUrl != null) {
      links.add(
        _LinkTile(
          icon: Icons.home_outlined,
          label: 'Homepage',
          url: listing.homepageUrl!,
        ),
      );
    }
    if (listing.supportUrl != null) {
      links.add(
        _LinkTile(
          icon: Icons.help_outline,
          label: 'Support site',
          url: listing.supportUrl!,
        ),
      );
    }
    if (listing.supportEmail != null) {
      links.add(
        _LinkTile(
          icon: Icons.email_outlined,
          label: listing.supportEmail!,
          url: 'mailto:${listing.supportEmail!}',
        ),
      );
    }
    links.add(
      _LinkTile(
        icon: Icons.public,
        label: 'View on addons.mozilla.org',
        url: listing.detailUrl,
      ),
    );
    if (listing.ratingUrl != null) {
      links.add(
        _LinkTile(
          icon: Icons.reviews_outlined,
          label: 'Reviews',
          url: listing.ratingUrl!,
        ),
      );
    }
    if (listing.hasPrivacyPolicy && listing.slug != null) {
      links.add(
        _LinkTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy policy',
          url: 'https://addons.mozilla.org/addon/${listing.slug}/privacy/',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...rows, const SizedBox(height: 8), ...links],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? url;

  const _InfoRow({required this.label, required this.value, this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueWidget = url != null
        ? InkWell(
            onTap: () => launchUrl(Uri.parse(url!)),
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        : Text(value, style: theme.textTheme.bodyMedium);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _LinkTile({required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => launchUrl(Uri.parse(url)),
    );
  }
}
