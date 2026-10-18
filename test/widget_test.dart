
import 'package:flutter_test/flutter_test.dart';
import 'package:replate/main.dart';

void main() {
  testWidgets('RePlate app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const RePlateApp());

    expect(find.byType(RePlateApp), findsOneWidget);
  });
}
