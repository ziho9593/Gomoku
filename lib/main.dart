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

  late List<List<int>> board;
  int currentTurn = blackStone;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    // 15x15 보드를 만들고 모든 칸을 빈 칸(0)으로 초기화합니다.
    board = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => empty),
    );
    currentTurn = blackStone;
  }

  void _placeStone(int row, int col) {
    // 이미 돌이 있는 칸에는 새 돌을 놓지 않습니다.
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
      appBar: AppBar(
        title: const Text('오목'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                _turnText,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildBoard(),
                  ),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9A85F),
        border: Border.all(color: Colors.brown.shade900, width: 2),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: boardSize * boardSize,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: boardSize,
        ),
        itemBuilder: (context, index) {
          final int row = index ~/ boardSize;
          final int col = index % boardSize;

          return _buildCell(row, col);
        },
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final int stone = board[row][col];

    return GestureDetector(
      onTap: () => _placeStone(row, col),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown.shade700, width: 0.5),
        ),
        child: Center(
          child: _buildStone(stone),
        ),
      ),
    );
  }

  Widget _buildStone(int stone) {
    // 빈 칸이면 아무것도 그리지 않습니다.
    if (stone == empty) {
      return const SizedBox.shrink();
    }

    final bool isBlack = stone == blackStone;

    return FractionallySizedBox(
      widthFactor: 0.72,
      heightFactor: 0.72,
      child: Container(
        decoration: BoxDecoration(
          color: isBlack ? Colors.black : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black87),
        ),
      ),
    );
  }
}
