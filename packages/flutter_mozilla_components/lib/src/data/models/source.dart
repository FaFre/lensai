import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

/// Describes a category of an external package.
enum PackageCategory {
  unknown(-1),
  game(0),
  audio(1),
  video(2),
  image(3),
  social(4),
  news(5),
  maps(6),
  productivity(7);

  final int id;
  const PackageCategory(this.id);

  factory PackageCategory.fromInt(int? id) {
    return PackageCategory.values.firstWhere(
      (category) => category.id == id,
      orElse: () => PackageCategory.unknown,
    );
  }

  PackageCategoryValue toValue() {
    return PackageCategoryValue(value: id);
  }
}

/// Represents the origin of a session to describe how and why it was created.
abstract class Source {
  final int id;

  const Source(this.id);

  SourceValue toValue();

  /// Initializes a [Source] of a correct type from its component properties.
  /// Intended use is for restoring persisted state.
  static Source restore(
    int? sourceId,
    String? packageId,
    int? packageCategory,
  ) {
    final caller = packageId != null
        ? ExternalPackage(
            packageId: packageId,
            category: PackageCategory.fromInt(packageCategory).toValue(),
          )
        : null;

    switch (sourceId) {
      case 1:
        return External.actionSend(caller);
      case 2:
        return External.actionView(caller);
      case 3:
        return External.actionSearch(caller);
      case 4:
        return External.customTab(caller);
      case 5:
        return Internal.homeScreen;
      case 6:
        return Internal.menu;
      case 7:
        return Internal.newTab;
      case 8:
        return Internal.none;
      case 9:
        return Internal.textSelection;
      case 10:
        return Internal.userEntered;
      case 11:
        return Internal.customTab;
      default:
        return Internal.none;
    }
  }
}

/// Describes sessions of external origins, i.e. from outside of the application.
abstract class External extends Source {
  final ExternalPackage? caller;

  const External(super.id, this.caller);

  @override
  SourceValue toValue() {
    return SourceValue(id: id, caller: caller);
  }

  /// Created to handle an ACTION_SEND (share) intent.
  factory External.actionSend(ExternalPackage? caller) = ActionSend;

  /// Created to handle an ACTION_VIEW intent.
  factory External.actionView(ExternalPackage? caller) = ActionView;

  /// Created to handle an ACTION_SEARCH and ACTION_WEB_SEARCH intent.
  factory External.actionSearch(ExternalPackage? caller) = ActionSearch;

  /// Created to handle a CustomTabs intent of external origin.
  factory External.customTab(ExternalPackage? caller) = CustomTab;
}

class ActionSend extends External {
  const ActionSend(ExternalPackage? caller) : super(1, caller);
}

class ActionView extends External {
  const ActionView(ExternalPackage? caller) : super(2, caller);
}

class ActionSearch extends External {
  const ActionSearch(ExternalPackage? caller) : super(3, caller);
}

class CustomTab extends External {
  const CustomTab(ExternalPackage? caller) : super(4, caller);
}

/// Describes sessions of internal origin, i.e. from within of the application.
abstract class Internal extends Source {
  const Internal(super.id);

  @override
  SourceValue toValue() {
    return SourceValue(id: id);
  }

  /// User interacted with the home screen.
  static const homeScreen = _HomeScreen();

  /// User interacted with a menu.
  static const menu = _Menu();

  /// User opened a new tab.
  static const newTab = _NewTab();

  /// Default value and for testing purposes.
  static const none = _None();

  /// User selected text.
  static const textSelection = _TextSelection();

  /// User entered a URL or search term.
  static const userEntered = _UserEntered();

  /// Created to handle a CustomTabs intent of internal origin.
  static const customTab = _CustomTab();
}

class _HomeScreen extends Internal {
  const _HomeScreen() : super(5);
}

class _Menu extends Internal {
  const _Menu() : super(6);
}

class _NewTab extends Internal {
  const _NewTab() : super(7);
}

class _None extends Internal {
  const _None() : super(8);
}

class _TextSelection extends Internal {
  const _TextSelection() : super(9);
}

class _UserEntered extends Internal {
  const _UserEntered() : super(10);
}

class _CustomTab extends Internal {
  const _CustomTab() : super(11);
}
