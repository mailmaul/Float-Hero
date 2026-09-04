import 'package:flutter_test/flutter_test.dart';

import 'package:float_hero/main.dart';

void main() {
  testWidgets('Float Hero smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FloatHeroApp());

    // Verify that loading screen appears
    expect(find.text('Loading Float Hero...'), findsOneWidget);
  });
}
