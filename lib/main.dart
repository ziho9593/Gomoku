import 'package:flutter/material.dart';

void main() {
  runApp(const GomokuApp());
}

class GomokuApp extends StatelessWidget {
  const GomokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gomoku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const GomokuPage(),
    );
  }
}

class BoardPoint {
  const BoardPoint(this.row, this.col);

  final int row;
  final int col;
}

class GomokuPage extends StatefulWidget {
  const GomokuPage({super.key});

  @override
  State<GomokuPage> createState() => _GomokuPageState();
}

class _GomokuPageState extends State<GomokuPage> {
  static const int boardSize = 15;
  static const int empty = 0;
  static const int blackStone = 1;
  static const int whiteStone = 2;

  // 돌이 보드 가장자리에서 잘리지 않도록 선을 안쪽에서 시작합니다.
  static const double boardPadding = 20;

  late List<List<int>> board;
  int currentTurn = blackStone;
  int winner = empty;
  int? lastMoveRow;
  int? lastMoveCol;
  List<BoardPoint> winningLine = [];

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    // 15x15 교차점 상태를 만들고 모든 위치를 빈 곳(0)으로 초기화합니다.
    board = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => empty),
    );
    currentTurn = blackStone;
    winner = empty;
    lastMoveRow = null;
    lastMoveCol = null;
    winningLine = [];
  }

  void _handleBoardTap(Offset tapPosition, Size boardAreaSize) {
    if (winner != empty) {
      return;
    }

    final double gap = _lineGap(boardAreaSize);
    final double boardStart = boardPadding;
    final double boardEnd = boardStart + gap * (boardSize - 1);

    // 바둑판 선 영역에서 너무 멀리 떨어진 탭은 무시합니다.
    if (tapPosition.dx < boardStart - gap / 2 ||
        tapPosition.dx > boardEnd + gap / 2 ||
        tapPosition.dy < boardStart - gap / 2 ||
        tapPosition.dy > boardEnd + gap / 2) {
      return;
    }

    // 탭한 화면 좌표를 가장 가까운 교차점 좌표로 바꿉니다.
    final int col = ((tapPosition.dx - boardStart) / gap).round();
    final int row = ((tapPosition.dy - boardStart) / gap).round();

    if (!_isInsideBoard(row, col)) {
      return;
    }

    _placeStone(row, col);
  }

  double _lineGap(Size boardAreaSize) {
    return (boardAreaSize.shortestSide - boardPadding * 2) / (boardSize - 1);
  }

  void _placeStone(int row, int col) {
    // 이미 돌이 있는 교차점에는 새 돌을 놓지 않습니다.
    if (board[row][col] != empty) {
      return;
    }

    setState(() {
      board[row][col] = currentTurn;
      lastMoveRow = row;
      lastMoveCol = col;

      // 방금 둔 돌을 기준으로 5개 이상 연결됐는지 확인합니다.
      final List<BoardPoint> line = _findWinningLine(row, col, currentTurn);
      if (line.isNotEmpty) {
        winner = currentTurn;
        winningLine = line;
        return;
      }

      currentTurn = currentTurn == blackStone ? whiteStone : blackStone;
    });
  }

  List<BoardPoint> _findWinningLine(int row, int col, int stone) {
    // 가로, 세로, 대각선 2개 방향만 확인하면 모든 5목을 검사할 수 있습니다.
    const List<List<int>> directions = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];

    for (final List<int> direction in directions) {
      final int rowStep = direction[0];
      final int colStep = direction[1];
      final List<BoardPoint> line = [
        ..._collectSameStones(row, col, -rowStep, -colStep, stone).reversed,
        BoardPoint(row, col),
        ..._collectSameStones(row, col, rowStep, colStep, stone),
      ];

      if (line.length >= 5) {
        return line.take(5).toList();
      }
    }

    return [];
  }

  List<BoardPoint> _collectSameStones(
    int startRow,
    int startCol,
    int rowStep,
    int colStep,
    int stone,
  ) {
    final List<BoardPoint> points = [];
    int row = startRow + rowStep;
    int col = startCol + colStep;

    // 한 방향으로 이동하면서 같은 색 돌이 연속되는 좌표를 모읍니다.
    while (_isInsideBoard(row, col) && board[row][col] == stone) {
      points.add(BoardPoint(row, col));
      row += rowStep;
      col += colStep;
    }

    return points;
  }

  bool _isInsideBoard(int row, int col) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }

  void _restartGame() {
    setState(() {
      _resetGame();
    });
  }

  String get _statusText {
    if (winner == blackStone) {
      return '흑돌 승리!';
    }

    if (winner == whiteStone) {
      return '백돌 승리!';
    }

    return currentTurn == blackStone ? '현재 차례: 흑돌' : '현재 차례: 백돌';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오목'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                _statusText,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: AspectRatio(aspectRatio: 1, child: _buildBoard()),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _restartGame,
                icon: const Icon(Icons.refresh),
                label: const Text('게임 재시작'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size boardAreaSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return GestureDetector(
          onTapUp: (details) {
            _handleBoardTap(details.localPosition, boardAreaSize);
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

  @override
  void paint(Canvas canvas, Size size) {
    final Rect boardRect = Offset.zero & size;
    final double gap = (size.shortestSide - padding * 2) / (boardSize - 1);
    final double lineStart = padding;
    final double lineEnd = lineStart + gap * (boardSize - 1);

    _drawBoardBackground(canvas, boardRect);
    _drawBoardLines(canvas, lineStart, lineEnd, gap);
    _drawStones(canvas, lineStart, gap);
    _drawWinningLine(canvas, lineStart, gap);
    _drawLastMoveMarker(canvas, lineStart, gap);
  }

  void _drawBoardBackground(Canvas canvas, Rect boardRect) {
    final Paint backgroundPaint = Paint()..color = const Color(0xFFD9A85F);
    final Paint borderPaint = Paint()
      ..color = Colors.brown.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(boardRect, backgroundPaint);
    canvas.drawRect(boardRect.deflate(1), borderPaint);
  }

  void _drawBoardLines(
    Canvas canvas,
    double lineStart,
    double lineEnd,
    double gap,
  ) {
    final Paint linePaint = Paint()
      ..color = Colors.brown.shade800
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

        final bool isBlack = stone == blackStone;
        final Paint stonePaint = Paint()
          ..color = isBlack ? Colors.black : Colors.white;
        final Paint stoneBorderPaint = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        canvas.drawCircle(center, stoneRadius, stonePaint);
        canvas.drawCircle(center, stoneRadius, stoneBorderPaint);
      }
    }
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
