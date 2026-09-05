// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $aboutRoute,
  $onboardingRoute,
  $lockRoute,
  $bangMenuRoute,
  $bookmarksRoute,
  $browserRoute,
  $addonManagerRoute,
  $feedListRoute,
  $historyRoute,
  $profileListRoute,
  $settingsRoute,
  $torProxyRoute,
];

RouteBase get $aboutRoute => GoRouteData.$route(
  path: '/about',
  name: 'AboutRoute',
  hasOverriddenOnExit: false,
  factory: $AboutRoute._fromState,
);

mixin $AboutRoute on GoRouteData {
  static AboutRoute _fromState(GoRouterState state) => AboutRoute();

  @override
  String get location => GoRouteData.$location('/about');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingRoute => GoRouteData.$route(
  path: '/onboarding/:currentRevision/:targetRevision',
  name: 'OnboardingRoute',
  hasOverriddenOnExit: false,
  factory: $OnboardingRoute._fromState,
);

mixin $OnboardingRoute on GoRouteData {
  static OnboardingRoute _fromState(GoRouterState state) => OnboardingRoute(
    currentRevision: int.parse(state.pathParameters['currentRevision']!),
    targetRevision: int.parse(state.pathParameters['targetRevision']!),
  );

  OnboardingRoute get _self => this as OnboardingRoute;

  @override
  String get location => GoRouteData.$location(
    '/onboarding/${Uri.encodeComponent(_self.currentRevision.toString())}/${Uri.encodeComponent(_self.targetRevision.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $lockRoute => GoRouteData.$route(
  path: '/lock',
  name: 'LockRoute',
  hasOverriddenOnExit: false,
  factory: $LockRoute._fromState,
);

mixin $LockRoute on GoRouteData {
  static LockRoute _fromState(GoRouterState state) => const LockRoute();

  @override
  String get location => GoRouteData.$location('/lock');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $bangMenuRoute => GoRouteData.$route(
  path: '/bangs',
  name: 'BangRoute',
  hasOverriddenOnExit: false,
  factory: $BangMenuRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'user',
      name: 'UserBangsRoute',
      hasOverriddenOnExit: false,
      factory: $UserBangsRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'new',
          name: 'NewUserBangRoute',
          hasOverriddenOnExit: false,
          factory: $NewUserBangRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'edit',
          name: 'EditUserBangRoute',
          hasOverriddenOnExit: false,
          factory: $EditUserBangRoute._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: 'search/:searchText',
      name: 'BangSearchRoute',
      hasOverriddenOnExit: false,
      factory: $BangSearchRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'categories',
      name: 'BangCategoriesRoute',
      hasOverriddenOnExit: false,
      factory: $BangCategoriesRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'category/:category',
          name: 'BangCategoryRoute',
          hasOverriddenOnExit: false,
          factory: $BangCategoryRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':subCategory',
              name: 'BangSubCategoryRoute',
              hasOverriddenOnExit: false,
              factory: $BangSubCategoryRoute._fromState,
            ),
          ],
        ),
      ],
    ),
  ],
);

