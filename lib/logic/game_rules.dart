import '../models/board_point.dart';

class GameRules {
  const GameRules({
    required this.boardSize,
    required this.empty,
  });

  final int boardSize;
  final int empty;

  static const List<List<int>> directions = [
    [0, 1],
    [1, 0],
    [1, 1],
    [1, -1],
  ];

  bool isInsideBoard(int row, int col) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }

  List<BoardPoint> findWinningLine(
    List<List<int>> board,
    int row,
    int col,
    int stone,
  ) {
    // 가로, 세로, 대각선 2개 방향만 확인하면 모든 5목을 검사할 수 있습니다.
    for (final List<int> direction in directions) {
      final int rowStep = direction[0];
      final int colStep = direction[1];
      final List<BoardPoint> line = [
        ..._collectSameStones(board, row, col, -rowStep, -colStep, stone)
            .reversed,
        BoardPoint(row, col),
        ..._collectSameStones(board, row, col, rowStep, colStep, stone),
      ];

      if (line.length >= 5) {
        return line.take(5).toList();
      }
    }

    return [];
  }

  bool isForbiddenMove(
    List<List<int>> board,
    int row,
    int col,
    int blackStone,
  ) {
    if (board[row][col] != empty) {
      return false;
    }

    board[row][col] = blackStone;

    final bool isOverline = _hasOverline(board, row, col, blackStone);
    final bool isExactFive =
        findWinningLine(board, row, col, blackStone).isNotEmpty && !isOverline;
    final bool isForbidden = !isExactFive &&
        (isOverline ||
            _countFourDirections(board, row, col, blackStone) >= 2 ||
            _countOpenThreeDirections(board, row, col, blackStone) >= 2);

    board[row][col] = empty;
    return isForbidden;
  }

  bool _hasOverline(List<List<int>> board, int row, int col, int stone) {
    for (final List<int> direction in directions) {
      final int rowStep = direction[0];
      final int colStep = direction[1];
      final int connectedCount = _lineLength(
        board,
        row,
        col,
        rowStep,
        colStep,
        stone,
      );

      if (connectedCount > 5) {
        return true;
      }
    }

    return false;
  }

  int _countFourDirections(
    List<List<int>> board,
    int row,
    int col,
    int stone,
  ) {
    int count = 0;

    for (final List<int> direction in directions) {
      if (_hasFourInDirection(
        board,
        row,
        col,
        direction[0],
        direction[1],
        stone,
      )) {
        count++;
      }
    }

    return count;
  }

  bool _hasFourInDirection(
    List<List<int>> board,
    int row,
    int col,
    int rowStep,
    int colStep,
    int stone,
  ) {
    // 이 방향의 빈 곳 하나에 더 두었을 때 정확한 5목이 되면 4로 봅니다.
    for (int offset = -4; offset <= 4; offset++) {
      final int targetRow = row + rowStep * offset;
      final int targetCol = col + colStep * offset;

      if (!isInsideBoard(targetRow, targetCol) ||
          board[targetRow][targetCol] != empty) {
        continue;
      }

      board[targetRow][targetCol] = stone;
      final bool makesFive =
          _lineLength(board, targetRow, targetCol, rowStep, colStep, stone) ==
              5;
      board[targetRow][targetCol] = empty;

      if (makesFive) {
        return true;
      }
    }

    return false;
  }

  int _countOpenThreeDirections(
    List<List<int>> board,
    int row,
    int col,
    int stone,
  ) {
    int count = 0;

    for (final List<int> direction in directions) {
      if (_hasOpenThreeInDirection(
        board,
        row,
        col,
        direction[0],
        direction[1],
        stone,
      )) {
        count++;
      }
    }

    return count;
  }

  bool _hasOpenThreeInDirection(
    List<List<int>> board,
    int row,
    int col,
    int rowStep,
    int colStep,
    int stone,
  ) {
    // 열린 3은 이 방향의 빈 곳 하나에 더 두면 양쪽으로 열린 4가 되는 형태입니다.
    for (int offset = -4; offset <= 4; offset++) {
      final int targetRow = row + rowStep * offset;
      final int targetCol = col + colStep * offset;

      if (!isInsideBoard(targetRow, targetCol) ||
          board[targetRow][targetCol] != empty) {
        continue;
      }

      board[targetRow][targetCol] = stone;
      final bool makesOpenFour = _hasOpenFourInDirection(
        board,
        targetRow,
        targetCol,
        rowStep,
        colStep,
        stone,
      );
      board[targetRow][targetCol] = empty;

      if (makesOpenFour) {
        return true;
      }
    }

    return false;
  }

  bool _hasOpenFourInDirection(
    List<List<int>> board,
    int row,
    int col,
    int rowStep,
    int colStep,
    int stone,
  ) {
    int winningSpotCount = 0;

    for (int offset = -4; offset <= 4; offset++) {
      final int targetRow = row + rowStep * offset;
      final int targetCol = col + colStep * offset;

      if (!isInsideBoard(targetRow, targetCol) ||
          board[targetRow][targetCol] != empty) {
        continue;
      }

      board[targetRow][targetCol] = stone;
      final bool makesFive =
          _lineLength(board, targetRow, targetCol, rowStep, colStep, stone) ==
              5;
      board[targetRow][targetCol] = empty;

      if (makesFive) {
        winningSpotCount++;
      }
    }

    return winningSpotCount >= 2;
  }

  int _lineLength(
    List<List<int>> board,
    int row,
    int col,
    int rowStep,
    int colStep,
    int stone,
  ) {
    return 1 +
        _collectSameStones(board, row, col, rowStep, colStep, stone).length +
        _collectSameStones(board, row, col, -rowStep, -colStep, stone).length;
  }

  List<BoardPoint> _collectSameStones(
    List<List<int>> board,
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
    while (isInsideBoard(row, col) && board[row][col] == stone) {
      points.add(BoardPoint(row, col));
      row += rowStep;
      col += colStep;
    }

    return points;
  }
}
