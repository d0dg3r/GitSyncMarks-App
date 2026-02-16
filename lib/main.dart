import 'package:flutter/material.dart';
import 'screens/bookmarks_screen.dart';

void main() {
  runApp(const GitSyncMarksApp());
}

class GitSyncMarksApp extends StatelessWidget {
  const GitSyncMarksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitSyncMarks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BookmarksScreen(),
    );
  }
}
