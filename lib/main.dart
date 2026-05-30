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
  }

  void _handleBoardTap(Offset tapPosition, Size boardAreaSize) {
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

    if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) {
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

      // 승리 판정은 아직 없으므로 착수 후 바로 다음 차례로 넘깁니다.
      currentTurn = currentTurn == blackStone ? whiteStone : blackStone;
    });
  }

  void _restartGame() {
    setState(() {
      _resetGame();
    });
  }

  String get _turnText {
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
              Text(_turnText, style: Theme.of(context).textTheme.titleLarge),
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
  });

  final List<List<int>> board;
  final int boardSize;
  final int empty;
  final int blackStone;
  final double padding;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect boardRect = Offset.zero & size;
    final double gap = (size.shortestSide - padding * 2) / (boardSize - 1);
    final double lineStart = padding;
    final double lineEnd = lineStart + gap * (boardSize - 1);

    _drawBoardBackground(canvas, boardRect);
    _drawBoardLines(canvas, lineStart, lineEnd, gap);
    _drawStones(canvas, lineStart, gap);
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

  @override
  bool shouldRepaint(covariant GomokuBoardPainter oldDelegate) {
    return true;
  }
}
