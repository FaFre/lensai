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
import 'dart:async';

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/web_search_bang.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/providers/search.dart';
import 'package:weblibre/features/bangs/domain/services/bang_query.dart';
import 'package:weblibre/features/bangs/domain/services/reverse_match.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_autofocus.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/animated_tab_type_switcher.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/clipboard_fill.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/module_surface_scope.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/module_surface_slivers.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_field.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_module_reorder_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/bookmark_search.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/combined_history_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/feed_search.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/history_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/local_history_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/popular_sites_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_providers_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_term_suggestions_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/tab_search.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/compact_container_selector.dart';
import 'package:weblibre/features/proxy/presentation/controllers/ensure_proxy_started.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/features/web_search/presentation/open_in_new_tab.dart';
import 'package:weblibre/features/web_search/presentation/widgets/route_through_tor_toggle.dart';
import 'package:weblibre/features/web_search/presentation/widgets/search_filter_chips.dart';
import 'package:weblibre/features/web_search/presentation/widgets/search_mode_selector.dart';
import 'package:weblibre/features/web_search/presentation/widgets/web_search_results_section.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';
import 'package:weblibre/presentation/hooks/sampled_value_notifier.dart';
import 'package:weblibre/utils/input_classification.dart';
import 'package:weblibre/utils/text_field_line_count.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class SearchScreen extends HookConsumerWidget {
  final String? initialSearchText;
  final TabType tabType;
  final bool launchedFromIntent;
  final bool autoSubmitSearch;

  /// When provided, URLs will be loaded into this existing tab.
  /// When null, a new tab will be created.
  final String? tabId;

  const SearchScreen({
    super.key,
    required this.initialSearchText,
    required this.tabType,
    this.launchedFromIntent = false,
    this.autoSubmitSearch = false,
    this.tabId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final createChildTabsOption = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.createChildTabsOption,
      ),
    );
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    final initialTabType =
        !settings.showIsolatedTabUi && tabType == TabType.isolated
        ? TabType.regular
        : tabType;

    final selectedTabType = useState(initialTabType);
    final currentTabTabType = ref.watch(selectedTabTypeProvider);

    useEffect(() {
      if (!settings.showIsolatedTabUi &&
          selectedTabType.value == TabType.isolated) {
        selectedTabType.value = TabType.regular;
      }
      return null;
    }, [settings.showIsolatedTabUi]);

    final selectedContainer = ref.watch(
      selectedContainerDataProvider.select((value) => value.value),
    );

    // When editing an existing tab, get its state
    // If tab no longer exists (null), fall back to new tab mode
    final existingTabState = tabId != null
        ? ref.watch(tabStateProvider(tabId))
        : null;

    // Determine if we're in edit mode (tabId provided AND tab still exists)
    final isEditMode = tabId != null && existingTabState != null;

    final effectiveTabMode = isEditMode
        ? existingTabState.tabMode
        : switch (selectedTabType.value) {
            TabType.regular => TabMode.regular,
            TabType.private => TabMode.private,
            TabType.isolated => TabMode.newIsolated(),
            TabType.child => switch (currentTabTabType) {
              TabType.private => TabMode.private,
              TabType.isolated => TabMode.isolated(
                ref.watch(selectedTabStateProvider)?.isolationContextId ??
                    newIsolatedContextId(),
              ),
              _ => TabMode.regular,
            },
          };

    final privateTabMode = effectiveTabMode is PrivateTabMode;

    final previousWebSearchQuery = ref.watch(
      metaSearchControllerProvider.select((s) {
        if (s.status != WebSearchStatus.idle && s.query.isNotEmpty) {
          return s.query;
        }
        return null;
      }),
    );

    final searchTextController = useTextEditingController(
      text: initialSearchText ?? previousWebSearchQuery,
    );
    final sampledSearchText = useSampledValueNotifier(
      source: searchTextController,
      sampleDuration: const Duration(milliseconds: 150),
    );
    final hasUserProvidedInput = useState(
      initialSearchText?.isNotEmpty == true || previousWebSearchQuery != null,
    );

    // Track if we started with a URL (edit mode) to show empty state initially
    final startedWithUrl = useMemoized(() {
      if (initialSearchText == null || initialSearchText!.isEmpty) return false;
      return classifyAddressBarInput(initialSearchText!)
          is NavigateInputClassification;
    });
    final hasUserModifiedInput = useState(false);
    final isUrlInput = useState(false);
    final isEditingAfterSearch = useState(false);

    // Holds the original URL when reverse bang-matching has swapped the
    // address-bar text for an extracted query. First tap of the clear button
    // restores this URL; a subsequent tap clears the field normally.
    final revertUrl = useState<String?>(null);
    final reverseMatchedQuery = useState<String?>(null);

    useOnListenableChangeSelector(
      searchTextController,
      () => searchTextController.text,
      () {
        final text = searchTextController.text;
        hasUserProvidedInput.value = text.isNotEmpty;

        // Keeps the address bar's provider icon in step with a bang the user
        // is typing. Submitting resolves again from the submitted text, so a
        // lookup still in flight here can never decide where a search goes.
        unawaited(ref.read(inlineBangProvider.notifier).resolve(text));

        final metaState = ref.read(metaSearchControllerProvider);

        if (text.isEmpty && metaState.status != WebSearchStatus.idle) {
          ref.read(metaSearchControllerProvider.notifier).reset();
        } else if (metaState.status != WebSearchStatus.idle) {
          isEditingAfterSearch.value = text != metaState.query;
        }

        if (startedWithUrl) {
          hasUserModifiedInput.value = text != initialSearchText;
        }
        isUrlInput.value =
            text.isNotEmpty &&
            classifyAddressBarInput(text) is NavigateInputClassification;
      },
    );

    // Keep isEditingAfterSearch in sync when meta search state changes
    // (e.g. after submit/ready transitions), not just on text changes.
    ref.listen(metaSearchControllerProvider, (_, next) {
      if (next.status == WebSearchStatus.idle) {
        isEditingAfterSearch.value = false;
      } else {
        isEditingAfterSearch.value = searchTextController.text != next.query;
      }
    });

    final showNoInputSections =
        (startedWithUrl && !hasUserModifiedInput.value) ||
        (!hasUserProvidedInput.value && searchTextController.text.isEmpty);

    final searchFocusNode = useFocusNode();
    final pauseTime = useRef<DateTime?>(null);
    final textFieldKey = useMemoized(() => GlobalKey());
    final preferredHeight = useState<double>(kToolbarHeight);

    useOnListenableChangeSelector(
      searchFocusNode,
      () => searchFocusNode.hasFocus,
      () {
        if (searchFocusNode.hasFocus &&
            (isEditMode || previousWebSearchQuery != null)) {
          searchTextController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: searchTextController.text.length,
          );
        }
      },
    );

    useEffect(() {
      if (isEditMode || previousWebSearchQuery != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          searchTextController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: searchTextController.text.length,
          );
        });
      }
      return null;
    }, []);

    // Try to recognise the current URL as a bang search. If a bang matches,
    // swap the URL for its extracted query and pre-select the bang so the
    // user can refine the search instead of editing the raw URL.
    useEffect(() {
      if (!startedWithUrl || initialSearchText == null) return null;
      final uri = Uri.tryParse(initialSearchText!);
      if (uri == null) return null;

      unawaited(() async {
        final match = await ref
            .read(reverseBangMatcherProvider.notifier)
            .match(uri);
        if (!context.mounted) return;
        if (match == null) return;
        // Bail out if the user has already started editing while we matched.
        if (searchTextController.text != initialSearchText) return;

        revertUrl.value = initialSearchText;
        reverseMatchedQuery.value = match.query;
        searchTextController.value = TextEditingValue(
          text: match.query,
          selection: TextSelection(
            baseOffset: 0,
            extentOffset: match.query.length,
          ),
        );
        // Mutual exclusion: clear any site-scoped selection so the global
        // auto-match isn't hidden behind a stale site bang (mirrors the
        // SmartBangSelector selection logic).
        final tabHost = existingTabState?.url.host;
        if (tabHost != null && tabHost.isNotEmpty) {
          ref
              .read(selectedBangTriggerProvider(domain: tabHost).notifier)
              .clearTrigger();
        }
        ref
            .read(selectedBangTriggerProvider().notifier)
            .setTrigger(match.bang.toKey());
      }());

      return null;
    }, []);

    //Request initial focus in a way our useOnListenableChangeSelector is triggered
    useEffect(() {
      if (ref.read(searchAutofocusSuppressionProvider)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(searchAutofocusSuppressionProvider.notifier).clear();
        });

        return null;
      }

      //Wait for first frame then request focus
      unawaited(
        Future.delayed(const Duration(milliseconds: 1000 ~/ 60)).whenComplete(
          () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              searchFocusNode.requestFocus();
            });
          },
        ),
      );

      return null;
    }, []);

    Future<void> measureHeightWithRetry() async {
      const delays = [25, 50, 75, 100];

      for (final delay in delays) {
        await Future.delayed(Duration(milliseconds: delay));
        final measuredHeight = getTextFieldHeight(textFieldKey);

        if (measuredHeight != null) {
          // Add 2px to account for SearchField container border
          preferredHeight.value = measuredHeight + 2;
          return;
        }
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        measureHeightWithRetry(); // ignore: discarded_futures
      });

      return null;
    }, [textFieldKey, isEditMode]);

    useOnListenableChangeSelector(
      isEditMode ? searchTextController : null,
      () => searchTextController.text,
      () {
        measureHeightWithRetry(); // ignore: discarded_futures
      },
    );

    useOnAppLifecycleStateChange((previous, current) {
      switch (current) {
        case AppLifecycleState.hidden:
        case AppLifecycleState.paused:
          //Fixes issue with disappearing keyboard after resume (even we request focus)
          searchFocusNode.unfocus();
          pauseTime.value ??= DateTime.now();
        case AppLifecycleState.inactive:
        case AppLifecycleState.detached:
          // Transient focus loss (IME input-method picker via long-press
          // spacebar, notification shade, split-screen) reports `inactive`
          // while the field is still visible. Unfocusing here would tear down
          // the input connection and dismiss the keyboard/picker, so leave
          // focus untouched and only react to genuine backgrounding above.
          break;
        case AppLifecycleState.resumed:
          if (pauseTime.value == null ||
              DateTime.now().difference(pauseTime.value!) <
                  const Duration(minutes: 1)) {
            pauseTime.value = null;
            break;
          }

          pauseTime.value = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            searchFocusNode.requestFocus();
          });
      }
    });

    final defaultSearchBang = ref.watch(
      defaultSearchBangDataProvider.select((value) => value.value),
    );

    // Watch both selection providers - only one should be set at a time
    // due to mutual exclusion in SmartBangSelector
    final siteSelectedBang = isEditMode
        ? ref.watch(selectedBangDataProvider(domain: existingTabState.url.host))
        : null;
    final globalSelectedBang = ref.watch(selectedBangDataProvider());

    // The active selection is whichever one is set (site takes priority if both somehow set)
    final selectedBang = siteSelectedBang ?? globalSelectedBang;

    // A bang written into the field beats a chip: it is the more explicit and
    // more recent statement of where this one search should go.
    final inlineBang = ref.watch(inlineBangProvider);

    final activeBang = inlineBang?.bang ?? selectedBang ?? defaultSearchBang;

    // The user named a provider for this search instead of falling back to the
    // default. That drives the field's provider icon, and it also settles what
    // enter means: search with that provider, not open the completed URL.
    final showBangIcon = inlineBang != null || selectedBang != null;

    // What the rest of the modules should search for. A resolved bang is an
    // instruction, not a search term, so it is lifted out before bookmarks,
    // history and the rest see the text. An unresolved `!foo` stays put — it
    // is just a word the user typed.
    final sampledQueryText = useValueNotifier(sampledSearchText.value);
    useEffect(() {
      void sync() {
        final value = sampledSearchText.value;
        // Only the text matters downstream; selection and composing belong to
        // the field the user is actually editing.
        sampledQueryText.value = inlineBang == null
            ? value
            : TextEditingValue(text: parseBangInput(value.text).query);
      }

      sync();
      sampledSearchText.addListener(sync);
      return () => sampledSearchText.removeListener(sync);
    }, [sampledSearchText, sampledQueryText, inlineBang]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        measureHeightWithRetry(); // ignore: discarded_futures
      });

      return null;
    }, [showBangIcon]);

    Future<void> openUriInTab(Uri uri, {String? findInPageQuery}) async {
      final String targetTabId;
      if (isEditMode) {
        targetTabId = tabId!;
        await ref
            .read(tabSessionProvider(tabId: targetTabId).notifier)
            .loadUrl(url: uri);
      } else {
        targetTabId = await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: uri,
              tabMode: effectiveTabMode,
              parentId: (selectedTabType.value == TabType.child)
                  ? ref.read(selectedTabProvider)
                  : null,
              launchedFromIntent: launchedFromIntent,
              selectTab: true,
              containerSelection: selectedContainer == null
                  ? const TabContainerSelection.unassigned()
                  : TabContainerSelection.specific(selectedContainer),
            );
      }

      if (findInPageQuery != null && findInPageQuery.isNotEmpty) {
        await ref
            .read(findInPageControllerProvider(targetTabId).notifier)
            .findAll(text: findInPageQuery);
      }

      if (context.mounted) {
        ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
        const BrowserRoute().go(context);
      }
    }

    /// Records the bang search, dispatches to the in-app web search engine for
    /// `wl` and returns null in that case, otherwise returns the resolved URI.
    Future<Uri?> resolveSearchUri(BangData bang, String query) async {
      if (!privateTabMode) {
        await ref
            .read(bangSearchProvider.notifier)
            .triggerBangSearch(bang, query);
      }

      if (isWebSearchBang(bang)) {
        final settings = ref.read(webSearchSettingsControllerProvider);
        await ref
            .read(metaSearchControllerProvider.notifier)
            .submit(
              query,
              mode: settings.searchMode,
              language: settings.language,
              region: settings.region,
              safeSearch: settings.safeSearch,
              timeRange: settings.timeRange,
            );
        return null;
      }

      return bang.getTemplateUrl(query);
    }

    Future<void> submitSearch(String query) async {
      if (formKey.currentState?.validate() != true) {
        return;
      }

      // Suggestion rows carry the typed text forward verbatim, bang and all.
      final inline = await ref.read(inlineBangProvider.notifier).resolve(query);
      final bang = inline?.bang ?? activeBang;

      if (bang == null) {
        return;
      }

      final uri = await resolveSearchUri(bang, inline?.query ?? query);
      if (uri != null) {
        await openUriInTab(uri);
      }
    }

    final autoSubmittedInitialSearch = useRef(false);
    useEffect(() {
      if (!autoSubmitSearch ||
          autoSubmittedInitialSearch.value ||
          initialSearchText == null ||
          initialSearchText!.trim().isEmpty ||
          activeBang == null ||
          !isWebSearchBang(activeBang)) {
        return null;
      }

      autoSubmittedInitialSearch.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(submitSearch(initialSearchText!));
      });

      return null;
    }, [autoSubmitSearch, initialSearchText, activeBang]);

    // Persist the results scroll offset across navigation so returning to
    // the search screen after opening a result restores the user's place
    // instead of jumping back to the top. The offset provider is reset on
    // every fresh submit/reset of the web search controller.
    final scrollController = useScrollController(
      initialScrollOffset: ref.read(webSearchScrollOffsetProvider),
    );
    useEffect(() {
      void listener() {
        if (scrollController.hasClients) {
          ref
              .read(webSearchScrollOffsetProvider.notifier)
              .update(scrollController.offset);
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    // The screen is two surfaces in one: before anything is typed it is the
    // new-tab page, afterwards it is the search results page. They are mutually
    // exclusive, so a single scope covers both.
    final activeSurface = showNoInputSections
        ? ModuleSurface.newTab
        : ModuleSurface.search;

    final reorderActive = ref.watch(searchReorderModeProvider(activeSurface));

    final moduleCallbacks = ModuleSurfaceCallbacks(
      onUriSelected: openUriInTab,
      searchTextController: searchTextController,
      submitSearch: submitSearch,
      onArticleSelected: (article) {
        FeedArticleRoute(articleId: article.id).pushReplacement(context);
      },
      onTabSelected: (tabId) async {
        await ref.read(tabRepositoryProvider.notifier).selectTab(tabId);

        if (context.mounted) {
          ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
          const BrowserRoute().go(context);
        }
      },
      onContainerSelected: (container) async {
        final result = await ref
            .read(selectedContainerProvider.notifier)
            .setContainerId(container.id);

        if (!context.mounted) return;

        if (result == SetContainerResult.success) {
          await ensureProxyStartedForContainer(context, ref, container);
        }

        if (context.mounted && result == SetContainerResult.success) {
          const TabViewRoute().go(context);
        }
      },
    );

    final searchWidgets = <SearchModuleType, Widget>{
      // The bang picker is the one module that wants the raw text: `!g` is
      // what it filters on.
      SearchModuleType.searchProviders: SearchProvidersSection(
        searchTextController: searchTextController,
        domain: isEditMode ? existingTabState.url.host : null,
      ),
      SearchModuleType.searchSuggestions: SearchTermSuggestionsSection(
        searchTextController: searchTextController,
        submitSearch: submitSearch,
      ),
      SearchModuleType.tabs: TabSearch(searchTextListenable: sampledQueryText),
      SearchModuleType.bookmarks: BookmarkSearch(
        searchTextListenable: sampledQueryText,
        onUriSelected: openUriInTab,
      ),
      SearchModuleType.articles: FeedSearch(
        searchTextNotifier: sampledQueryText,
      ),
      SearchModuleType.history: HistorySuggestions(
        searchTextListenable: sampledQueryText,
        onUriSelected: openUriInTab,
      ),
      SearchModuleType.localHistory: LocalHistorySuggestions(
        searchTextListenable: sampledQueryText,
        onUriSelected: openUriInTab,
      ),
      SearchModuleType.combinedHistory: CombinedHistorySuggestions(
        searchTextListenable: sampledQueryText,
        onUriSelected: openUriInTab,
      ),
      SearchModuleType.popularSites: PopularSitesSuggestions(
        searchTextListenable: sampledQueryText,
        onUriSelected: openUriInTab,
      ),
    };

    final searchOrder = ref.watch(
      searchModuleOrderProvider(ModuleSurface.search),
    );

    bool canShowSearchModule(SearchModuleType type) {
      if (!isUrlInput.value) {
        return true;
      }

      return switch (type) {
        SearchModuleType.searchProviders ||
        SearchModuleType.searchSuggestions ||
        SearchModuleType.articles => false,
        _ => true,
      };
    }

    // Whether to surface an in-app close button so the page can be dismissed
    // without a system back button/gesture (opt-in, e.g. for e-ink devices).
    // Only meaningful when there is a route to pop back to.
    final showCloseButton = context.canPop() && settings.showSearchCloseButton;

    // Arranging this surface's sections is a mode on top of the screen, not a
    // route, so back leaves the arrangement before it leaves the screen — the
    // same ladder the "Done" button offers.
    return PopScope(
      canPop: !reorderActive,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref
            .read(searchReorderModeProvider(activeSurface).notifier)
            .deactivate();
      },
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: formKey,
            child: ModuleSurfaceScope(
              surface: activeSurface,
              pinnedHeaderBackgroundColor: Theme.of(context).canvasColor,
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    leading: showCloseButton
                        ? IconButton(
                            tooltip: 'Close',
                            icon: const Icon(Icons.close),
                            onPressed: () => context.pop(),
                          )
                        : null,
                    backgroundColor: colorScheme.surface,
                    scrolledUnderElevation: 0,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    // Collapse the toolbar in edit mode (no tab-type switcher), but
                    // keep it when the close button needs somewhere to render.
                    toolbarHeight: (isEditMode && !showCloseButton)
                        ? 0
                        : kToolbarHeight,
                    titleSpacing: 0.0,
                    title: isEditMode
                        ? null
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Builder(
                              builder: (context) {
                                final tabTypeSwitcher = Focus(
                                  canRequestFocus: false,
                                  child: AnimatedTabTypeSwitcher(
                                    selected: selectedTabType.value,
                                    onChanged: (value) {
                                      selectedTabType.value = value;
                                      // Restore focus to search field after segment change
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            searchFocusNode.requestFocus();
                                          });
                                    },
                                    showChildOption: createChildTabsOption,
                                    showIsolatedOption:
                                        settings.showIsolatedTabUi,
                                    selectedBackgroundColor:
                                        switch (selectedTabType.value) {
                                          TabType.regular => null,
                                          TabType.private =>
                                            appColors.privateSelectionOverlay,
                                          TabType.isolated =>
                                            appColors.isolatedSelectionOverlay,
                                          TabType.child =>
                                            switch (currentTabTabType) {
                                              TabType.private =>
                                                appColors
                                                    .privateSelectionOverlay,
                                              TabType.isolated =>
                                                appColors
                                                    .isolatedSelectionOverlay,
                                              _ => null,
                                            },
                                        },
                                  ),
                                );

                                if (!settings.showContainerUi) {
                                  return Center(
                                    child: Transform.scale(
                                      scale: 1.08,
                                      child: tabTypeSwitcher,
                                    ),
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: tabTypeSwitcher,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: CompactContainerSelector(
                                          selectedContainer: selectedContainer,
                                          emphasizeSelection: false,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(preferredHeight.value),
                      child: SearchField(
                        textFieldKey: textFieldKey,
                        showBangIcon: showBangIcon,
                        explicitBangSelected: showBangIcon,
                        textEditingController: searchTextController,
                        focusNode: searchFocusNode,
                        maxLines: isEditMode ? 3 : 1,
                        privateMode: privateTabMode,
                        label: const Text('Search or enter URL'),
                        unfocusOnTapOutside: false,
                        onClearPressed: () {
                          final url = revertUrl.value;
                          if (url != null &&
                              searchTextController.text ==
                                  reverseMatchedQuery.value) {
                            // First press after a reverse-match swap: restore the
                            // original URL and drop the auto-selected bang. The
                            // user can press again to actually clear.
                            searchTextController.value = TextEditingValue(
                              text: url,
                              selection: TextSelection(
                                baseOffset: 0,
                                extentOffset: url.length,
                              ),
                            );
                            revertUrl.value = null;
                            reverseMatchedQuery.value = null;
                            ref
                                .read(selectedBangTriggerProvider().notifier)
                                .clearTrigger();
                          } else {
                            revertUrl.value = null;
                            reverseMatchedQuery.value = null;
                            searchTextController.clear();
                          }
                        },
                        onSubmitted: (value) async {
                          if (value.isEmpty) return;

                          switch (classifyAddressBarInput(value)) {
                            case NavigateInputClassification(:final uri):
                              await openUriInTab(uri);
                            case SearchInputClassification(:final query):
                              // Resolved from the submitted text rather than the
                              // provider's state so a lookup still in flight for
                              // the last keystroke cannot misroute the search.
                              final inline = await ref
                                  .read(inlineBangProvider.notifier)
                                  .resolve(query);

                              // Read from both providers - use site if set, otherwise global
                              final siteBang = isEditMode
                                  ? ref.read(
                                      selectedBangDataProvider(
                                        domain: existingTabState.url.host,
                                      ),
                                    )
                                  : null;
                              final globalBang = ref.read(
                                selectedBangDataProvider(),
                              );
                              final bang =
                                  inline?.bang ??
                                  siteBang ??
                                  globalBang ??
                                  await ref.read(
                                    defaultSearchBangProvider.future,
                                  );

                              if (bang == null) return;

                              // `!g` on its own carries no query, which every
                              // bang already reads as "open the site itself".
                              final uri = await resolveSearchUri(
                                bang,
                                inline?.query ?? query,
                              );
                              if (uri == null) {
                                // Web search dispatched in-app; reset edit state.
                                isEditingAfterSearch.value = false;
                                return;
                              }
                              await openUriInTab(uri);
                            case InvalidInputClassification():
                              if (context.mounted) {
                                ui_helper.showErrorMessage(
                                  context,
                                  'Invalid address',
                                );
                              }
                          }
                        },
                        activeBang: activeBang,
                        showSuggestions: true,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ClipboardFillLink(controller: searchTextController),
                  ),
                  if (isWebSearchBang(activeBang))
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _WebSearchOptionsRow(),
                            WebSearchTorBootstrapProgress(),
                          ],
                        ),
                      ),
                    ),
                  if (reorderActive)
                    SearchModuleReorderView(surface: activeSurface)
                  else if (isWebSearchBang(activeBang) &&
                      ref.watch(
                        metaSearchControllerProvider.select(
                          (s) =>
                              s.status != WebSearchStatus.idle ||
                              s.query.isNotEmpty,
                        ),
                      )) ...[
                    // Once a web search has been dispatched, the screen shows
                    // the fetched results only — search suggestions and search
                    // providers belong to the normal search page, not the
                    // results view.
                    WebSearchResultsSection(
                      resolveOpenTarget: () => WebSearchOpenTarget(
                        tabMode: effectiveTabMode,
                        containerSelection: selectedContainer == null
                            ? const TabContainerSelection.unassigned()
                            : TabContainerSelection.specific(selectedContainer),
                        parentId: (selectedTabType.value == TabType.child)
                            ? ref.read(selectedTabProvider)
                            : null,
                      ),
                    ),
                  ] else if (showNoInputSections)
                    ModuleSurfaceSliverList(
                      surface: ModuleSurface.newTab,
                      callbacks: moduleCallbacks,
                    )
                  else ...[
                    for (final entry in searchOrder)
                      if (searchWidgets.containsKey(entry.type) &&
                          entry.visible &&
                          canShowSearchModule(entry.type))
                        searchWidgets[entry.type]!,
                    const CustomizeSectionsButton(
                      surface: ModuleSurface.search,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrollable row of web-search filter pills.
///
/// Order: Tor toggle first (always-visible safety control), then search
/// mode, then the locale/freshness/safety filter pills. The row itself
/// scrolls horizontally — adding more chips later doesn't break the
/// layout on narrow screens.
class _WebSearchOptionsRow extends StatelessWidget {
  const _WebSearchOptionsRow();

  @override
  Widget build(BuildContext context) {
    return FadingScroll(
      fadingSize: 15,
      builder: (context, controller) {
        return SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: const Row(
            children: [
              WebSearchStatusChip(),
              RouteThroughTorToggle(),
              SizedBox(width: 8),
              SearchModeSelector(),
              SizedBox(width: 8),
              LanguageSelector(),
              SizedBox(width: 8),
              CountrySelector(),
              SizedBox(width: 8),
              FreshnessSelector(),
              SizedBox(width: 8),
              SafeSearchSelector(),
            ],
          ),
        );
      },
    );
  }
}
