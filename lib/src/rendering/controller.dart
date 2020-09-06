import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

// ignore_for_file: public_member_api_docs

/// Signature for a function that takes two [Rect] instances and returns a
/// [RectTween] that transitions between them.
typedef RectTweenSupplier = Tween<Rect> Function(Rect begin, Rect end);

class LocalHeroController {
  LocalHeroController({
    @required TickerProvider vsync,
    @required Duration duration,
    @required this.curve,
    @required this.createRectTween,
    @required this.tag,
  })  : assert(createRectTween != null),
        assert(tag != null),
        link = LayerLink() {
    _controller = AnimationController(vsync: vsync, duration: duration)
      ..addStatusListener(_onAnimationStatusChanged);
  }

  final Object tag;

  final LayerLink link;

  AnimationController _controller;
  Animation<Rect> _animation;
  Rect _lastRect;

  Curve curve;
  RectTweenSupplier createRectTween;

  Duration get duration => _controller.duration;
  set duration(Duration value) {
    _controller.duration = value;
  }

  bool get isAnimating => _isAnimating;
  bool _isAnimating = false;

  Animation<double> get view => _controller.view;

  Offset get linkedOffset => _animation?.value?.topLeft ?? _lastRect.topLeft;

  Size get linkedSize => _animation?.value?.size ?? _lastRect?.size;

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _isAnimating = false;
      _animation = null;
      _controller.value = 0;
    }
  }

  void animateIfNeeded(Rect rect) {
    if (_lastRect != null && _lastRect != rect) {
      final bool inAnimation = isAnimating;
      Rect from = Rect.fromLTWH(
        _lastRect.left - rect.left,
        _lastRect.top - rect.top,
        _lastRect.width,
        _lastRect.height,
      );
      if (inAnimation) {
        // We need to recompute the from.
        final Rect currentRect = _animation.value;
        from = Rect.fromLTWH(
          currentRect.left + _lastRect.left - rect.left,
          currentRect.top + _lastRect.top - rect.top,
          currentRect.width,
          currentRect.height,
        );
      }
      _isAnimating = true;

      _animation = _controller.drive(CurveTween(curve: curve)).drive(
            createRectTween(
              from,
              Rect.fromLTWH(
                0,
                0,
                rect.width,
                rect.height,
              ),
            ),
          );

      if (!inAnimation) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _controller.forward();
        });
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          final Duration duration =
              _controller.duration * (1 - _controller.value);
          _controller.reset();
          _controller.animateTo(
            1,
            duration: duration,
          );
        });
      }
    }
    _lastRect = rect;
  }

  void dispose() {
    _controller.stop();
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _controller.dispose();
  }

  void addListener(VoidCallback listener) {
    _controller.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    _controller.removeListener(listener);
  }

  void addStatusListener(AnimationStatusListener listener) {
    _controller.addStatusListener(listener);
  }

  void removeStatusListener(AnimationStatusListener listener) {
    _controller.removeStatusListener(listener);
  }
}
