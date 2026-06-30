import 'package:flutter_test/flutter_test.dart';
import 'package:plump_icons_example/main.dart';

void main() {
  testWidgets('shows searchable icon browser', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Plump Icons'), findsOneWidget);
    expect(find.textContaining('icons'), findsWidgets);
  });
}
