import 'package:flutter/material.dart';

import '../models/board_point.dart';

class GomokuBoard extends StatelessWidget {
  const GomokuBoard({
    super.key,
    required this.board,
    required this.boardSize,
    required this.empty,
    required this.blackStone,
    required this.lastMoveRow,
    required this.lastMoveCol,
    required this.winningLine,
    required this.onTapBoard,
  });

  static const double boardPadding = 20;

  final List<List<int>> board;
  final int boardSize;
  final int empty;
  final int blackStone;
  final int? lastMoveRow;
  final int? lastMoveCol;
  final List<BoardPoint> winningLine;
  final void Function(Offset tapPosition, Size boardAreaSize) onTapBoard;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final Size boardAreaSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            return GestureDetector(
              onTapUp: (details) {
                onTapBoard(details.localPosition, boardAreaSize);
              },
              child: CustomPaint(
                size: boardAreaSize,
                painter: GomokuBoardPainter(
                  board: board,
                  boardSize: boardSize,
                  empty: empty,
                  blackStone: blackStone,
                  padding: boardPadding,
                  lastMoveRow: lastMoveRow,
                  lastMoveCol: lastMoveCol,
                  winningLine: winningLine,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GomokuBoardPainter extends CustomPainter {
  const GomokuBoardPainter({
    required this.board,
    required this.boardSize,
    required this.empty,
    required this.blackStone,
    required this.padding,
    required this.lastMoveRow,
    required this.lastMoveCol,
    required this.winningLine,
  });

  final List<List<int>> board;
  final int boardSize;
  final int empty;
  final int blackStone;
  final double padding;
  final int? lastMoveRow;
  final int? lastMoveCol;
  final List<BoardPoint> winningLine;

  static const List<BoardPoint> starPoints = [
    BoardPoint(3, 3),
    BoardPoint(3, 11),
    BoardPoint(7, 7),
    BoardPoint(11, 3),
    BoardPoint(11, 11),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Rect boardRect = Offset.zero & size;
    final double gap = (size.shortestSide - padding * 2) / (boardSize - 1);
    final double lineStart = padding;
    final double lineEnd = lineStart + gap * (boardSize - 1);

    _drawBoardBackground(canvas, boardRect);
    _drawBoardLines(canvas, lineStart, lineEnd, gap);
    _drawStarPoints(canvas, lineStart, gap);
    _drawStones(canvas, lineStart, gap);
    _drawWinningLine(canvas, lineStart, gap);
    _drawLastMoveMarker(canvas, lineStart, gap);
  }

  void _drawBoardBackground(Canvas canvas, Rect boardRect) {
    final Paint backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE8BE72),
          Color(0xFFD39A4A),
          Color(0xFFC88937),
        ],
      ).createShader(boardRect);
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF5D3218)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(boardRect, backgroundPaint);
    canvas.drawRect(boardRect.deflate(1.5), borderPaint);
  }

  void _drawBoardLines(
    Canvas canvas,
    double lineStart,
    double lineEnd,
    double gap,
  ) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFF5F371F).withValues(alpha: 0.78)
      ..strokeWidth = 1;

    for (int i = 0; i < boardSize; i++) {
      final double position = lineStart + gap * i;

      canvas.drawLine(
        Offset(lineStart, position),
        Offset(lineEnd, position),
        linePaint,
      );
      canvas.drawLine(
        Offset(position, lineStart),
        Offset(position, lineEnd),
        linePaint,
      );
    }
  }

  void _drawStarPoints(Canvas canvas, double lineStart, double gap) {
    final Paint starPaint = Paint()
      ..color = const Color(0xFF4A2B19)
      ..style = PaintingStyle.fill;

    for (final BoardPoint point in starPoints) {
      canvas.drawCircle(
        _pointCenter(point, lineStart, gap),
        gap * 0.11,
        starPaint,
      );
    }
  }

  void _drawStones(Canvas canvas, double lineStart, double gap) {
    final double stoneRadius = gap * 0.38;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final int stone = board[row][col];

        if (stone == empty) {
          continue;
        }

        final Offset center = Offset(
          lineStart + gap * col,
          lineStart + gap * row,
        );

        _drawStone(canvas, center, stoneRadius, stone);
      }
    }
  }

  void _drawStone(Canvas canvas, Offset center, double radius, int stone) {
    final bool isBlack = stone == blackStone;
    final Rect stoneRect = Rect.fromCircle(center: center, radius: radius);
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    final Paint stonePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.9,
        colors: isBlack
            ? const [Color(0xFF55504A), Color(0xFF111111), Color(0xFF000000)]
            : const [Color(0xFFFFFFFF), Color(0xFFF1EEE7), Color(0xFFD8D1C8)],
      ).createShader(stoneRect);
    final Paint stoneBorderPaint = Paint()
      ..color = isBlack ? Colors.black : const Color(0xFF8E867B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center + const Offset(1.6, 2.2), radius, shadowPaint);
    canvas.drawCircle(center, radius, stonePaint);
    canvas.drawCircle(center, radius, stoneBorderPaint);
  }

  void _drawWinningLine(Canvas canvas, double lineStart, double gap) {
    if (winningLine.length < 2) {
      return;
    }

    final Offset start = _pointCenter(winningLine.first, lineStart, gap);
    final Offset end = _pointCenter(winningLine.last, lineStart, gap);
    final Paint glowPaint = Paint()
      ..color = const Color(0xFFFFF176).withValues(alpha: 0.65)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = gap * 0.5;
    final Paint linePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    canvas.drawLine(start, end, glowPaint);
    canvas.drawLine(start, end, linePaint);
  }

  void _drawLastMoveMarker(Canvas canvas, double lineStart, double gap) {
    if (lastMoveRow == null || lastMoveCol == null) {
      return;
    }

    final Offset center = Offset(
      lineStart + gap * lastMoveCol!,
      lineStart + gap * lastMoveRow!,
    );
    final Paint markerPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, gap * 0.22, markerPaint);
  }

  Offset _pointCenter(BoardPoint point, double lineStart, double gap) {
    return Offset(lineStart + gap * point.col, lineStart + gap * point.row);
  }

  @override
  bool shouldRepaint(covariant GomokuBoardPainter oldDelegate) {
    return true;
  }
}
