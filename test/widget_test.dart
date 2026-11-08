import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('AR app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ARConversationalApp());
    // Verify the app launches
    expect(find.byType(MaterialApp), findsOneWidget);
    // Advance timers so pending timers finish
    await tester.pump(const Duration(seconds: 5));
  });
}
