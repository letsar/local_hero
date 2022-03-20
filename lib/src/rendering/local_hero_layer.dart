import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:local_hero/src/rendering/controller.dart';
import 'package:local_hero/src/rendering/layer.dart';

// ignore_for_file: public_member_api_docs

class RenderLocalHeroLeaderLayer extends RenderProxyBox {
  /// Creates a render object that uses a [LeaderLayer].
  ///
  /// The [controller] must not be null.
  RenderLocalHeroLeaderLayer({
    required LocalHeroController controller,
    RenderBox? child,
  }) : super(child) {
    _controller = controller..addStatusListener(_onAnimationStatusChanged);
  }

  LocalHeroController get controller => _controller;
  late LocalHeroController _controller;
  set controller(LocalHeroController value) {
    if (_controller != value) {
      _controller.removeStatusListener(_onAnimationStatusChanged);
      _controller = value;
      _controller.addStatusListener(_onAnimationStatusChanged);
      markNeedsPaint();
    }
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      if (!(debugDisposed ?? true)) {
        markNeedsPaint();
      }
    }
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) {
    return !controller.isAnimating &&
        super.hitTest(result, position: position!);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = Rect.fromPoints(offset, size.bottomRight(offset));
    _controller.animateIfNeeded(rect);

    if (layer == null) {
      layer = LeaderLayer(link: controller.link, offset: offset);
    } else {
      final LeaderLayer leaderLayer = layer as LeaderLayer;
      leaderLayer
        ..link = controller.link
        ..offset = offset;
    }

    // We need to hide the leader when the controller is animating if we just
    // changed of position.
    final painter = controller.isAnimating
        ? (PaintingContext context, Offset offset) =>
            context.pushOpacity(offset, 0, super.paint)
        : super.paint;

    context.pushLayer(layer!, painter, Offset.zero);

    assert(layer != null);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (!controller.isAnimating) {
      super.visitChildrenForSemantics(visitor);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<LocalHeroController>('controller', controller),
    );
  }
}

class RenderLocalHeroFollowerLayer extends RenderProxyBox {
  RenderLocalHeroFollowerLayer({
    required LocalHeroController controller,
    RenderBox? child,
  }) : super(child) {
    _controller = controller..addListener(markNeedsLayout);
  }

  LocalHeroController get controller => _controller;
  late LocalHeroController _controller;
  set controller(LocalHeroController value) {
    if (_controller != value) {
      _controller.removeListener(markNeedsLayout);
      _controller = value;
      _controller.addListener(markNeedsLayout);
      markNeedsPaint();
    }
  }

  @override
  void detach() {
    layer = null;
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  /// The layer we created when we were last painted.
  @override
  LocalHeroLayer? get layer => super.layer as LocalHeroLayer?;

  /// Return the transform that was used in the last composition phase, if any.
  ///
  /// If the [FollowerLayer] has not yet been created, was never composited, or
  /// was unable to determine the transform (see
  /// [FollowerLayer.getLastTransform]), this returns the identity matrix (see
  /// [new Matrix4.identity].
  Matrix4 getCurrentTransform() {
    return layer?.getLastTransform() ?? Matrix4.identity();
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) {
    // We can never interact with this follower.
    return false;
  }

  @override
  void performLayout() {
    final Size? requestedSize = controller.linkedSize;
    final BoxConstraints childConstraints = requestedSize == null
        ? constraints
        : constraints.enforce(BoxConstraints.tight(requestedSize));
    child!.layout(childConstraints, parentUsesSize: true);
    size = constraints.constrain(child!.size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (layer == null) {
      layer = LocalHeroLayer(controller: controller);
    } else {
      layer!.controller = controller;
    }

    context.pushLayer(
      layer!,
      super.paint,
      Offset.zero,
      childPaintBounds: const Rect.fromLTRB(
        // We don't know where we'll end up, so we have no idea what our cull rect should be.
        double.negativeInfinity,
        double.negativeInfinity,
        double.infinity,
        double.infinity,
      ),
    );
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (controller.isAnimating) {
      super.visitChildrenForSemantics(visitor);
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(getCurrentTransform());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LocalHeroController>(
      'controller',
      controller,
    ));
    properties.add(TransformProperty(
      'current transform matrix',
      getCurrentTransform(),
    ));
  }
}
