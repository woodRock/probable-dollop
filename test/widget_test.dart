// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock/main.dart';

void main() {
  testWidgets('App title is correct test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    // Verify the title of the app is correct.
    expect(find.text('Groceries'), findsOneWidget);
  });

  testWidgets("Add grocery to favorites test", (WidgetTester tester) async {
    //Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    // Tap the favorite button for the first tile.
    await tester.tap(find.byType(ListView).first);
    // Rebuild the widget after the state has changed.
    await tester.pump();
    // One startup should have a heart filled in.
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets("Remove grocery from favorites test",
      (WidgetTester tester) async {
    //Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    // Tap startup to add to favorites.
    await tester.tap(find.byType(ListView).first);
    // Rebuild the widget after the state has changed.
    await tester.pump();
    // Tap again to remove from favorites
    await tester.tap(find.byType(ListView).first);
    // Rebuild the widget after the state has changed.
    await tester.pump();
    // There should only be one heart, the link the favorites, showing.
    // No groceries should have a favorite icon.
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
