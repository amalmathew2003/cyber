
import 'package:flutter_test/flutter_test.dart';
import 'package:cyber_poster_gen/main.dart';

void main() {
  testWidgets('App should load', (WidgetTester tester) async {
    await tester.pumpWidget(const CyberDefenderApp());
    expect(find.text('CYBER DEFENDER'), findsOneWidget);
  });
}
