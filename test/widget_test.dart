import 'package:flutter_test/flutter_test.dart';

import 'package:gomoku/main.dart';

void main() {
  testWidgets('Gomoku app shows the first turn and restart button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GomokuApp());

    expect(find.text('현재 차례: 흑돌'), findsOneWidget);
    expect(find.text('게임 재시작'), findsOneWidget);
  });
}
