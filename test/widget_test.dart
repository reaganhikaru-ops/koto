// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_learning_app/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our NihonVerse app and trigger a frame.
    await tester.pumpWidget(const NihonVerseApp());

    // Verify that the main title appears on screen.
    expect(find.text('NihonVerse Study'), findsOneWidget);
  });
}