mixin $BangMenuRoute on GoRouteData {
  static BangMenuRoute _fromState(GoRouterState state) => const BangMenuRoute();

  @override
  String get location => GoRouteData.$location('/bangs');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $UserBangsRoute on GoRouteData {
  static UserBangsRoute _fromState(GoRouterState state) =>
      const UserBangsRoute();

  @override
  String get location => GoRouteData.$location('/bangs/user');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NewUserBangRoute on GoRouteData {
  static NewUserBangRoute _fromState(GoRouterState state) =>
      const NewUserBangRoute();

  @override
  String get location => GoRouteData.$location('/bangs/user/new');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $EditUserBangRoute on GoRouteData {
  static EditUserBangRoute _fromState(GoRouterState state) => EditUserBangRoute(
    initialBang: state.uri.queryParameters['initial-bang']!,
    fork:
        _$convertMapValue('fork', state.uri.queryParameters, _$boolConverter) ??
        false,
  );

  EditUserBangRoute get _self => this as EditUserBangRoute;

  @override
  String get location => GoRouteData.$location(
    '/bangs/user/edit',
    queryParams: {
      'initial-bang': _self.initialBang,
      if (_self.fork != false) 'fork': _self.fork.toString(),
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BangSearchRoute on GoRouteData {
  static BangSearchRoute _fromState(GoRouterState state) => BangSearchRoute(
    searchText:
        state.pathParameters['searchText'] ?? BangSearchRoute.emptySearchText,
  );

  BangSearchRoute get _self => this as BangSearchRoute;

  @override
  String get location => GoRouteData.$location(
    '/bangs/search/${Uri.encodeComponent(_self.searchText)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BangCategoriesRoute on GoRouteData {
  static BangCategoriesRoute _fromState(GoRouterState state) =>
      const BangCategoriesRoute();

  @override
  String get location => GoRouteData.$location('/bangs/categories');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BangCategoryRoute on GoRouteData {
  static BangCategoryRoute _fromState(GoRouterState state) =>
      BangCategoryRoute(category: state.pathParameters['category']!);

  BangCategoryRoute get _self => this as BangCategoryRoute;

  @override
  String get location => GoRouteData.$location(
    '/bangs/categories/category/${Uri.encodeComponent(_self.category)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BangSubCategoryRoute on GoRouteData {
  static BangSubCategoryRoute _fromState(GoRouterState state) =>
      BangSubCategoryRoute(
        category: state.pathParameters['category']!,
        subCategory: state.pathParameters['subCategory']!,
      );

  BangSubCategoryRoute get _self => this as BangSubCategoryRoute;

  @override
  String get location => GoRouteData.$location(
    '/bangs/categories/category/${Uri.encodeComponent(_self.category)}/${Uri.encodeComponent(_self.subCategory)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}

RouteBase get $bookmarksRoute => GoRouteData.$route(
  path: '/bookmarks',
  name: 'BookmarksRoute',
  hasOverriddenOnExit: false,
  factory: $BookmarksRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'list/:entryGuid',
      name: 'BookmarkListRoute',
      hasOverriddenOnExit: false,
      factory: $BookmarkListRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'createFolder',
      name: 'BookmarkFolderAddRoute',
      hasOverriddenOnExit: false,
      factory: $BookmarkFolderAddRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'editFolder',
      name: 'BookmarkFolderEditRoute',
      hasOverriddenOnExit: false,
      factory: $BookmarkFolderEditRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'createEntry',
      name: 'BookmarkEntryAddRoute',
      hasOverriddenOnExit: false,
      factory: $BookmarkEntryAddRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'editEntry',
      name: 'BookmarkEntryEditRoute',
      hasOverriddenOnExit: false,
      factory: $BookmarkEntryEditRoute._fromState,
    ),
  ],
);

mixin $BookmarksRoute on GoRouteData {
  static BookmarksRoute _fromState(GoRouterState state) => BookmarksRoute();

  @override
  String get location => GoRouteData.$location('/bookmarks');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BookmarkListRoute on GoRouteData {
  static BookmarkListRoute _fromState(GoRouterState state) =>
      BookmarkListRoute(entryGuid: state.pathParameters['entryGuid']!);

  BookmarkListRoute get _self => this as BookmarkListRoute;

  @override
  String get location => GoRouteData.$location(
    '/bookmarks/list/${Uri.encodeComponent(_self.entryGuid)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BookmarkFolderAddRoute on GoRouteData {
  static BookmarkFolderAddRoute _fromState(GoRouterState state) =>
      BookmarkFolderAddRoute(
        parentGuid: state.uri.queryParameters['parent-guid'],
      );

  BookmarkFolderAddRoute get _self => this as BookmarkFolderAddRoute;

  @override
  String get location => GoRouteData.$location(
    '/bookmarks/createFolder',
    queryParams: {
      if (_self.parentGuid != null) 'parent-guid': _self.parentGuid,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BookmarkFolderEditRoute on GoRouteData {
  static BookmarkFolderEditRoute _fromState(GoRouterState state) =>
      BookmarkFolderEditRoute(folder: state.uri.queryParameters['folder']!);

  BookmarkFolderEditRoute get _self => this as BookmarkFolderEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/bookmarks/editFolder',
    queryParams: {'folder': _self.folder},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BookmarkEntryAddRoute on GoRouteData {
  static BookmarkEntryAddRoute _fromState(GoRouterState state) =>
      BookmarkEntryAddRoute(
        bookmarkInfo: state.uri.queryParameters['bookmark-info']!,
      );

  BookmarkEntryAddRoute get _self => this as BookmarkEntryAddRoute;

  @override
  String get location => GoRouteData.$location(
    '/bookmarks/createEntry',
    queryParams: {'bookmark-info': _self.bookmarkInfo},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BookmarkEntryEditRoute on GoRouteData {
  static BookmarkEntryEditRoute _fromState(GoRouterState state) =>
      BookmarkEntryEditRoute(
        bookmarkEntry: state.uri.queryParameters['bookmark-entry']!,
      );

  BookmarkEntryEditRoute get _self => this as BookmarkEntryEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/bookmarks/editEntry',
    queryParams: {'bookmark-entry': _self.bookmarkEntry},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $browserRoute => GoRouteData.$route(
  path: '/browser',
  name: 'BrowserRoute',
  hasOverriddenOnExit: false,
  factory: $BrowserRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'search/:tabType/:searchText',
      name: 'SearchRoute',
      hasOverriddenOnExit: false,
      factory: $SearchRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'tab_view',
      name: 'TabViewRoute',
      hasOverriddenOnExit: false,
      factory: $TabViewRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'context_menu',
      name: 'ContextMenuRoute',
      hasOverriddenOnExit: false,
      factory: $ContextMenuRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'container_draft',
      name: 'ContainerDraftRoute',
      hasOverriddenOnExit: false,
      factory: $ContainerDraftRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'containers',
      name: 'ContainerListRoute',
      hasOverriddenOnExit: false,
      factory: $ContainerListRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'create/:containerData',
          name: 'ContainerCreateRoute',
          hasOverriddenOnExit: false,
          factory: $ContainerCreateRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'edit/:containerData',
          name: 'ContainerEditRoute',
          hasOverriddenOnExit: false,
          factory: $ContainerEditRoute._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: 'select_container',
      name: 'ContainerSelectionRoute',
      hasOverriddenOnExit: false,
      factory: $ContainerSelectionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'tab_tree/:rootTabId',
      name: 'TabTreeRoute',
      hasOverriddenOnExit: false,
      factory: $TabTreeRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'open_content',
      name: 'OpenSharedContentRoute',
      hasOverriddenOnExit: false,
      factory: $OpenSharedContentRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'profile',
      name: 'SelectProfileRoute',
      hasOverriddenOnExit: false,
      factory: $SelectProfileRoute._fromState,
    ),
  ],
);

mixin $BrowserRoute on GoRouteData {
  static BrowserRoute _fromState(GoRouterState state) => const BrowserRoute();

  @override
  String get location => GoRouteData.$location('/browser');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SearchRoute on GoRouteData {
  static SearchRoute _fromState(GoRouterState state) => SearchRoute(
    tabType: _$TabTypeEnumMap._$fromName(state.pathParameters['tabType']!)!,
    searchText:
        state.pathParameters['searchText'] ?? SearchRoute.emptySearchText,
    launchedFromIntent:
        _$convertMapValue(
          'launched-from-intent',
          state.uri.queryParameters,
          _$boolConverter,
        ) ??
        false,
    autoSubmitSearch:
        _$convertMapValue(
          'auto-submit-search',
          state.uri.queryParameters,
          _$boolConverter,
        ) ??
        false,
    tabId: state.uri.queryParameters['tab-id'],
  );

  SearchRoute get _self => this as SearchRoute;

  @override
  String get location => GoRouteData.$location(
    '/browser/search/${Uri.encodeComponent(_$TabTypeEnumMap[_self.tabType]!)}/${Uri.encodeComponent(_self.searchText)}',
    queryParams: {
      if (_self.launchedFromIntent != false)
        'launched-from-intent': _self.launchedFromIntent.toString(),
      if (_self.autoSubmitSearch != false)
        'auto-submit-search': _self.autoSubmitSearch.toString(),
      if (_self.tabId != null) 'tab-id': _self.tabId,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

const _$TabTypeEnumMap = {
  TabType.regular: 'regular',
  TabType.private: 'private',
  TabType.child: 'child',
  TabType.isolated: 'isolated',
};

mixin $TabViewRoute on GoRouteData {
  static TabViewRoute _fromState(GoRouterState state) => const TabViewRoute();

  @override
  String get location => GoRouteData.$location('/browser/tab_view');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ContextMenuRoute on GoRouteData {
  static ContextMenuRoute _fromState(GoRouterState state) =>
      ContextMenuRoute(hitResult: state.uri.queryParameters['hit-result']!);

  ContextMenuRoute get _self => this as ContextMenuRoute;

  @override
  String get location => GoRouteData.$location(
    '/browser/context_menu',
    queryParams: {'hit-result': _self.hitResult},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ContainerDraftRoute on GoRouteData {
  static ContainerDraftRoute _fromState(GoRouterState state) =>
      const ContainerDraftRoute();

  @override
  String get location => GoRouteData.$location('/browser/container_draft');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ContainerListRoute on GoRouteData {
  static ContainerListRoute _fromState(GoRouterState state) =>
      const ContainerListRoute();

  @override
  String get location => GoRouteData.$location('/browser/containers');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ContainerCreateRoute on GoRouteData {
  static ContainerCreateRoute _fromState(GoRouterState state) =>
      ContainerCreateRoute(
        containerData: state.pathParameters['containerData']!,
        tabIds: state.uri.queryParameters['tab-ids'] ?? '[]',
      );

  ContainerCreateRoute get _self => this as ContainerCreateRoute;

  @override
  String get location => GoRouteData.$location(
    '/browser/containers/create/${Uri.encodeComponent(_self.containerData)}',
    queryParams: {if (_self.tabIds != '[]') 'tab-ids': _self.tabIds},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ContainerEditRoute on GoRouteData {
  static ContainerEditRoute _fromState(GoRouterState state) =>
      ContainerEditRoute(containerData: state.pathParameters['containerData']!);

  ContainerEditRoute get _self => this as ContainerEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/browser/containers/edit/${Uri.encodeComponent(_self.containerData)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ContainerSelectionRoute on GoRouteData {
  static ContainerSelectionRoute _fromState(GoRouterState state) =>
      const ContainerSelectionRoute();

  @override
  String get location => GoRouteData.$location('/browser/select_container');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $TabTreeRoute on GoRouteData {
  static TabTreeRoute _fromState(GoRouterState state) =>
      TabTreeRoute(state.pathParameters['rootTabId']!);

  TabTreeRoute get _self => this as TabTreeRoute;

  @override
  String get location => GoRouteData.$location(
    '/browser/tab_tree/${Uri.encodeComponent(_self.rootTabId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $OpenSharedContentRoute on GoRouteData {
  static OpenSharedContentRoute _fromState(GoRouterState state) =>
      OpenSharedContentRoute(
        sharedUrl: state.uri.queryParameters['shared-url'] ?? 'about:blank',
        contextId: state.uri.queryParameters['context-id'],
        containerMode: state.uri.queryParameters['container-mode'],
      );

  OpenSharedContentRoute get _self => this as OpenSharedContentRoute;

  @override
  String get location => GoRouteData.$location(
    '/browser/open_content',
    queryParams: {
      if (_self.sharedUrl != 'about:blank') 'shared-url': _self.sharedUrl,
      if (_self.contextId != null) 'context-id': _self.contextId,
      if (_self.containerMode != null) 'container-mode': _self.containerMode,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SelectProfileRoute on GoRouteData {
  static SelectProfileRoute _fromState(GoRouterState state) =>
      const SelectProfileRoute();

  @override
  String get location => GoRouteData.$location('/browser/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}

RouteBase get $addonManagerRoute => GoRouteData.$route(
  path: '/addons',
  name: 'AddonManagerRoute',
  hasOverriddenOnExit: false,
  factory: $AddonManagerRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'details/:addonId',
      name: 'AddonDetailsRoute',
      hasOverriddenOnExit: false,
      factory: $AddonDetailsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'listing/:addonId',
      name: 'AddonListingDetailsRoute',
      hasOverriddenOnExit: false,
      factory: $AddonListingDetailsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'permissions/:addonId',
      name: 'AddonPermissionsRoute',
      hasOverriddenOnExit: false,
      factory: $AddonPermissionsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'settings/:addonId',
      name: 'AddonInternalSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $AddonInternalSettingsRoute._fromState,
    ),
  ],
);

mixin $AddonManagerRoute on GoRouteData {
  static AddonManagerRoute _fromState(GoRouterState state) =>
      const AddonManagerRoute();

  @override
  String get location => GoRouteData.$location('/addons');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AddonDetailsRoute on GoRouteData {
  static AddonDetailsRoute _fromState(GoRouterState state) =>
      AddonDetailsRoute(addonId: state.pathParameters['addonId']!);

  AddonDetailsRoute get _self => this as AddonDetailsRoute;

  @override
  String get location => GoRouteData.$location(
    '/addons/details/${Uri.encodeComponent(_self.addonId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AddonListingDetailsRoute on GoRouteData {
  static AddonListingDetailsRoute _fromState(GoRouterState state) =>
      AddonListingDetailsRoute(
        addonId: state.pathParameters['addonId']!,
        $extra: state.extra as AddonListing,
      );

  AddonListingDetailsRoute get _self => this as AddonListingDetailsRoute;

  @override
  String get location => GoRouteData.$location(
    '/addons/listing/${Uri.encodeComponent(_self.addonId)}',
  );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin $AddonPermissionsRoute on GoRouteData {
  static AddonPermissionsRoute _fromState(GoRouterState state) =>
      AddonPermissionsRoute(addonId: state.pathParameters['addonId']!);

  AddonPermissionsRoute get _self => this as AddonPermissionsRoute;

  @override
  String get location => GoRouteData.$location(
    '/addons/permissions/${Uri.encodeComponent(_self.addonId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AddonInternalSettingsRoute on GoRouteData {
  static AddonInternalSettingsRoute _fromState(GoRouterState state) =>
      AddonInternalSettingsRoute(addonId: state.pathParameters['addonId']!);

  AddonInternalSettingsRoute get _self => this as AddonInternalSettingsRoute;

  @override
  String get location => GoRouteData.$location(
    '/addons/settings/${Uri.encodeComponent(_self.addonId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $feedListRoute => GoRouteData.$route(
  path: '/feeds',
  name: 'FeedListRoute',
  hasOverriddenOnExit: false,
  factory: $FeedListRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'add',
      name: 'FeedAddRoute',
      hasOverriddenOnExit: false,
      factory: $FeedAddRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'articles/:feedId',
      name: 'FeedArticleListRoute',
      hasOverriddenOnExit: false,
      factory: $FeedArticleListRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'article/:articleId',
      name: 'FeedArticleRoute',
      hasOverriddenOnExit: false,
      factory: $FeedArticleRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'create/:feedId',
      name: 'FeedCreateRoute',
      hasOverriddenOnExit: false,
      factory: $FeedCreateRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'available/:feedsJson',
      name: 'SelectFeedDialogRoute',
      hasOverriddenOnExit: false,
      factory: $SelectFeedDialogRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'edit/:feedId',
      name: 'FeedEditRoute',
      hasOverriddenOnExit: false,
      factory: $FeedEditRoute._fromState,
    ),
  ],
);

mixin $FeedListRoute on GoRouteData {
  static FeedListRoute _fromState(GoRouterState state) => FeedListRoute();

  @override
  String get location => GoRouteData.$location('/feeds');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FeedAddRoute on GoRouteData {
  static FeedAddRoute _fromState(GoRouterState state) =>
      FeedAddRoute(uri: state.uri.queryParameters['uri']);

  FeedAddRoute get _self => this as FeedAddRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/add',
    queryParams: {if (_self.uri != null) 'uri': _self.uri},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FeedArticleListRoute on GoRouteData {
  static FeedArticleListRoute _fromState(GoRouterState state) =>
      FeedArticleListRoute(feedId: Uri.parse(state.pathParameters['feedId']!));

  FeedArticleListRoute get _self => this as FeedArticleListRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/articles/${Uri.encodeComponent(_self.feedId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FeedArticleRoute on GoRouteData {
  static FeedArticleRoute _fromState(GoRouterState state) =>
      FeedArticleRoute(articleId: state.pathParameters['articleId']!);

  FeedArticleRoute get _self => this as FeedArticleRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/article/${Uri.encodeComponent(_self.articleId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FeedCreateRoute on GoRouteData {
  static FeedCreateRoute _fromState(GoRouterState state) =>
      FeedCreateRoute(feedId: Uri.parse(state.pathParameters['feedId']!));

  FeedCreateRoute get _self => this as FeedCreateRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/create/${Uri.encodeComponent(_self.feedId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SelectFeedDialogRoute on GoRouteData {
  static SelectFeedDialogRoute _fromState(GoRouterState state) =>
      SelectFeedDialogRoute(feedsJson: state.pathParameters['feedsJson']!);

  SelectFeedDialogRoute get _self => this as SelectFeedDialogRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/available/${Uri.encodeComponent(_self.feedsJson)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FeedEditRoute on GoRouteData {
  static FeedEditRoute _fromState(GoRouterState state) =>
      FeedEditRoute(feedId: Uri.parse(state.pathParameters['feedId']!));

  FeedEditRoute get _self => this as FeedEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/edit/${Uri.encodeComponent(_self.feedId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $historyRoute => GoRouteData.$route(
  path: '/history',
  name: 'HistoryRoute',
  hasOverriddenOnExit: false,
  factory: $HistoryRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'downloads',
      name: 'HistoryDownloadsRoute',
      hasOverriddenOnExit: false,
      factory: $HistoryDownloadsRoute._fromState,
    ),
  ],
);

mixin $HistoryRoute on GoRouteData {
  static HistoryRoute _fromState(GoRouterState state) => const HistoryRoute();

  @override
  String get location => GoRouteData.$location('/history');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $HistoryDownloadsRoute on GoRouteData {
  static HistoryDownloadsRoute _fromState(GoRouterState state) =>
      const HistoryDownloadsRoute();

  @override
  String get location => GoRouteData.$location('/history/downloads');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $profileListRoute => GoRouteData.$route(
  path: '/profiles',
  name: 'ProfileListRoute',
  hasOverriddenOnExit: false,
  factory: $ProfileListRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'edit',
      name: 'ProfileEditRoute',
      hasOverriddenOnExit: false,
      factory: $EditProfileRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'backup_list',
      name: 'ProfileBackupListRoute',
      hasOverriddenOnExit: false,
      factory: $ProfileBackupListRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'restore',
      name: 'RestoreProfileRoute',
      hasOverriddenOnExit: false,
      factory: $RestoreProfileRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'backup',
      name: 'BackupProfileRoute',
      hasOverriddenOnExit: false,
      factory: $BackupProfileRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'create',
      name: 'CreateProfileRoute',
      hasOverriddenOnExit: false,
      factory: $CreateProfileRoute._fromState,
    ),
  ],
);

mixin $ProfileListRoute on GoRouteData {
  static ProfileListRoute _fromState(GoRouterState state) => ProfileListRoute();

  @override
  String get location => GoRouteData.$location('/profiles');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $EditProfileRoute on GoRouteData {
  static EditProfileRoute _fromState(GoRouterState state) =>
      EditProfileRoute(profile: state.uri.queryParameters['profile']!);

  EditProfileRoute get _self => this as EditProfileRoute;

  @override
  String get location => GoRouteData.$location(
    '/profiles/edit',
    queryParams: {'profile': _self.profile},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProfileBackupListRoute on GoRouteData {
  static ProfileBackupListRoute _fromState(GoRouterState state) =>
      ProfileBackupListRoute();

  @override
  String get location => GoRouteData.$location('/profiles/backup_list');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RestoreProfileRoute on GoRouteData {
  static RestoreProfileRoute _fromState(GoRouterState state) =>
      RestoreProfileRoute(
        backupFileUri: state.uri.queryParameters['backup-file-uri']!,
      );

  RestoreProfileRoute get _self => this as RestoreProfileRoute;

  @override
  String get location => GoRouteData.$location(
    '/profiles/restore',
    queryParams: {'backup-file-uri': _self.backupFileUri},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BackupProfileRoute on GoRouteData {
  static BackupProfileRoute _fromState(GoRouterState state) =>
      BackupProfileRoute(profile: state.uri.queryParameters['profile']!);

  BackupProfileRoute get _self => this as BackupProfileRoute;

  @override
  String get location => GoRouteData.$location(
    '/profiles/backup',
    queryParams: {'profile': _self.profile},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CreateProfileRoute on GoRouteData {
  static CreateProfileRoute _fromState(GoRouterState state) =>
      CreateProfileRoute();

  @override
  String get location => GoRouteData.$location('/profiles/create');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsRoute => GoRouteData.$route(
  path: '/settings',
  name: 'SettingsRoute',
  hasOverriddenOnExit: false,
  factory: $SettingsRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'general',
      name: 'GeneralSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $GeneralSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'transfer',
      name: 'SettingsTransferRoute',
      hasOverriddenOnExit: false,
      factory: $SettingsTransferRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'browsing',
      name: 'BrowsingSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $BrowsingSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'gestures',
      name: 'GestureSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $GestureSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'privacy_security',
      name: 'PrivacySecuritySettingsRoute',
      hasOverriddenOnExit: false,
      factory: $PrivacySecuritySettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'toolbar_layout',
      name: 'ToolbarLayoutSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $ToolbarLayoutSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'web_content',
      name: 'WebContentSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $WebContentSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'search',
      name: 'SearchSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $SearchSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'extensions',
      name: 'ExtensionsSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $ExtensionsSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'advanced',
      name: 'AdvancedSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $AdvancedSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'experimental',
      name: 'ExperimentalSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $ExperimentalSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'push',
      name: 'WebPushSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $WebPushSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'bang',
      name: 'BangSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $BangSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'hardening',
      name: 'WebEngineHardeningRoute',
      hasOverriddenOnExit: false,
      factory: $WebEngineHardeningRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'group/:group',
          name: 'WebEngineHardeningGroupRoute',
          hasOverriddenOnExit: false,
          factory: $WebEngineHardeningGroupRoute._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: 'doh',
      name: 'DohSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $DohSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'fingerprint',
      name: 'FingerprintSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $FingerprintSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'locales',
      name: 'LocaleSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $LocaleSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'addon_collection',
      name: 'AddonCollectionRoute',
      hasOverriddenOnExit: false,
      factory: $AddonCollectionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'ublock_filter_lists',
      name: 'UBlockFilterListsRoute',
      hasOverriddenOnExit: false,
      factory: $UBlockFilterListsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'tracking_protection_exceptions',
      name: 'TrackingProtectionExceptionsRoute',
      hasOverriddenOnExit: false,
      factory: $TrackingProtectionExceptionsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'custom_tracking_protection',
      name: 'CustomTrackingProtectionRoute',
      hasOverriddenOnExit: false,
      factory: $CustomTrackingProtectionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'error_logs',
      name: 'ErrorLogsRoute',
      hasOverriddenOnExit: false,
      factory: $ErrorLogsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'account',
      name: 'AccountSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $AccountSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'sync',
      name: 'SyncSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $SyncSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'url_cleaner',
      name: 'UrlCleanerSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $UrlCleanerSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'unshortener',
      name: 'UnshortenerSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $UnshortenerSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'home',
      name: 'HomeSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $HomeSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'home_modules',
      name: 'HomeModulesSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $HomeModulesSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'new_tab_modules',
      name: 'NewTabModulesSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $NewTabModulesSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'wallpaper',
      name: 'WallpaperSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $WallpaperSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'contextual_toolbar',
      name: 'ContextualToolbarSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $ContextualToolbarSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'quick_switcher_toolbar',
      name: 'QuickSwitcherToolbarSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $QuickSwitcherToolbarSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'desktop_mode_sites',
      name: 'DesktopModeSitesRoute',
      hasOverriddenOnExit: false,
      factory: $DesktopModeSitesRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'singbox_proxy_profiles',
      name: 'SingboxProxyProfilesRoute',
      hasOverriddenOnExit: false,
      factory: $SingboxProxyProfilesRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'editor',
          name: 'SingboxProxyProfileEditorRoute',
          hasOverriddenOnExit: false,
          factory: $SingboxProxyProfileEditorRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'logs',
          name: 'SingboxProxyLogsRoute',
          hasOverriddenOnExit: false,
          factory: $SingboxProxyLogsRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'subscription',
          name: 'SubscriptionImportRoute',
          hasOverriddenOnExit: false,
          factory: $SubscriptionImportRoute._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: 'proxy_routing',
      name: 'ProxyRoutingSettingsRoute',
      hasOverriddenOnExit: false,
      factory: $ProxyRoutingSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'proxy',
      name: 'ProxySettingsRoute',
      hasOverriddenOnExit: false,
      factory: $ProxySettingsRoute._fromState,
    ),
  ],
);

mixin $SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $GeneralSettingsRoute on GoRouteData {
  static GeneralSettingsRoute _fromState(GoRouterState state) =>
      GeneralSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/general');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsTransferRoute on GoRouteData {
  static SettingsTransferRoute _fromState(GoRouterState state) =>
      const SettingsTransferRoute();

  @override
  String get location => GoRouteData.$location('/settings/transfer');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BrowsingSettingsRoute on GoRouteData {
  static BrowsingSettingsRoute _fromState(GoRouterState state) =>
      BrowsingSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/browsing');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $GestureSettingsRoute on GoRouteData {
  static GestureSettingsRoute _fromState(GoRouterState state) =>
      GestureSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/gestures');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PrivacySecuritySettingsRoute on GoRouteData {
  static PrivacySecuritySettingsRoute _fromState(GoRouterState state) =>
      PrivacySecuritySettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/privacy_security');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ToolbarLayoutSettingsRoute on GoRouteData {
  static ToolbarLayoutSettingsRoute _fromState(GoRouterState state) =>
      ToolbarLayoutSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/toolbar_layout');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $WebContentSettingsRoute on GoRouteData {
  static WebContentSettingsRoute _fromState(GoRouterState state) =>
      WebContentSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/web_content');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SearchSettingsRoute on GoRouteData {
  static SearchSettingsRoute _fromState(GoRouterState state) =>
      SearchSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/search');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ExtensionsSettingsRoute on GoRouteData {
  static ExtensionsSettingsRoute _fromState(GoRouterState state) =>
      ExtensionsSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/extensions');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AdvancedSettingsRoute on GoRouteData {
  static AdvancedSettingsRoute _fromState(GoRouterState state) =>
      AdvancedSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/advanced');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ExperimentalSettingsRoute on GoRouteData {
  static ExperimentalSettingsRoute _fromState(GoRouterState state) =>
      ExperimentalSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/experimental');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $WebPushSettingsRoute on GoRouteData {
  static WebPushSettingsRoute _fromState(GoRouterState state) =>
      WebPushSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/push');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BangSettingsRoute on GoRouteData {
  static BangSettingsRoute _fromState(GoRouterState state) =>
      BangSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/bang');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $WebEngineHardeningRoute on GoRouteData {
  static WebEngineHardeningRoute _fromState(GoRouterState state) =>
      WebEngineHardeningRoute();

  @override
  String get location => GoRouteData.$location('/settings/hardening');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $WebEngineHardeningGroupRoute on GoRouteData {
  static WebEngineHardeningGroupRoute _fromState(GoRouterState state) =>
      WebEngineHardeningGroupRoute(group: state.pathParameters['group']!);

  WebEngineHardeningGroupRoute get _self =>
      this as WebEngineHardeningGroupRoute;

  @override
  String get location => GoRouteData.$location(
    '/settings/hardening/group/${Uri.encodeComponent(_self.group)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DohSettingsRoute on GoRouteData {
  static DohSettingsRoute _fromState(GoRouterState state) => DohSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/doh');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FingerprintSettingsRoute on GoRouteData {
  static FingerprintSettingsRoute _fromState(GoRouterState state) =>
      FingerprintSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/fingerprint');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $LocaleSettingsRoute on GoRouteData {
  static LocaleSettingsRoute _fromState(GoRouterState state) =>
      LocaleSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/locales');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AddonCollectionRoute on GoRouteData {
  static AddonCollectionRoute _fromState(GoRouterState state) =>
      AddonCollectionRoute();

  @override
  String get location => GoRouteData.$location('/settings/addon_collection');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $UBlockFilterListsRoute on GoRouteData {
  static UBlockFilterListsRoute _fromState(GoRouterState state) =>
      UBlockFilterListsRoute();

  @override
  String get location => GoRouteData.$location('/settings/ublock_filter_lists');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $TrackingProtectionExceptionsRoute on GoRouteData {
  static TrackingProtectionExceptionsRoute _fromState(GoRouterState state) =>
      TrackingProtectionExceptionsRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/tracking_protection_exceptions');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CustomTrackingProtectionRoute on GoRouteData {
  static CustomTrackingProtectionRoute _fromState(GoRouterState state) =>
      CustomTrackingProtectionRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/custom_tracking_protection');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ErrorLogsRoute on GoRouteData {
  static ErrorLogsRoute _fromState(GoRouterState state) => ErrorLogsRoute();

  @override
  String get location => GoRouteData.$location('/settings/error_logs');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AccountSettingsRoute on GoRouteData {
  static AccountSettingsRoute _fromState(GoRouterState state) =>
      AccountSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/account');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SyncSettingsRoute on GoRouteData {
  static SyncSettingsRoute _fromState(GoRouterState state) =>
      SyncSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/sync');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $UrlCleanerSettingsRoute on GoRouteData {
  static UrlCleanerSettingsRoute _fromState(GoRouterState state) =>
      UrlCleanerSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/url_cleaner');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $UnshortenerSettingsRoute on GoRouteData {
  static UnshortenerSettingsRoute _fromState(GoRouterState state) =>
      UnshortenerSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/unshortener');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $HomeSettingsRoute on GoRouteData {
  static HomeSettingsRoute _fromState(GoRouterState state) =>
      const HomeSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $HomeModulesSettingsRoute on GoRouteData {
  static HomeModulesSettingsRoute _fromState(GoRouterState state) =>
      const HomeModulesSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/home_modules');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NewTabModulesSettingsRoute on GoRouteData {
  static NewTabModulesSettingsRoute _fromState(GoRouterState state) =>
      const NewTabModulesSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/new_tab_modules');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $WallpaperSettingsRoute on GoRouteData {
  static WallpaperSettingsRoute _fromState(GoRouterState state) =>
      const WallpaperSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/wallpaper');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ContextualToolbarSettingsRoute on GoRouteData {
  static ContextualToolbarSettingsRoute _fromState(GoRouterState state) =>
      const ContextualToolbarSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/contextual_toolbar');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuickSwitcherToolbarSettingsRoute on GoRouteData {
  static QuickSwitcherToolbarSettingsRoute _fromState(GoRouterState state) =>
      const QuickSwitcherToolbarSettingsRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/quick_switcher_toolbar');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DesktopModeSitesRoute on GoRouteData {
  static DesktopModeSitesRoute _fromState(GoRouterState state) =>
      const DesktopModeSitesRoute();

  @override
  String get location => GoRouteData.$location('/settings/desktop_mode_sites');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SingboxProxyProfilesRoute on GoRouteData {
  static SingboxProxyProfilesRoute _fromState(GoRouterState state) =>
      const SingboxProxyProfilesRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/singbox_proxy_profiles');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SingboxProxyProfileEditorRoute on GoRouteData {
  static SingboxProxyProfileEditorRoute _fromState(GoRouterState state) =>
      SingboxProxyProfileEditorRoute(
        profileId: state.uri.queryParameters['profile-id'],
        $extra: state.extra as ProxyProfileSeed?,
      );

  SingboxProxyProfileEditorRoute get _self =>
      this as SingboxProxyProfileEditorRoute;

  @override
  String get location => GoRouteData.$location(
    '/settings/singbox_proxy_profiles/editor',
    queryParams: {if (_self.profileId != null) 'profile-id': _self.profileId},
  );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin $SingboxProxyLogsRoute on GoRouteData {
  static SingboxProxyLogsRoute _fromState(GoRouterState state) =>
      const SingboxProxyLogsRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/singbox_proxy_profiles/logs');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SubscriptionImportRoute on GoRouteData {
  static SubscriptionImportRoute _fromState(GoRouterState state) =>
      const SubscriptionImportRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/singbox_proxy_profiles/subscription');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProxyRoutingSettingsRoute on GoRouteData {
  static ProxyRoutingSettingsRoute _fromState(GoRouterState state) =>
      const ProxyRoutingSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/proxy_routing');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProxySettingsRoute on GoRouteData {
  static ProxySettingsRoute _fromState(GoRouterState state) =>
      const ProxySettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/proxy');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $torProxyRoute => GoRouteData.$route(
  path: '/tor',
  name: 'TorProxyRoute',
  hasOverriddenOnExit: false,
  factory: $TorProxyRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'country_picker',
      name: 'TorCountryPickerRoute',
      hasOverriddenOnExit: false,
      factory: $TorCountryPickerRoute._fromState,
    ),
  ],
);

mixin $TorProxyRoute on GoRouteData {
  static TorProxyRoute _fromState(GoRouterState state) => const TorProxyRoute();

  @override
  String get location => GoRouteData.$location('/tor');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $TorCountryPickerRoute on GoRouteData {
  static TorCountryPickerRoute _fromState(GoRouterState state) =>
      TorCountryPickerRoute(
        title: state.uri.queryParameters['title']!,
        $extra: state.extra as String?,
      );

  TorCountryPickerRoute get _self => this as TorCountryPickerRoute;

  @override
  String get location => GoRouteData.$location(
    '/tor/country_picker',
    queryParams: {'title': _self.title},
  );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}
