import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_hero/local_hero.dart';
import 'package:local_hero/src/widgets/local_hero_layer.dart';

void main() {
  group('LocalHero', () {
    testWidgets('must be a descendant of `LocalHeroScope`', (tester) async {
      await tester.pumpWidget(
        const LocalHero(
          tag: '0',
          child: SizedBox(),
        ),
      );

      expect(
        tester.takeException().toString(),
        contains('No LocalHeroScope for a LocalHero'),
      );
    });

    testWidgets('should animating after position changed', (tester) async {
      final List<Offset> positions = <Offset>[];
      void recordMetrics() {
        positions.add(tester.getTopLeft(find.byType(MyBox)));
      }

      await tester.pumpWidget(
        const TestWidget(
          position: Offset(0, 0),
        ),
      );

      expect(find.byType(LocalHeroFollower), findsNothing);

      await tester.pumpWidget(
        const TestWidget(
          position: Offset(100, 100),
        ),
      );

      await tester.pump();
      recordMetrics(); // t=0

      await tester.pump(const Duration(milliseconds: 100));
      recordMetrics(); // t=100.

      await tester.pump(const Duration(milliseconds: 100));
      recordMetrics(); // t=200.

      await tester.pump(const Duration(milliseconds: 100));
      recordMetrics(); // t=300.

      await tester.pump(const Duration(milliseconds: 100));
      recordMetrics(); // t=400.

      await tester.pump(const Duration(milliseconds: 100));
      recordMetrics(); // t=500.

      expect(positions, [
        const Offset(0, 0),
        const Offset(20, 20),
        const Offset(40, 40),
        const Offset(60, 60),
        const Offset(80, 80),
        const Offset(100, 100),
      ]);
    });
  });
}

class TestWidget extends StatelessWidget {
  const TestWidget({
    Key? key,
    required this.position,
  }) : super(key: key);

  final Offset position;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocalHeroScope(
        duration: const Duration(milliseconds: 500),
        createRectTween: (begin, end) {
          return RectTween(begin: begin, end: end);
        },
        child: Align(
          alignment: Alignment.topLeft,
          child: Stack(
            children: [
              Positioned(
                top: position.dy,
                left: position.dx,
                child: const LocalHero(
                  tag: 'id',
                  child: MyBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyBox extends StatelessWidget {
  const MyBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: ColoredBox(
        color: Colors.red,
      ),
    );
  }
}
