import 'package:devil_run/widgets/touch_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'direction remains pressed while finger moves and releases on up',
    (tester) async {
      var left = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TouchControls(
              onLeftChanged: (value) => left = value,
              onRightChanged: (_) {},
              onJump: () {},
            ),
          ),
        ),
      );

      final leftButton = find.byIcon(Icons.keyboard_arrow_left_rounded);
      final gesture = await tester.startGesture(tester.getCenter(leftButton));
      expect(left, isTrue);

      await gesture.moveBy(const Offset(20, -20));
      expect(left, isTrue);

      await gesture.up();
      expect(left, isFalse);
    },
  );

  testWidgets('removing controls releases a held direction', (tester) async {
    var left = false;
    var visible = true;
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Scaffold(
              body: visible
                  ? TouchControls(
                      onLeftChanged: (value) => left = value,
                      onRightChanged: (_) {},
                      onJump: () {},
                    )
                  : const SizedBox(),
            );
          },
        ),
      ),
    );

    await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.keyboard_arrow_left_rounded)),
    );
    expect(left, isTrue);

    rebuild(() => visible = false);
    await tester.pump();
    expect(left, isFalse);
  });
}
