import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _AutocompleteCallbackAction<T extends Intent> extends CallbackAction<T> {
  _AutocompleteCallbackAction({
    required super.onInvoke,
    required this.isEnabledCallback,
  });

  // The enabled state determines whether the action will consume the
  // key shortcut or let it continue on to the underlying text field.
  // They should only be enabled when the options are showing so shortcuts
  // can be used to navigate them.
  final bool Function() isEnabledCallback;

  @override
  bool isEnabled(covariant T intent) => isEnabledCallback();

  @override
  bool consumesKey(covariant T intent) => isEnabled(intent);
}

class ExternalResultsAutocomplete<T extends Object> extends StatefulWidget {
  /// Create an instance of RawAutocomplete.
  ///
  /// [displayStringForOption], [onTextChanged] and [optionsViewBuilder] must
  /// not be null.
  const ExternalResultsAutocomplete({
    super.key,
    required this.optionsViewBuilder,
    required this.onTextChanged,
    required this.optionsStream,
    this.optionsViewOpenDirection = OptionsViewOpenDirection.down,
    this.displayStringForOption = defaultStringForOption,
    this.fieldViewBuilder,
    this.focusNode,
    this.onSelected,
    this.textEditingController,
    this.initialValue,
  })  : assert(
          fieldViewBuilder != null ||
              (key != null &&
                  focusNode != null &&
                  textEditingController != null),
          'Pass in a fieldViewBuilder, or otherwise create a separate field and pass in the FocusNode, TextEditingController, and a key. Use the key with RawAutocomplete.onFieldSubmitted.',
        ),
        assert((focusNode == null) == (textEditingController == null)),
        assert(
          !(textEditingController != null && initialValue != null),
          'textEditingController and initialValue cannot be simultaneously defined.',
        );

  /// {@template flutter.widgets.RawAutocomplete.fieldViewBuilder}
  /// Builds the field whose input is used to get the options.
  ///
  /// Pass the provided [TextEditingController] to the field built here so that
  /// RawAutocomplete can listen for changes.
  /// {@endtemplate}
  ///
  /// If this parameter is null, then a [SizedBox.shrink] is built instead.
  /// For how that pattern can be useful, see [textEditingController].
  final AutocompleteFieldViewBuilder? fieldViewBuilder;

  /// The [FocusNode] that is used for the text field.
  ///
  /// {@template flutter.widgets.RawAutocomplete.split}
  /// The main purpose of this parameter is to allow the use of a separate text
  /// field located in another part of the widget tree instead of the text
  /// field built by [fieldViewBuilder]. For example, it may be desirable to
  /// place the text field in the AppBar and the options below in the main body.
  ///
  /// When following this pattern, [fieldViewBuilder] can be omitted,
  /// so that a text field is not drawn where it would normally be.
  /// A separate text field can be created elsewhere, and a
  /// FocusNode and TextEditingController can be passed both to that text field
  /// and to RawAutocomplete.
  ///
  /// {@tool dartpad}
  /// This examples shows how to create an autocomplete widget with the text
  /// field in the AppBar and the results in the main body of the app.
  ///
  /// ** See code in examples/api/lib/widgets/autocomplete/raw_autocomplete.focus_node.0.dart **
  /// {@end-tool}
  /// {@endtemplate}
  ///
  /// If this parameter is not null, then [textEditingController] must also be
  /// not null.
  final FocusNode? focusNode;

  /// {@template flutter.widgets.RawAutocomplete.optionsViewBuilder}
  /// Builds the selectable options widgets from a list of options objects.
  ///
  /// The options are displayed floating below or above the field using a
  /// [CompositedTransformFollower] inside of an [Overlay], not at the same
  /// place in the widget tree as [ExternalResultsAutocomplete]. To control whether it opens
  /// upward or downward, use [optionsViewOpenDirection].
  ///
  /// In order to track which item is highlighted by keyboard navigation, the
  /// resulting options will be wrapped in an inherited
  /// [AutocompleteHighlightedOption] widget.
  /// Inside this callback, the index of the highlighted option can be obtained
  /// from [AutocompleteHighlightedOption.of] to display the highlighted option
  /// with a visual highlight to indicate it will be the option selected from
  /// the keyboard.
  ///
  /// {@endtemplate}
  final AutocompleteOptionsViewBuilder<T> optionsViewBuilder;

  /// {@template flutter.widgets.RawAutocomplete.optionsViewOpenDirection}
  /// The direction in which to open the options-view overlay.
  ///
  /// Defaults to [OptionsViewOpenDirection.down].
  /// {@endtemplate}
  final OptionsViewOpenDirection optionsViewOpenDirection;

  /// {@template flutter.widgets.RawAutocomplete.displayStringForOption}
  /// Returns the string to display in the field when the option is selected.
  ///
  /// This is useful when using a custom T type and the string to display is
  /// different than the string to search by.
  ///
  /// If not provided, will use `option.toString()`.
  /// {@endtemplate}
  final AutocompleteOptionToString<T> displayStringForOption;

