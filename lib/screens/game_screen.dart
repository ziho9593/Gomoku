import 'dart:async';

import 'package:flutter/material.dart';

import '../logic/game_rules.dart';
import '../models/board_point.dart';
import '../models/move_record.dart';
import '../widgets/game_status_bar.dart';
import '../widgets/gomoku_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int boardSize = 15;
  static const int empty = 0;
  static const int blackStone = 1;
  static const int whiteStone = 2;
  static const int turnTimeLimitSeconds = 60;

  late List<List<int>> board;
  int currentTurn = blackStone;
  int winner = empty;
  int? lastMoveRow;
  int? lastMoveCol;
  int remainingSeconds = turnTimeLimitSeconds;
  Timer? turnTimer;
  List<BoardPoint> winningLine = [];
  List<MoveRecord> moveHistory = [];
  String? forbiddenMessage;

  final GameRules gameRules = const GameRules(
    boardSize: boardSize,
    empty: empty,
  );

  @override
  void initState() {
    super.initState();
    _resetGame();
    _startTurnTimer();
  }

  @override
  void dispose() {
    _stopTurnTimer();
    super.dispose();
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
    remainingSeconds = turnTimeLimitSeconds;
    winningLine = [];
    moveHistory = [];
    forbiddenMessage = null;
  }

  void _handleBoardTap(Offset tapPosition, Size boardAreaSize) {
    if (winner != empty) {
      return;
    }

    final double gap = _lineGap(boardAreaSize);
    final double boardStart = GomokuBoard.boardPadding;
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

    if (!gameRules.isInsideBoard(row, col)) {
      return;
    }

    _placeStone(row, col);
  }

  double _lineGap(Size boardAreaSize) {
    return (boardAreaSize.shortestSide - GomokuBoard.boardPadding * 2) /
        (boardSize - 1);
  }

  void _placeStone(int row, int col) {
    // 이미 돌이 있는 교차점에는 새 돌을 놓지 않습니다.
    if (board[row][col] != empty) {
      return;
    }

    final String? forbiddenReason = currentTurn == blackStone
        ? gameRules.forbiddenMoveReason(board, row, col, blackStone)
        : null;
    if (forbiddenReason != null) {
      setState(() {
        forbiddenMessage = forbiddenReason;
      });
      return;
    }

    bool gameWon = false;

    setState(() {
      board[row][col] = currentTurn;
      lastMoveRow = row;
      lastMoveCol = col;
      remainingSeconds = turnTimeLimitSeconds;
      forbiddenMessage = null;
      moveHistory.add(MoveRecord(row: row, col: col, stone: currentTurn));

      // 방금 둔 돌을 기준으로 5개 이상 연결됐는지 확인합니다.
      final List<BoardPoint> line = gameRules.findWinningLine(
        board,
        row,
        col,
        currentTurn,
      );
      if (line.isNotEmpty) {
        winner = currentTurn;
        winningLine = line;
        gameWon = true;
        return;
      }

      currentTurn = currentTurn == blackStone ? whiteStone : blackStone;
    });

    if (gameWon) {
      _stopTurnTimer();
    } else {
      _startTurnTimer();
    }
  }

  void _restartGame() {
    setState(() {
      _resetGame();
    });
    _startTurnTimer();
  }

  void _undoMove() {
    if (moveHistory.isEmpty) {
      return;
    }

    setState(() {
      final MoveRecord lastMove = moveHistory.removeLast();
      board[lastMove.row][lastMove.col] = empty;
      currentTurn = lastMove.stone;
      winner = empty;
      winningLine = [];
      forbiddenMessage = null;
      remainingSeconds = turnTimeLimitSeconds;

      if (moveHistory.isEmpty) {
        lastMoveRow = null;
        lastMoveCol = null;
      } else {
        final MoveRecord previousMove = moveHistory.last;
        lastMoveRow = previousMove.row;
        lastMoveCol = previousMove.col;
      }
    });

    _startTurnTimer();
  }

  void _resignGame() {
    if (winner != empty) {
      return;
    }

    setState(() {
      winner = currentTurn == blackStone ? whiteStone : blackStone;
      forbiddenMessage = null;
    });
    _stopTurnTimer();
  }

  void _startTurnTimer() {
    _stopTurnTimer();
    turnTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      if (winner != empty) {
        _stopTurnTimer();
        return;
      }

      setState(() {
        if (remainingSeconds > 1) {
          remainingSeconds--;
        } else {
          currentTurn = currentTurn == blackStone ? whiteStone : blackStone;
          remainingSeconds = turnTimeLimitSeconds;
        }
      });
    });
  }

  void _stopTurnTimer() {
    turnTimer?.cancel();
    turnTimer = null;
  }

  String get _statusText {
    if (forbiddenMessage != null) {
      return forbiddenMessage!;
    }

    if (winner == blackStone) {
      return '흑돌 승리!';
    }

    if (winner == whiteStone) {
      return '백돌 승리!';
    }

    return currentTurn == blackStone ? '흑돌 차례' : '백돌 차례';
  }

  Color get _statusAccentColor {
    if (winner != empty) {
      return const Color(0xFFB8860B);
    }

    return currentTurn == blackStone ? Colors.black : Colors.white;
  }

  Color get _statusAccentBorderColor {
    return currentTurn == whiteStone && winner == empty
        ? Colors.black54
        : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오목'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF4F1EA),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              GameStatusBar(
                statusText: _statusText,
                accentColor: _statusAccentColor,
                accentBorderColor: _statusAccentBorderColor,
                remainingSeconds: remainingSeconds,
                isGameOver: winner != empty,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GomokuBoard(
                      board: board,
                      boardSize: boardSize,
                      empty: empty,
                      blackStone: blackStone,
                      lastMoveRow: lastMoveRow,
                      lastMoveCol: lastMoveCol,
                      winningLine: winningLine,
                      onTapBoard: _handleBoardTap,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: moveHistory.isEmpty ? null : _undoMove,
                    icon: const Icon(Icons.undo),
                    label: const Text('무르기'),
                  ),
                  OutlinedButton.icon(
                    onPressed: winner == empty ? _resignGame : null,
                    icon: const Icon(Icons.flag),
                    label: const Text('기권'),
                  ),
                  FilledButton.icon(
                    onPressed: _restartGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('게임 재시작'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
