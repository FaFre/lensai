// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabStates)
final tabStatesProvider = TabStatesProvider._();

final class TabStatesProvider
    extends $NotifierProvider<TabStates, Map<String, TabState>> {
  TabStatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabStatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabStatesHash();

  @$internal
  @override
  TabStates create() => TabStates();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TabState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TabState>>(value),
    );
  }
}

String _$tabStatesHash() => r'eed70328c6c08a9d721d0b95df247a827ed9dc65';

abstract class _$TabStates extends $Notifier<Map<String, TabState>> {
  Map<String, TabState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, TabState>, Map<String, TabState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, TabState>, Map<String, TabState>>,
              Map<String, TabState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(tabState)
final tabStateProvider = TabStateFamily._();

final class TabStateProvider
    extends $FunctionalProvider<TabState?, TabState?, TabState?>
    with $Provider<TabState?> {
  TabStateProvider._({
    required TabStateFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tabStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabStateHash();

  @override
  String toString() {
    return r'tabStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<TabState?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TabState? create(Ref ref) {
    final argument = this.argument as String?;
    return tabState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabState?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabStateHash() => r'f57b2353acc99ca73670d504b45ea5ff19df38c7';

final class TabStateFamily extends $Family
    with $FunctionalFamilyOverride<TabState?, String?> {
  TabStateFamily._()
    : super(
        retry: null,
        name: r'tabStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabStateProvider call(String? tabId) =>
      TabStateProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabStateProvider';
}

/// Projection of [tabStatesProvider] for consumers that order or filter tabs
/// but render nothing from the state itself. Watching this instead of the full
/// map keeps the (expensive) grouping/sorting passes off the path of every
/// icon, security-info and readerable event.

@ProviderFor(tabSortKeys)
final tabSortKeysProvider = TabSortKeysProvider._();

/// Projection of [tabStatesProvider] for consumers that order or filter tabs
/// but render nothing from the state itself. Watching this instead of the full
/// map keeps the (expensive) grouping/sorting passes off the path of every
/// icon, security-info and readerable event.

final class TabSortKeysProvider
    extends
        $FunctionalProvider<
          EquatableValue<Map<String, TabSortKeys>>,
          EquatableValue<Map<String, TabSortKeys>>,
          EquatableValue<Map<String, TabSortKeys>>
        >
    with $Provider<EquatableValue<Map<String, TabSortKeys>>> {
  /// Projection of [tabStatesProvider] for consumers that order or filter tabs
  /// but render nothing from the state itself. Watching this instead of the full
  /// map keeps the (expensive) grouping/sorting passes off the path of every
  /// icon, security-info and readerable event.
  TabSortKeysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabSortKeysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabSortKeysHash();

  @$internal
  @override
  $ProviderElement<EquatableValue<Map<String, TabSortKeys>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<Map<String, TabSortKeys>> create(Ref ref) {
    return tabSortKeys(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<Map<String, TabSortKeys>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<Map<String, TabSortKeys>>>(value),
    );
  }
}

String _$tabSortKeysHash() => r'7bf660099d006b6df9846594d2a5d78a32fa3bdb';

@ProviderFor(tabStateWithFallback)
final tabStateWithFallbackProvider = TabStateWithFallbackFamily._();

final class TabStateWithFallbackProvider
    extends
        $FunctionalProvider<AsyncValue<TabState>, TabState, FutureOr<TabState>>
    with $FutureModifier<TabState>, $FutureProvider<TabState> {
  TabStateWithFallbackProvider._({
    required TabStateWithFallbackFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tabStateWithFallbackProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabStateWithFallbackHash();

  @override
  String toString() {
    return r'tabStateWithFallbackProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TabState> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TabState> create(Ref ref) {
    final argument = this.argument as String;
    return tabStateWithFallback(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TabStateWithFallbackProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabStateWithFallbackHash() =>
    r'061011ac79738dbe4e662a76fccbc8592cba21cf';

final class TabStateWithFallbackFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TabState>, String> {
  TabStateWithFallbackFamily._()
    : super(
        retry: null,
        name: r'tabStateWithFallbackProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabStateWithFallbackProvider call(String tabId) =>
      TabStateWithFallbackProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabStateWithFallbackProvider';
}

@ProviderFor(isTabTunneled)
final isTabTunneledProvider = IsTabTunneledFamily._();

final class IsTabTunneledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  IsTabTunneledProvider._({
    required IsTabTunneledFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'isTabTunneledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isTabTunneledHash();

  @override
  String toString() {
    return r'isTabTunneledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String?;
    return isTabTunneled(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsTabTunneledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isTabTunneledHash() => r'd36607ff812f71870af32ce59c2dbe898a9c1917';

final class IsTabTunneledFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String?> {
  IsTabTunneledFamily._()
    : super(
        retry: null,
        name: r'isTabTunneledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsTabTunneledProvider call(String? tabId) =>
      IsTabTunneledProvider._(argument: tabId, from: this);

  @override
  String toString() => r'isTabTunneledProvider';
}

@ProviderFor(selectedTabState)
final selectedTabStateProvider = SelectedTabStateProvider._();

final class SelectedTabStateProvider
    extends $FunctionalProvider<TabState?, TabState?, TabState?>
    with $Provider<TabState?> {
  SelectedTabStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTabStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTabStateHash();

  @$internal
  @override
  $ProviderElement<TabState?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TabState? create(Ref ref) {
    return selectedTabState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabState?>(value),
    );
  }
}

String _$selectedTabStateHash() => r'dbd36af7af286bd9d079f30e8e11bbda23bf7728';

@ProviderFor(selectedTabType)
final selectedTabTypeProvider = SelectedTabTypeProvider._();

final class SelectedTabTypeProvider
    extends $FunctionalProvider<TabType?, TabType?, TabType?>
    with $Provider<TabType?> {
  SelectedTabTypeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTabTypeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTabTypeHash();

  @$internal
  @override
  $ProviderElement<TabType?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TabType? create(Ref ref) {
    return selectedTabType(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabType? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabType?>(value),
    );
  }
}

String _$selectedTabTypeHash() => r'4cf99c9175357a7835fc3c4eff29a9f328931e4f';

@ProviderFor(selectedTabContainerId)
final selectedTabContainerIdProvider = SelectedTabContainerIdProvider._();

final class SelectedTabContainerIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<String?>,
          AsyncValue<String?>,
          AsyncValue<String?>
        >
    with $Provider<AsyncValue<String?>> {
  SelectedTabContainerIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTabContainerIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTabContainerIdHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<String?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<String?> create(Ref ref) {
    return selectedTabContainerId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String?>>(value),
    );
  }
}

String _$selectedTabContainerIdHash() =>
    r'07899d29f69654d3b314d0da945ad402b1003b41';
