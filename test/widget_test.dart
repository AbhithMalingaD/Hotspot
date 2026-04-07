import 'package:flutter_test/flutter_test.dart';

import 'package:hotspot/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
  });
}