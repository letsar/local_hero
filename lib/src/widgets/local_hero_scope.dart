import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:local_hero/src/rendering/controller.dart';
import 'package:local_hero/src/widgets/local_hero.dart';
import 'package:local_hero/src/widgets/local_hero_layer.dart';

// ignore_for_file: public_member_api_docs

/// A widget under which you can create [LocalHero] widgets.
class LocalHeroScope extends StatefulWidget {
  /// Creates a [LocalHeroScope].
  /// All local hero animations under this widget, will have the specified
  /// [duration], [curve], and [createRectTween].
  const LocalHeroScope({
    Key? key,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    this.createRectTween = _defaultCreateTweenRect,
    required this.child,
  }) : super(key: key);

  /// The duration of the animation.
  final Duration duration;

  /// The curve for the hero animation.
  final Curve curve;

  /// Defines how the destination hero's bounds change as it flies from the
  /// starting position to the destination position.
  ///
  /// The default value creates a [MaterialRectArcTween].
  final CreateRectTween createRectTween;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  _LocalHeroScopeState createState() => _LocalHeroScopeState();
}

class _LocalHeroScopeState extends State<LocalHeroScope>
    with TickerProviderStateMixin
    implements LocalHeroScopeState {
  final Map<Object, _LocalHeroTracker> trackers = <Object, _LocalHeroTracker>{};

  @override
  LocalHeroController track(BuildContext context, LocalHero localHero) {
    final _LocalHeroTracker tracker = trackers.putIfAbsent(
      localHero.tag,
      () => createTracker(context, localHero),
    );
    tracker.count++;
    return tracker.controller;
  }

  _LocalHeroTracker createTracker(BuildContext context, LocalHero localHero) {
    final LocalHeroController controller = LocalHeroController(
      duration: widget.duration,
      createRectTween: widget.createRectTween,
      curve: widget.curve,
      tag: localHero.tag,
      vsync: this,
    );
    final Widget shuttle = localHero.flightShuttleBuilder?.call(
          context,
          controller.view,
          localHero.child,
        ) ??
        localHero.child;

    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        return LocalHeroFollower(
          controller: controller,
          child: shuttle,
        );
      },
    );

    final _LocalHeroTracker tracker = _LocalHeroTracker(
      controller: controller,
      overlayEntry: overlayEntry,
    );

    tracker.addOverlay(context);
    return tracker;
  }

  @override
  void untrack(LocalHero localHero) {
    final _LocalHeroTracker? tracker = trackers[localHero.tag];
    if (tracker != null) {
      tracker.count--;
      if (tracker.count == 0) {
        trackers.remove(localHero.tag);
        disposeTracker(tracker);
      }
    }
  }

  @override
  void dispose() {
    trackers.values.forEach(disposeTracker);
    super.dispose();
  }

  void disposeTracker(_LocalHeroTracker tracker) {
    tracker.controller.dispose();
    tracker.removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedLocalHeroScopeState(
      state: this,
      child: widget.child,
    );
  }
}

abstract class LocalHeroScopeState {
  LocalHeroController track(BuildContext context, LocalHero localHero);

  void untrack(LocalHero localHero);
}

class _LocalHeroTracker {
  _LocalHeroTracker({
    required this.overlayEntry,
    required this.controller,
  });

  final OverlayEntry overlayEntry;
  final LocalHeroController controller;
  int count = 0;

  bool _removeRequested = false;
  bool _overlayInserted = false;

  void addOverlay(BuildContext context) {
    final OverlayState? overlayState = Overlay.of(context);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_removeRequested) {
        overlayState!.insert(overlayEntry);
        _overlayInserted = true;
      }
    });
  }

  void removeOverlay() {
    _removeRequested = true;
    if (_overlayInserted) {
      overlayEntry.remove();
    }
  }
}

class _InheritedLocalHeroScopeState extends InheritedWidget {
  const _InheritedLocalHeroScopeState({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  final LocalHeroScopeState state;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

extension BuildContextExtensions on BuildContext {
  T? getInheritedWidget<T extends InheritedWidget>() {
    final InheritedElement? elem = getElementForInheritedWidgetOfExactType<T>();
    return elem?.widget as T?;
  }

  LocalHeroScopeState getLocalHeroScopeState() {
    final inheritedState = getInheritedWidget<_InheritedLocalHeroScopeState>();
    assert(() {
      if (inheritedState == null) {
        throw FlutterError('No LocalHeroScope for a LocalHero\n'
            'When creating a LocalHero, you must ensure that there\n'
            'is a LocalHeroScope above the LocalHero.\n');
      }
      return true;
    }());

    return inheritedState!.state;
  }
}

RectTween _defaultCreateTweenRect(Rect? begin, Rect? end) {
  return MaterialRectArcTween(begin: begin, end: end);
}
