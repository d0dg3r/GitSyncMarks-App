import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/bookmark_provider.dart';
import 'screens/bookmark_list_screen.dart';
import 'screens/settings_screen.dart';

/// GitSyncMarks brand colors (from extension options.css / popup.css).
class _AppColors {
  static const primaryLight = Color(0xFF0071e3);
  static const primaryDark = Color(0xFF0a84ff);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF2c2c2e);
  static const backgroundLight = Color(0xFFf5f5f7);
  static const backgroundDark = Color(0xFF1d1d1f);
  static const onSurfaceLight = Color(0xFF1d1d1f);
  static const onSurfaceDark = Color(0xFFf5f5f7);
  static const outlineLight = Color(0xFF6e6e73);
  static const outlineDark = Color(0xFFa1a1a6);
}

class GitSyncMarksApp extends StatelessWidget {
  const GitSyncMarksApp({super.key, this.provider});

  /// Optional provider for screenshot tests; if null, creates a fresh provider.
  final BookmarkProvider? provider;

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = provider ?? BookmarkProvider()..loadCredentials();
    return ChangeNotifierProvider<BookmarkProvider>.value(
      value: bookmarkProvider,
      child: MaterialApp(
        title: 'GitSyncMarks',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: '/',
        routes: {
          '/': (context) => const BookmarkListScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }

  /// Themes for screenshot tests and tooling.
  static ThemeData get testLightTheme => _buildLightTheme();
  static ThemeData get testDarkTheme => _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    final scheme = ColorScheme.light(
      primary: _AppColors.primaryLight,
      onPrimary: Colors.white,
      surface: _AppColors.surfaceLight,
      onSurface: _AppColors.onSurfaceLight,
      surfaceContainerHighest: const Color(0xFFe8e8ed),
      error: const Color(0xFFff3b30),
      onError: Colors.white,
      outline: _AppColors.outlineLight,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: _AppColors.backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    final scheme = ColorScheme.dark(
      primary: _AppColors.primaryDark,
      onPrimary: Colors.white,
      surface: _AppColors.surfaceDark,
      onSurface: _AppColors.onSurfaceDark,
      surfaceContainerHighest: const Color(0xFF3a3a3c),
      error: const Color(0xFFff453a),
      onError: Colors.white,
      outline: _AppColors.outlineDark,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: _AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
