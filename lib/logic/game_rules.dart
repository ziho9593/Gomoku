import '../models/board_point.dart';

class GameRules {
  const GameRules({
    required this.boardSize,
    required this.empty,
  });

  final int boardSize;
  final int empty;

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
