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

    final bool isForbidden = _hasOverline(board, row, col, blackStone) ||
        _countFourDirections(board, row, col, blackStone) >= 2 ||
        _countOpenThreeDirections(board, row, col, blackStone) >= 2;

    board[row][col] = empty;
    return isForbidden;
  }

  bool _hasOverline(List<List<int>> board, int row, int col, int stone) {
    for (final List<int> direction in directions) {
      final int rowStep = direction[0];
      final int colStep = direction[1];
      final int connectedCount = 1 +
          _collectSameStones(board, row, col, rowStep, colStep, stone).length +
          _collectSameStones(board, row, col, -rowStep, -colStep, stone).length;

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
      if (_lineText(board, row, col, direction[0], direction[1], stone)
          .contains('BBBB')) {
        count++;
      }
    }

    return count;
  }

  int _countOpenThreeDirections(
    List<List<int>> board,
    int row,
    int col,
    int stone,
  ) {
    int count = 0;

    for (final List<int> direction in directions) {
      final String line = _lineText(
        board,
        row,
        col,
        direction[0],
        direction[1],
        stone,
      );

      // 열린 3은 양쪽에 빈 곳이 있어 다음 수에 열린 4로 커질 수 있는 형태입니다.
      if (line.contains('EBBBE') ||
          line.contains('EBBEBE') ||
          line.contains('EBEBBE')) {
        count++;
      }
    }

    return count;
  }

  String _lineText(
    List<List<int>> board,
    int row,
    int col,
    int rowStep,
    int colStep,
    int stone,
  ) {
    final StringBuffer buffer = StringBuffer();

    for (int offset = -4; offset <= 4; offset++) {
      final int currentRow = row + rowStep * offset;
      final int currentCol = col + colStep * offset;

      if (!isInsideBoard(currentRow, currentCol)) {
        buffer.write('X');
      } else if (board[currentRow][currentCol] == empty) {
        buffer.write('E');
      } else if (board[currentRow][currentCol] == stone) {
        buffer.write('B');
      } else {
        buffer.write('W');
      }
    }

    return buffer.toString();
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
