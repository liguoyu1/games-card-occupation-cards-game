import 'package:flutter_test/flutter_test.dart';
import 'package:occupation_cards/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const OccupationCardsApp());
    expect(find.byType(GameScreen), findsOneWidget);
  });
}
