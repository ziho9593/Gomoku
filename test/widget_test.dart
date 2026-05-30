import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gomoku/main.dart';

void main() {
  testWidgets('Gomoku app shows the first turn and restart button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GomokuApp());

    expect(find.text('현재 차례: 흑돌'), findsOneWidget);
    expect(find.text('게임 재시작'), findsOneWidget);
  });

  testWidgets('Black wins after making five stones in a row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GomokuApp());

    final Finder boardFinder = find.byWidgetPredicate((Widget widget) {
      return widget is CustomPaint &&
          widget.painter.runtimeType.toString() == 'GomokuBoardPainter';
    });
    final Offset boardTopLeft = tester.getTopLeft(boardFinder);
    final Size boardSize = tester.getSize(boardFinder);
    final double gap = (boardSize.shortestSide - 40) / 14;

    Future<void> tapIntersection(int row, int col) async {
      await tester.tapAt(
        boardTopLeft + Offset(20 + gap * col, 20 + gap * row),
      );
      await tester.pump();
    }

    await tapIntersection(7, 0); // 흑
    await tapIntersection(8, 0); // 백
    await tapIntersection(7, 1); // 흑
    await tapIntersection(8, 1); // 백
    await tapIntersection(7, 2); // 흑
    await tapIntersection(8, 2); // 백
    await tapIntersection(7, 3); // 흑
    await tapIntersection(8, 3); // 백
    await tapIntersection(7, 4); // 흑

    expect(find.text('흑돌 승리!'), findsOneWidget);
  });
}
