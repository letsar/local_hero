# local_hero

[![Pub][pub_badge]][pub]

A widget which implicitly launches a hero animation when its position changed within the same route.

![Overview][overview]

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  local_hero:
```

In your library add the following import:

```dart
import 'package:local_hero/local_hero.dart';
```

## Usage

To be animated implicitly, a widget needs to be surrounded by a `LocalHero` widget with a unique `tag`:

```dart
const LocalHero(
    tag: 'my_widget_tag',
    child: MyWidget(),
),
```

A `LocalHero` widget must have a `LocalHeroScope` ancestor which hosts the animations properties (duration, curve, etc.).
At each frame we must have only one `LocalHero` per tag, per `LocalHeroScope`.

The following example shows the basic usage of a `LocalHero` widget:

```dart
class _LocalHeroPage extends StatelessWidget {
  const _LocalHeroPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LocalHeroScope(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: const _LocalHeroPlayground(),
        ),
      ),
    );
  }
}

class _LocalHeroPlayground extends StatefulWidget {
  const _LocalHeroPlayground({
    Key key,
  }) : super(key: key);

  @override
  _LocalHeroPlaygroundState createState() => _LocalHeroPlaygroundState();
}

class _LocalHeroPlaygroundState extends State<_LocalHeroPlayground> {
  AlignmentGeometry alignment = Alignment.topLeft;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: alignment,
              child: const LocalHero(
                tag: 'id',
                child: _Box(),
              ),
            ),
          ),
        ),
        RaisedButton(
          onPressed: () {
            setState(() {
              alignment = alignment == Alignment.topLeft
                  ? Alignment.bottomRight
                  : Alignment.topLeft;
            });
          },
          child: const Text('Move'),
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: 50,
      height: 50,
    );
  }
}
```

![Example][example]

## Sponsoring

I'm working on my packages on my free-time, but I don't have as much time as I would. If this package or any other package I created is helping you, please consider to sponsor me so that I can take time to read the issues, fix bugs, merge pull requests and add features to these packages.

## Changelog

Please see the [Changelog][changelog] page to know what's recently changed.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue][issue].  
If you fixed a bug or implemented a feature, please send a [pull request][pr].

<!--Links-->
[pub_badge]: https://img.shields.io/pub/v/local_hero.svg
[pub]: https://pub.dartlang.org/packages/local_hero
[changelog]: https://github.com/letsar/local_hero/blob/master/CHANGELOG.md
[issue]: https://github.com/letsar/local_hero/issues
[pr]: https://github.com/letsar/local_hero/pulls
[example]: https://raw.githubusercontent.com/letsar/local_hero/master/packages/images/local_hero.gif
[overview]: https://raw.githubusercontent.com/letsar/local_hero/master/packages/images/local_hero_02.gif
