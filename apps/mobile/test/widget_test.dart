import 'package:flutter_test/flutter_test.dart';

import 'package:cafeteria_utez/main.dart';

void main() {
  testWidgets('Renders minimal CafeteriaApp smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafeteriaApp());

    expect(find.text('Cafetería UTEZ'), findsOneWidget);
  });
}