  /// {@template flutter.widgets.RawAutocomplete.onSelected}
  /// Called when an option is selected by the user.
  /// {@endtemplate}
  final AutocompleteOnSelected<T>? onSelected;

  final FutureOr<void> Function(TextEditingValue textEditingValue)
      onTextChanged;

  /// The [TextEditingController] that is used for the text field.
  ///
  /// {@macro flutter.widgets.RawAutocomplete.split}
  ///
  /// If this parameter is not null, then [focusNode] must also be not null.
  final TextEditingController? textEditingController;

  /// {@template flutter.widgets.RawAutocomplete.initialValue}
  /// The initial value to use for the text field.
  /// {@endtemplate}
  ///
  /// Setting the initial value does not notify [textEditingController]'s
  /// listeners, and thus will not cause the options UI to appear.
  ///
  /// This parameter is ignored if [textEditingController] is defined.
  final TextEditingValue? initialValue;

  final Stream<Iterable<T>> optionsStream;

  /// Calls [AutocompleteFieldViewBuilder]'s onFieldSubmitted callback for the
  /// RawAutocomplete widget indicated by the given [GlobalKey].
  ///
  /// This is not typically used unless a custom field is implemented instead of
  /// using [fieldViewBuilder]. In the typical case, the onFieldSubmitted
  /// callback is passed via the [AutocompleteFieldViewBuilder] signature. When
  /// not using fieldViewBuilder, the same callback can be called by using this
  /// static method.
  ///
  /// See also:
  ///
  ///  * [focusNode] and [textEditingController], which contain a code example
  ///    showing how to create a separate field outside of fieldViewBuilder.
  static void onFieldSubmitted<T extends Object>(GlobalKey key) {
    final _RawAutocompleteState<T> rawAutocomplete =
        key.currentState! as _RawAutocompleteState<T>;
    rawAutocomplete._onFieldSubmitted();
  }

  /// The default way to convert an option to a string in
  /// [displayStringForOption].
  ///
  /// Uses the `toString` method of the given `option`.
  static String defaultStringForOption(Object? option) {
    return option.toString();
  }

  @override
  State<ExternalResultsAutocomplete<T>> createState() =>
      _RawAutocompleteState<T>();
}

