import 'package:flutter_test/flutter_test.dart';
import 'package:gomoku/logic/game_rules.dart';

void main() {
  const int boardSize = 15;
  const int empty = 0;
  const int blackStone = 1;
  const GameRules rules = GameRules(boardSize: boardSize, empty: empty);

  List<List<int>> emptyBoard() {
    return List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => empty),
    );
  }

  test('exact five is not forbidden for black', () {
    final List<List<int>> board = emptyBoard();

    for (int col = 3; col <= 6; col++) {
      board[7][col] = blackStone;
    }

    expect(rules.isForbiddenMove(board, 7, 7, blackStone), isFalse);
    expect(rules.forbiddenMoveReason(board, 7, 7, blackStone), isNull);
  });

  test('overline is forbidden for black', () {
    final List<List<int>> board = emptyBoard();

    for (int col = 2; col <= 6; col++) {
      board[7][col] = blackStone;
    }

    expect(rules.isForbiddenMove(board, 7, 7, blackStone), isTrue);
    expect(rules.forbiddenMoveReason(board, 7, 7, blackStone), '장목 금수');
  });

  test('double-four is forbidden for black', () {
    final List<List<int>> board = emptyBoard();

    for (int col = 4; col <= 6; col++) {
      board[7][col] = blackStone;
    }
    for (int row = 4; row <= 6; row++) {
      board[row][7] = blackStone;
    }

    expect(rules.isForbiddenMove(board, 7, 7, blackStone), isTrue);
    expect(rules.forbiddenMoveReason(board, 7, 7, blackStone), '쌍사 금수');
  });

  test('double-three is forbidden for black', () {
    final List<List<int>> board = emptyBoard();

    board[7][6] = blackStone;
    board[7][8] = blackStone;
    board[6][7] = blackStone;
    board[8][7] = blackStone;

    expect(rules.isForbiddenMove(board, 7, 7, blackStone), isTrue);
    expect(rules.forbiddenMoveReason(board, 7, 7, blackStone), '쌍삼 금수');
  });
}
