import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:local_hero/local_hero.dart';

void main() {
  runApp(const _LocalHeroApp());
}

class _LocalHeroApp extends StatelessWidget {
  const _LocalHeroApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LocalHeroScope(
      duration: const Duration(milliseconds: 500),
      createRectTween: (begin, end) {
        return RectTween(begin: begin, end: end);
      },
      curve: Curves.easeInOut,
      child: const MaterialApp(
        home: _LocalHeroPlayground(),
      ),
    );
  }
}

class _LocalHeroPlayground extends StatelessWidget {
  const _LocalHeroPlayground({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: <Widget>[
              Text('Animate wrap reordering'),
              Text('Move between containers'),
              Text('Draggable content'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: <Widget>[
              _WrapReorderingAnimation(),
              _AcrossContainersAnimation(),
              _DraggableExample(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileModel extends Equatable {
  const _TileModel({this.color, this.text});

  final Color? color;
  final String? text;

  @override
  List<Object?> get props => [color, text];

  @override
  String toString() {
    return text!;
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    Key? key,
    required this.model,
    required this.size,
    this.onTap,
  }) : super(key: key);

  final _TileModel model;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return LocalHero(
      tag: model.text!,
      child: GestureDetector(
        onTap: onTap,
        child: _RawTile(
          model: model,
          size: size,
        ),
      ),
    );
  }
}

class _RawTile extends StatelessWidget {
  const _RawTile({
    Key? key,
    required this.model,
    required this.size,
  }) : super(key: key);

  final _TileModel? model;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: model!.color,
      height: size,
      width: size,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CircleAvatar(
          backgroundColor: Colors.white70,
          foregroundColor: Colors.black54,
          child: Text(model!.text!),
        ),
      ),
    );
  }
}

class _WrapReorderingAnimation extends StatefulWidget {
  const _WrapReorderingAnimation({
    Key? key,
  }) : super(key: key);

  @override
  _WrapReorderingAnimationState createState() =>
      _WrapReorderingAnimationState();
}

class _WrapReorderingAnimationState extends State<_WrapReorderingAnimation> {
  final List<_TileModel> tiles = <_TileModel>[];
  double spacing = 10;
  double runSpacing = 10;

  @override
  void initState() {
    super.initState();
    const List<MaterialColor> colors = Colors.primaries;
    for (var i = 0; i < colors.length; i++) {
      tiles.add(_TileModel(color: colors[i], text: '$i'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: LocalHeroOverlay(
              child: Center(
                child: Wrap(
                  spacing: spacing,
                  runSpacing: runSpacing,
                  children: <Widget>[
                    ...tiles.map(
                      (tile) => _Tile(
                        key: ValueKey(tile),
                        size: 80,
                        model: tile,
                        onTap: () {
                          setState(() {
                            final int index = tiles.indexOf(tile);
                            final int swappedIndex = (index + 5) % tiles.length;
                            tiles[index] = tiles[swappedIndex];
                            tiles[swappedIndex] = tile;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Slider(
          max: 30,
          divisions: 3,
          value: spacing,
          onChanged: (value) => setState(() => spacing = value),
        ),
        Slider(
          max: 30,
          divisions: 3,
          value: runSpacing,
          onChanged: (value) => setState(() => runSpacing = value),
        ),
      ],
    );
  }
}

class _AcrossContainersAnimation extends StatefulWidget {
  const _AcrossContainersAnimation({
    Key? key,
  }) : super(key: key);

  @override
  _AcrossContainersAnimationState createState() =>
      _AcrossContainersAnimationState();
}

class _AcrossContainersAnimationState
    extends State<_AcrossContainersAnimation> {
  final List<_TileModel> rowTiles = <_TileModel>[];
  final List<_TileModel> colTiles = <_TileModel>[];

  @override
  void initState() {
    super.initState();
    const List<MaterialColor> primaries = Colors.primaries;
    for (var i = 0; i < 5; i++) {
      final _TileModel tile = _TileModel(color: primaries[i], text: 'p$i');
      rowTiles.add(tile);
    }
    const List<MaterialAccentColor> accents = Colors.accents;
    for (var i = 0; i < 5; i++) {
      final _TileModel tile = _TileModel(color: accents[i], text: 'a$i');
      colTiles.add(tile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ...rowTiles.map(
                (tile) => _Tile(
                  key: ValueKey(tile),
                  model: tile,
                  size: 60,
                  onTap: () {
                    setState(() {
                      colTiles.add(tile);
                      rowTiles.remove(tile);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Column(
            children: <Widget>[
              ...colTiles.map(
                (tile) => _Tile(
                  key: ValueKey(tile),
                  model: tile,
                  size: 60,
                  onTap: () {
                    setState(() {
                      rowTiles.add(tile);
                      colTiles.remove(tile);
                    });
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _DraggableExample extends StatefulWidget {
  const _DraggableExample({
    Key? key,
  }) : super(key: key);

  @override
  _DraggableExampleState createState() => _DraggableExampleState();
}

class _DraggableExampleState extends State<_DraggableExample> {
  final List<_TileModel?> tiles = <_TileModel?>[];

  @override
  void initState() {
    super.initState();
    const List<MaterialColor> colors = Colors.primaries;
    for (var i = 0; i < colors.length; i++) {
      tiles.add(_TileModel(color: colors[i], text: 'd$i'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: <Widget>[
          ...tiles.map(
            (tile) => DragTarget<_TileModel>(
              key: ValueKey(tile),
              onWillAccept: (data) {
                final bool accept = data != tile;
                if (accept) {
                  onDrag(data, tile);
                }
                return accept;
              },
              builder: (context, candidateData, rejectedData) {
                return _DraggableTile(model: tile);
              },
            ),
          ),
        ],
      ),
    );
  }

  void onDrag(_TileModel? source, _TileModel? target) {
    // source comes before target.
    final int index = tiles.indexOf(target);
    tiles.remove(source);
    tiles.insert(index, source);
    setState(() {});
  }
}

class _DraggableTile extends StatefulWidget {
  _DraggableTile({
    Key? key,
    this.model,
  })  : child = _RawTile(model: model, size: 80),
        super(key: key);

  final _TileModel? model;
  final Widget child;

  @override
  _DraggableTileState createState() => _DraggableTileState();
}

class _DraggableTileState extends State<_DraggableTile> {
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    return Draggable<_TileModel>(
      onDragStarted: () {
        dragging = true;
      },
      onDragEnd: (details) {
        dragging = false;
      },
      data: widget.model,
      feedback: widget.child,
      childWhenDragging: Container(width: 80, height: 80),
      child: LocalHero(
        tag: widget.model!,
        enabled: !dragging,
        child: widget.child,
      ),
    );
  }
}

class LocalHeroOverlay extends StatefulWidget {
  const LocalHeroOverlay({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  _LocalHeroOverlayState createState() => _LocalHeroOverlayState();
}

class _LocalHeroOverlayState extends State<LocalHeroOverlay> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Overlay(
        initialEntries: <OverlayEntry>[
          OverlayEntry(builder: (context) => widget.child!),
        ],
      ),
    );
  }
}

class TestOne extends StatefulWidget {
  const TestOne({
    Key? key,
  }) : super(key: key);

  @override
  _TestOneState createState() => _TestOneState();
}

class _TestOneState extends State<TestOne> {
  final List<Widget> children = <Widget>[
    LocalHero(
      tag: 0,
      key: const ValueKey(0),
      child: Container(
        height: 20,
        width: 20,
        color: Colors.green,
      ),
    ),
    LocalHero(
      tag: 1,
      key: const ValueKey(1),
      child: Container(
        height: 40,
        width: 40,
        color: Colors.yellow,
      ),
    ),
    LocalHero(
      tag: 2,
      key: const ValueKey(2),
      child: Container(
        height: 60,
        width: 60,
        color: Colors.red,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ...children,
        TextButton(
          onPressed: () {
            setState(() {
              children.shuffle();
            });
          },
          child: const Text('shuffle'),
        ),
      ],
    );
  }
}
