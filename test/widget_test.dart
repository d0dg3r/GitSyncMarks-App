import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsyncmarks/app.dart';

void main() {
  testWidgets('App starts and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const GitSyncMarksApp());

    expect(find.text('GitSyncMarks'), findsWidgets);
  });

  testWidgets('App shows settings in bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const GitSyncMarksApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.settings), findsWidgets);
  });
}
