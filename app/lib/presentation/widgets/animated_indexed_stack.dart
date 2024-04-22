import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// An internal representation of a child widget subtree that is a child of
/// the [AnimatedIndexedStack].
///
/// This keeps track of animation controllers, keys, and the child widget.
class _ChildEntry {
  _ChildEntry({
    required this.key,
    required this.primaryController,
    required this.secondaryController,
    required this.child,
  });

  /// The key of this entry.
  /// This is usually a [GlobalKey] to ensure that children do not lose their state.
  final Key key;

  /// The animation controller for the child's transition.
  final AnimationController primaryController;

  /// The (curved) animation being used to drive the transition.
  final AnimationController secondaryController;
  Widget child;

  /// Release the resources used by this object.
  ///
  /// The object is no longer usable after this method is called.
  void dispose() {
    primaryController.dispose();
    secondaryController.dispose();
  }

  @override
  String toString() => 'AnimatedIndexedStackEntry#${shortHash(this)}($child)';
}

enum _ChildAnimationDirection {
  primaryForward,
  primaryReverse,
  secondaryForward,
  secondaryReverse,
}

/// A Widget that shows a single child from a list of children.
/// Changing the index will animate the change of widgets according to the [transitionBuilder].
/// Removing the widget at the current index will also animate the change.
///
/// Widgets which are not currently visible will be kept alive until they are removed.
class AnimatedIndexedStack extends StatefulWidget {
  const AnimatedIndexedStack({
    super.key,
    this.index = 0,
    this.duration = const Duration(milliseconds: 300),
    this.reverse = false,
    required this.transitionBuilder,
    this.layoutBuilder = defaultLayoutBuilder,
    this.children = const [],
  });

  /// The index of the child to show.
  ///
  /// If this is null, none of the children will be shown.
  final int? index;

  /// The duration of the transition from the old [child] value to the new one.
  final Duration duration;

  /// Indicates whether the new [child] will visually appear on top of or
  /// underneath the old child.
  final bool reverse;

  /// A function that wraps a new [child] with a primary and secondary animation
  /// set define how the child appears and disappears.
  final Widget Function(
    Widget child,
    Animation<double> primaryAnimation,
    Animation<double> secondaryAnimation,
  ) transitionBuilder;

  /// A function that lays out all the children in this IndexedStack.
  /// This defaults to [PageTransitionSwitcher.defaultLayoutBuilder].
  final Widget Function(List<Widget> entries) layoutBuilder;

  /// The child widgets of the stack.
  /// Only the child at index [index] will be shown.
  /// To correctly keep track of the state of child widgets, they must be given unique keys.
  final List<Widget> children;

  /// The default layout builder for [AnimatedIndexedStack].
  /// Contains all the children in a [Stack].
  static Widget defaultLayoutBuilder(List<Widget> entries) {
    return Stack(
      alignment: Alignment.center,
      children: entries,
    );
  }

