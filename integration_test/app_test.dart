import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:leafmark/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Acceptance Test: LeafMark Counter Scenario', () {
    testWidgets('Verify that clicking the plus button increments the counter',
            (tester) async {
          // 1. Start the app
          app.main();
          await tester.pumpAndSettle();

          // 2. Verify if the Home Page title is visible
          // Now using the exact string from your main.dart
          expect(find.text('LeafMark Home Page'), findsOneWidget);

          // 3. Verify counter starts at 0
          expect(find.text('0'), findsOneWidget);

          // 4. Find the Plus button and tap it
          final Finder fab = find.byType(FloatingActionButton);
          await tester.tap(fab);

          // 5. Wait for the counter to update
          await tester.pumpAndSettle();

          // 6. Verify the counter is now 1
          expect(find.text('1'), findsOneWidget);

          print("Test Passed: Counter incremented successfully!");
        });
  });
}