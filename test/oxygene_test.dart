import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oxygene/oxygene.dart';

void main() {
  testWidgets('Oxygene рисует переданный геном внутри рамки', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Oxygene(
              genome: '0,1-0*1v11,1-0*a,1-0*a',
              width: 52,
              height: 52,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Oxygene), findsOneWidget);
    expect(find.byType(PipeActDrawler), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Oxygene),
        matching: find.byWidgetPredicate(
          (w) => w is IgnorePointer && w.ignoring,
        ),
      ),
      findsOneWidget,
    );
  });

  test('PipeLogic.isKnot отличает развилку от листа', () {
    final logic = PipeLogic();
    expect(logic.isKnot('1-0*1v11'), isTrue);
    expect(logic.isKnot('1-0*a'), isFalse);
  });
}