  @override
  State<AnimatedIndexedStack> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack>
    with TickerProviderStateMixin {
  /// All entries contained in this Stack.
  /// This is built from the children list, but may also contain entries which are animating out.
  List<_ChildEntry> _entries = [];

  /// The entry which is currently at the top of the stack.
  _ChildEntry? _currentEntry;

  @override
  void initState() {
    super.initState();
    _updateEntriesList();
  }

  @override
  void didUpdateWidget(AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateEntriesList();
  }

  /// In place operation to shift a child entry to the end of the list (the visual front).
  ///
  /// If entry is null, this is a no-op.
  void _moveToEnd(List<_ChildEntry> entries, _ChildEntry? entry) {
    if (entry == null) return;
    entries.remove(entry);
    entries.add(entry);
  }

  /// Inserts an entry as last place in the list and animates it.
  ///
  /// If entry is null, this is a no-op.
  void _insertAndAnimate(
    List<_ChildEntry> entries,
    _ChildEntry? entry,
    _ChildAnimationDirection direction,
  ) {
    if (entry == null) return;
    _moveToEnd(entries, entry);
    switch (direction) {
      case _ChildAnimationDirection.primaryForward:
        entry.primaryController.forward(from: 0);
        entry.secondaryController.value = 0;
      case _ChildAnimationDirection.primaryReverse:
        entry.primaryController.reverse(from: 1);
        entry.secondaryController.value = 0;
      case _ChildAnimationDirection.secondaryForward:
        entry.primaryController.value = 1;
        entry.secondaryController.forward(from: 0);
      case _ChildAnimationDirection.secondaryReverse:
        entry.primaryController.value = 1;
        entry.secondaryController.reverse(from: 1);
    }
  }

  /// Updates the list of child entries.
  /// Ensures to order the list appropriately and animate entries in and out.
  void _updateEntriesList() {
    final List<_ChildEntry> entries = [];

    final _ChildEntry? previousEntry = _currentEntry;
    _ChildEntry? currentEntry;

    Widget? currentChild;
    if (widget.index != null && widget.children.isNotEmpty) {
      currentChild = widget.children[widget.index!];
    }

    for (final child in widget.children) {
      // We find the previous entry by looking for an identical child widget.
      // If the children of this Stack share widget types, they must be given unique keys.
      final int existingIndex =
          _entries.indexWhere((entry) => Widget.canUpdate(entry.child, child));

      _ChildEntry? existingEntry;
      if (existingIndex != -1) {
        existingEntry = _entries[existingIndex];
      }

      _ChildEntry entry;

      if (existingEntry != null) {
        // If we find an existing entry, we update its child widget and reuse it.
        // This ensures it continues to use the same global key and animation controllers.
        existingEntry.child = child;
        existingEntry.primaryController.duration = widget.duration;
        existingEntry.secondaryController.duration = widget.duration;
        entry = existingEntry;
      } else {
        entry = _newEntry(child);
      }

      if (currentChild == child) {
        currentEntry = entry;
      }

      entries.add(entry);
    }

    final bool hasChanged = previousEntry != currentEntry;
    final bool previousWasRemoved =
        previousEntry != null && !entries.contains(previousEntry);

    if (hasChanged) {
      if (widget.reverse) {
        // When reverse is true, the new child will transition in below the
        // old child while its secondary animation and the primary
        // animation of the old child are running in reverse. This is similar to
        // the transition associated with popping a [PageRoute] to reveal a new
        // [PageRoute] below it.
        _insertAndAnimate(
          entries,
          currentEntry,
          _ChildAnimationDirection.secondaryReverse,
        );
        _insertAndAnimate(
          entries,
          previousEntry,
          _ChildAnimationDirection.primaryReverse,
        );
        if (previousWasRemoved) {
          previousEntry.primaryController.addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              setState(() {
                _entries.remove(previousEntry);
                previousEntry.dispose();
              });
            }
          });
        }
      } else {
        // When reverse is false, the new child will transition in on top of the
        // old child while its primary animation and the secondary
        // animation of the old child are running forward. This is similar to
        // the transition associated with pushing a new [PageRoute] on top of
        // another.
        _insertAndAnimate(
          entries,
          previousEntry,
          _ChildAnimationDirection.secondaryForward,
        );
        _insertAndAnimate(
          entries,
          currentEntry,
          _ChildAnimationDirection.primaryForward,
        );
        if (previousWasRemoved) {
          previousEntry.secondaryController.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _entries.remove(previousEntry);
                previousEntry.dispose();
              });
            }
          });
        }
      }
    } else {
      if (widget.reverse) {
        _moveToEnd(entries, currentEntry);
        _moveToEnd(entries, previousEntry);
      } else {
        _moveToEnd(entries, previousEntry);
        _moveToEnd(entries, currentEntry);
      }
    }

    setState(() {
      _entries = entries;
      _currentEntry = currentEntry;
    });
  }

  _ChildEntry _newEntry(Widget child) => _ChildEntry(
        key: GlobalKey(),
        child: child,
        primaryController: AnimationController(
          duration: widget.duration,
          vsync: this,
        ),
        secondaryController: AnimationController(
          duration: widget.duration,
          vsync: this,
        ),
      );

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  Widget _buildChild(_ChildEntry entry) => AnimatedBuilder(
        animation: Listenable.merge([
          entry.primaryController,
          entry.secondaryController,
        ]),
        builder: (context, child) {
          final bool isVisible = entry.primaryController.isAnimating ||
              entry.secondaryController.isAnimating ||
              entry == _currentEntry;

          return Visibility(
            visible: isVisible,
            maintainState: true,
            child: widget.transitionBuilder(
              KeyedSubtree(
                key: entry.key,
                child: child!,
              ),
              entry.primaryController,
              entry.secondaryController,
            ),
          );
        },
        child: entry.child,
      );

  @override
  Widget build(BuildContext context) {
    return widget.layoutBuilder(_entries.map(_buildChild).toList());
  }
}
