import 'package:flutter_test/flutter_test.dart';
import 'package:unimarket_flutter/main.dart';

void main() {
  testWidgets('UniMarketApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UniMarketApp());
    expect(find.text('UniMarket'), findsWidgets);
  });
}
