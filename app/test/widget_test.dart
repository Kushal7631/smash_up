import 'package:flutter_test/flutter_test.dart';
import 'package:smash_up/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const SmashUpApp());
    expect(find.text('SmashUp'), findsOneWidget);
  });
}