class _RawAutocompleteState<T extends Object>
    extends State<ExternalResultsAutocomplete<T>> {
  final GlobalKey _fieldKey = GlobalKey();
  final LayerLink _optionsLayerLink = LayerLink();
  final OverlayPortalController _optionsViewController =
      OverlayPortalController(debugLabel: '_RawAutocompleteState');

  TextEditingController? _internalTextEditingController;
  TextEditingController get _textEditingController {
    return widget.textEditingController ??
        (_internalTextEditingController ??= TextEditingController()
          ..addListener(_onChangedField));
  }

  FocusNode? _internalFocusNode;
  FocusNode get _focusNode {
    return widget.focusNode ??
        (_internalFocusNode ??= FocusNode()
          ..addListener(_updateOptionsViewVisibility));
  }

  late final Map<Type, CallbackAction<Intent>> _actionMap =
      <Type, CallbackAction<Intent>>{
    AutocompletePreviousOptionIntent:
        _AutocompleteCallbackAction<AutocompletePreviousOptionIntent>(
      onInvoke: _highlightPreviousOption,
      isEnabledCallback: () => _canShowOptionsView,
    ),
    AutocompleteNextOptionIntent:
        _AutocompleteCallbackAction<AutocompleteNextOptionIntent>(
      onInvoke: _highlightNextOption,
      isEnabledCallback: () => _canShowOptionsView,
    ),
    DismissIntent: CallbackAction<DismissIntent>(onInvoke: _hideOptions),
  };

  late StreamSubscription<Iterable<T>> _optionsSubscription;
  Iterable<T> _options = Iterable<T>.empty();
  T? _selection;
  // Set the initial value to null so when this widget gets focused for the first
  // time it will try to run the options view builder.
  String? _lastFieldText;
  final ValueNotifier<int> _highlightedOptionIndex = ValueNotifier<int>(0);

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowUp):
        AutocompletePreviousOptionIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown):
        AutocompleteNextOptionIntent(),
  };

  bool get _canShowOptionsView =>
      _focusNode.hasFocus && _selection == null && _options.isNotEmpty;

  void _updateOptionsViewVisibility() {
    if (_canShowOptionsView) {
      _optionsViewController.show();
    } else {
      _optionsViewController.hide();
    }
  }

  void _onUpateOptions(Iterable<T> options) {
    final TextEditingValue value = _textEditingController.value;

    _options = options;
    _updateHighlight(_highlightedOptionIndex.value);
    final T? selection = _selection;
    if (selection != null &&
        value.text != widget.displayStringForOption(selection)) {
      _selection = null;
    }

    // Make sure the options are no longer hidden if the content of the field
    // changes (ignore selection changes).
    if (value.text != _lastFieldText) {
      _lastFieldText = value.text;
      _updateOptionsViewVisibility();
    }
  }

  // Called when _textEditingController changes.
  Future<void> _onChangedField() async {
    final TextEditingValue value = _textEditingController.value;
    await widget.onTextChanged(value);
  }

  // Called from fieldViewBuilder when the user submits the field.
  void _onFieldSubmitted() {
    if (_optionsViewController.isShowing) {
      _select(_options.elementAt(_highlightedOptionIndex.value));
    }
  }

  // Select the given option and update the widget.
  void _select(T nextSelection) {
    if (nextSelection == _selection) {
      return;
    }
    _selection = nextSelection;
    final String selectionString = widget.displayStringForOption(nextSelection);
    _textEditingController.value = TextEditingValue(
      selection: TextSelection.collapsed(offset: selectionString.length),
      text: selectionString,
    );
    widget.onSelected?.call(nextSelection);
    _updateOptionsViewVisibility();
  }

  void _updateHighlight(int newIndex) {
    _highlightedOptionIndex.value =
        _options.isEmpty ? 0 : newIndex % _options.length;
  }

  void _highlightPreviousOption(AutocompletePreviousOptionIntent intent) {
    assert(_canShowOptionsView);
    _updateOptionsViewVisibility();
    assert(_optionsViewController.isShowing);
    _updateHighlight(_highlightedOptionIndex.value - 1);
  }

  void _highlightNextOption(AutocompleteNextOptionIntent intent) {
    assert(_canShowOptionsView);
    _updateOptionsViewVisibility();
    assert(_optionsViewController.isShowing);
    _updateHighlight(_highlightedOptionIndex.value + 1);
  }

  Object? _hideOptions(DismissIntent intent) {
    if (_optionsViewController.isShowing) {
      _optionsViewController.hide();
      return null;
    } else {
      return Actions.invoke(context, intent);
    }
  }

  Widget _buildOptionsView(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final Alignment followerAlignment =
        switch (widget.optionsViewOpenDirection) {
      OptionsViewOpenDirection.up => AlignmentDirectional.bottomStart,
      OptionsViewOpenDirection.down => AlignmentDirectional.topStart,
    }
            .resolve(textDirection);
    final Alignment targetAnchor = switch (widget.optionsViewOpenDirection) {
      OptionsViewOpenDirection.up => AlignmentDirectional.topStart,
      OptionsViewOpenDirection.down => AlignmentDirectional.bottomStart,
    }
        .resolve(textDirection);

    return CompositedTransformFollower(
      link: _optionsLayerLink,
      showWhenUnlinked: false,
      targetAnchor: targetAnchor,
      followerAnchor: followerAlignment,
      child: TextFieldTapRegion(
        child: AutocompleteHighlightedOption(
          highlightIndexNotifier: _highlightedOptionIndex,
          child: Builder(
            builder: (BuildContext context) =>
                widget.optionsViewBuilder(context, _select, _options),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final TextEditingController initialController =
        widget.textEditingController ??
            (_internalTextEditingController =
                TextEditingController.fromValue(widget.initialValue));
    initialController.addListener(_onChangedField);
    widget.focusNode?.addListener(_updateOptionsViewVisibility);
    _optionsSubscription = widget.optionsStream.listen(_onUpateOptions);
  }

  @override
  void didUpdateWidget(ExternalResultsAutocomplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(
      oldWidget.textEditingController,
      widget.textEditingController,
    )) {
      oldWidget.textEditingController?.removeListener(_onChangedField);
      if (oldWidget.textEditingController == null) {
        _internalTextEditingController?.dispose();
        _internalTextEditingController = null;
      }
      widget.textEditingController?.addListener(_onChangedField);
    }
    if (!identical(oldWidget.focusNode, widget.focusNode)) {
      oldWidget.focusNode?.removeListener(_updateOptionsViewVisibility);
      if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      widget.focusNode?.addListener(_updateOptionsViewVisibility);
    }
    if (!identical(oldWidget.optionsStream, widget.optionsStream)) {
      unawaited(_optionsSubscription.cancel());
      _optionsSubscription = widget.optionsStream.listen(_onUpateOptions);
    }
  }

  @override
  void dispose() {
    widget.textEditingController?.removeListener(_onChangedField);
    _internalTextEditingController?.dispose();
    widget.focusNode?.removeListener(_updateOptionsViewVisibility);
    _internalFocusNode?.dispose();
    _highlightedOptionIndex.dispose();
    unawaited(_optionsSubscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget fieldView = widget.fieldViewBuilder?.call(
          context,
          _textEditingController,
          _focusNode,
          _onFieldSubmitted,
        ) ??
        const SizedBox.shrink();
    return OverlayPortal.targetsRootOverlay(
      controller: _optionsViewController,
      overlayChildBuilder: _buildOptionsView,
      child: TextFieldTapRegion(
        child: Container(
          key: _fieldKey,
          child: Shortcuts(
            shortcuts: _shortcuts,
            child: Actions(
              actions: _actionMap,
              child: CompositedTransformTarget(
                link: _optionsLayerLink,
                child: fieldView,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
