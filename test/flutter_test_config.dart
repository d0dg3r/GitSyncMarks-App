import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// Loads Roboto and Material icons so golden screenshots render real text
/// instead of Ahem blocks. Required for README/Flatpak/F-Droid screenshots.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  return testMain();
}
