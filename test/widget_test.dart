import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsyncmarks/main.dart';

void main() {
  testWidgets('App starts and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const GitSyncMarksApp());

    expect(find.text('GitSyncMarks'), findsOneOrMoreWidgets);
  });

  testWidgets('App shows loading indicator on start', (WidgetTester tester) async {
    await tester.pumpWidget(const GitSyncMarksApp());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
