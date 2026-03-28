import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('bookmark_cache');
  await Hive.openBox<dynamic>('sync_state');
  runApp(const GitSyncMarksApp());
}
