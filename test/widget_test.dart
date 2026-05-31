import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gomoku/main.dart';
import 'package:gomoku/widgets/gomoku_board.dart';

void main() {
  testWidgets('Gomoku app shows the first turn, timer, and restart button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GomokuApp());

    expect(find.text('흑돌 차례'), findsOneWidget);
    expect(find.text('60초'), findsOneWidget);
    expect(find.text('게임 재시작'), findsOneWidget);
  });

  testWidgets('Turn changes when the timer reaches zero', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GomokuApp());

    await tester.pump(const Duration(seconds: 60));

    expect(find.text('백돌 차례'), findsOneWidget);
    expect(find.text('60초'), findsOneWidget);
  });

  testWidgets('Last move is passed to the board painter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GomokuApp());

    final Finder boardFinder = _findGomokuBoard();
    await _tapIntersection(tester, boardFinder, row: 7, col: 7);

    final GomokuBoardPainter painter = _boardPainter(tester, boardFinder);

    expect(painter.lastMoveRow, 7);
    expect(painter.lastMoveCol, 7);
    expect(find.text('60초'), findsOneWidget);
  });

  testWidgets('Undo removes the last move and returns the turn', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GomokuApp());

    final Finder boardFinder = _findGomokuBoard();
    await _tapIntersection(tester, boardFinder, row: 7, col: 7);

    expect(find.text('백돌 차례'), findsOneWidget);

    await tester.tap(find.text('무르기'));
    await tester.pump();

    final GomokuBoardPainter painter = _boardPainter(tester, boardFinder);

    expect(find.text('흑돌 차례'), findsOneWidget);
    expect(painter.board[7][7], 0);
    expect(painter.lastMoveRow, isNull);
    expect(painter.lastMoveCol, isNull);
  });

  testWidgets('Black cannot place a double-three forbidden move', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GomokuApp());

    final Finder boardFinder = _findGomokuBoard();

    await _tapIntersection(tester, boardFinder, row: 7, col: 6); // 흑
    await _tapIntersection(tester, boardFinder, row: 0, col: 0); // 백
    await _tapIntersection(tester, boardFinder, row: 7, col: 8); // 흑
    await _tapIntersection(tester, boardFinder, row: 0, col: 1); // 백
    await _tapIntersection(tester, boardFinder, row: 6, col: 7); // 흑
    await _tapIntersection(tester, boardFinder, row: 0, col: 2); // 백
    await _tapIntersection(tester, boardFinder, row: 8, col: 7); // 흑
    await _tapIntersection(tester, boardFinder, row: 0, col: 3); // 백
    await _tapIntersection(tester, boardFinder, row: 7, col: 7); // 금수

    final GomokuBoardPainter painter = _boardPainter(tester, boardFinder);

    expect(find.text('금수입니다'), findsOneWidget);
    expect(painter.board[7][7], 0);
  });

  testWidgets('Black wins and passes the winning line to the board painter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GomokuApp());

    final Finder boardFinder = _findGomokuBoard();

    await _tapIntersection(tester, boardFinder, row: 7, col: 0); // 흑
    await _tapIntersection(tester, boardFinder, row: 8, col: 0); // 백
    await _tapIntersection(tester, boardFinder, row: 7, col: 1); // 흑
    await _tapIntersection(tester, boardFinder, row: 8, col: 1); // 백
    await _tapIntersection(tester, boardFinder, row: 7, col: 2); // 흑
    await _tapIntersection(tester, boardFinder, row: 8, col: 2); // 백
    await _tapIntersection(tester, boardFinder, row: 7, col: 3); // 흑
    await _tapIntersection(tester, boardFinder, row: 8, col: 3); // 백
    await _tapIntersection(tester, boardFinder, row: 7, col: 4); // 흑

    final GomokuBoardPainter painter = _boardPainter(tester, boardFinder);

    expect(find.text('흑돌 승리!'), findsOneWidget);
    expect(find.text('종료'), findsOneWidget);
    expect(painter.winningLine.length, 5);
    expect(painter.winningLine.first.row, 7);
    expect(painter.winningLine.first.col, 0);
    expect(painter.winningLine.last.row, 7);
    expect(painter.winningLine.last.col, 4);
  });
}

Finder _findGomokuBoard() {
  return find.byWidgetPredicate((Widget widget) {
    return widget is CustomPaint && widget.painter is GomokuBoardPainter;
  });
}

GomokuBoardPainter _boardPainter(WidgetTester tester, Finder boardFinder) {
  final CustomPaint boardPaint = tester.widget<CustomPaint>(boardFinder);
  return boardPaint.painter! as GomokuBoardPainter;
}

Future<void> _tapIntersection(
  WidgetTester tester,
  Finder boardFinder, {
  required int row,
  required int col,
}) async {
  final Offset boardTopLeft = tester.getTopLeft(boardFinder);
  final Size boardSize = tester.getSize(boardFinder);
  final double gap = (boardSize.shortestSide - 40) / 14;

  await tester.tapAt(boardTopLeft + Offset(20 + gap * col, 20 + gap * row));
  await tester.pump();
}
