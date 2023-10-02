import 'package:flutter/widgets.dart';
import 'package:local_hero/src/rendering/controller.dart';
import 'package:local_hero/src/rendering/local_hero_layer.dart';

// ignore_for_file: public_member_api_docs

class LocalHeroFollower extends SingleChildRenderObjectWidget {
  const LocalHeroFollower({
    Key? key,
    required this.controller,
    Widget? child,
  }) : super(
          key: key,
          child: child,
        );

  final LocalHeroController controller;

  @override
  _LocalHeroFollowerElement createElement() {
    return _LocalHeroFollowerElement(this);
  }

  @override
  RenderLocalHeroFollowerLayer createRenderObject(BuildContext context) {
    return RenderLocalHeroFollowerLayer(
      controller: controller,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLocalHeroFollowerLayer renderObject,
  ) {
    renderObject.controller = controller;
  }
}

class _LocalHeroFollowerElement extends SingleChildRenderObjectElement {
  _LocalHeroFollowerElement(LocalHeroFollower widget) : super(widget);

  @override
  LocalHeroFollower get widget => super.widget as LocalHeroFollower;

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    if (widget.controller.isAnimating) {
      super.debugVisitOnstageChildren(visitor);
    }
  }
}

class LocalHeroLeader extends SingleChildRenderObjectWidget {
  /// Creates a composited transform target widget.
  ///
  /// The [link] property must not be null, and must not be currently being used
  /// by any other [CompositedTransformTarget] object that is in the tree.
  const LocalHeroLeader({
    Key? key,
    required this.controller,
    Widget? child,
  }) : super(key: key, child: child);

  final LocalHeroController controller;

  @override
  _LocalHeroLeaderElement createElement() {
    return _LocalHeroLeaderElement(this);
  }

  @override
  RenderLocalHeroLeaderLayer createRenderObject(BuildContext context) {
    return RenderLocalHeroLeaderLayer(
      controller: controller,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLocalHeroLeaderLayer renderObject,
  ) {
    renderObject.controller = controller;
  }
}

class _LocalHeroLeaderElement extends SingleChildRenderObjectElement {
  _LocalHeroLeaderElement(LocalHeroLeader widget) : super(widget);

  @override
  LocalHeroLeader get widget => super.widget as LocalHeroLeader;

  /// Track the slot that this element is in to be able to call
  /// [LocalHeroController.markRemount] when the slot changes
  Object? _lastSlot;

  @override
  void update(SingleChildRenderObjectWidget newWidget) {
    super.update(newWidget);

    if (slot != _lastSlot) {
      // Mark remount due to slot change
      widget.controller.markRemount();
      _lastSlot = slot;
    }
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    // Mark remount due to reparenting
    widget.controller.markRemount();
    _lastSlot = newSlot;
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    if (!widget.controller.isAnimating) {
      super.debugVisitOnstageChildren(visitor);
    }
  }
}
