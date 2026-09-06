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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

final _wildcardHostRegex = RegExp(r'^\*\.([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,63}$');

/// Parses a user-entered site-assignment value. Accepts:
/// - `example.com`, `https://example.com/path` → exact origin entry
/// - `*.example.com`, `https://*.example.com` → wildcard entry for all
///   subdomains (and the apex) of `example.com`
Uri? _parseSiteAssignmentInput(String? input) {
  if (input == null) return null;
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  // Strip scheme for wildcard detection.
  var rest = trimmed;
  var scheme = 'https';
  final schemeMatch = RegExp(
    r'^(https?):\/\/',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (schemeMatch != null) {
    scheme = schemeMatch.group(1)!.toLowerCase();
    rest = trimmed.substring(schemeMatch.end);
  }

  // Extract host portion (up to first path/query/fragment/port separator).
  final hostEnd = rest.indexOf(RegExp(r'[\/?#:]'));
  final host = (hostEnd == -1 ? rest : rest.substring(0, hostEnd))
      .toLowerCase();

  if (host.startsWith('*.')) {
    if (!_wildcardHostRegex.hasMatch(host)) return null;
    return Uri(scheme: scheme, host: host);
  }

  final parsed = parseValidatedUrl(
    trimmed,
    eagerParsing: true,
    onlyHttpProtocol: true,
  );
  if (parsed == null) return null;
  return Uri.parse(parsed.origin);
}

class ContainerSitesScreen extends HookConsumerWidget {
  final Set<Uri> initialSites;

  const ContainerSitesScreen({super.key, required this.initialSites});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textController = useTextEditingController();

    final sites = useState(initialSites);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.pop(result ?? sites.value);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            onPressed: () {
              context.pop(sites.value);
            },
          ),
          title: const Text('Site Assignments'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    decoration: InputDecoration(
                      label: const Text('Add Site'),
                      hintText: 'example.com or *.example.com',
                      helperText: 'Use *.example.com to match all subdomains',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffix: TextButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() == true) {
                            formKey.currentState?.save();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ),
                    controller: textController,
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'URL must be provided';
                      }

                      final entry = _parseSiteAssignmentInput(value);
                      if (entry == null) {
                        return 'Invalid URL';
                      }

                      if (sites.value.contains(entry)) {
                        return 'This site has been already assigned';
                      }

                      return null;
                    },
                    onSaved: (newValue) async {
                      final entry = _parseSiteAssignmentInput(newValue);
                      if (entry == null) {
                        return;
                      }

                      // Read once up front: the lookups below are database
                      // round trips, and the screen can be popped while they
                      // are in flight — a `WidgetRef` throws after that.
                      final containerRepository = ref.read(
                        containerRepositoryProvider.notifier,
                      );

                      // Exact-origin duplicate detection — wildcard overlaps
                      // with existing entries are the user's intent and are
                      // not flagged here.
                      final isAssigned =
                          !isWildcardSite(entry) &&
                          await containerRepository.isSiteAssignedToContainer(
                            entry,
                          );

                      if (!isAssigned) {
                        sites.value = {...sites.value, entry};
                      } else {
                        final assignedContainerId = await containerRepository
                            .siteAssignedContainerId(entry);
                        final assignedContainer = await assignedContainerId
                            .mapNotNull(containerRepository.getContainerData);

                        if (context.mounted) {
                          ui_helper.showErrorMessage(
                            context,
                            (assignedContainer?.name.isNotEmpty ?? false)
                                ? '$entry has already been assigned to container "${assignedContainer?.name}"'
                                : '$entry has already been assigned to another container',
                          );
                        }
                      }

                      textController.clear();
                    },
                    onFieldSubmitted: (_) {
                      if (formKey.currentState?.validate() == true) {
                        formKey.currentState?.save();
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sites.value.length,
                  itemBuilder: (context, index) {
                    final site = sites.value.elementAt(index);

                    return ListTile(
                      leading: UrlIcon([site], iconSize: 20),
                      title: Text(
                        site.host,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(site.toString()),
                      trailing: IconButton(
                        onPressed: () {
                          sites.value = {...sites.value}..remove(site);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
