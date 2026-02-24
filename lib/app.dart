import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'l10n/app_localizations.dart';
import 'providers/bookmark_provider.dart';
import 'screens/home_screen.dart';
import 'services/settings_import_export.dart';
import 'widgets/add_bookmark_dialog.dart';

bool _isMobileShareTarget() {
  if (kIsWeb) {
    return false;
  }
  try {
    return Platform.isAndroid || Platform.isIOS;
  } catch (e) {
    rethrow;
  }
}

/// GitSyncMarks brand colors (from extension options.css / popup.css).
class _AppColors {
  static const primaryLight = Color(0xFF0071e3);
  static const primaryDark = Color(0xFF0a84ff);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF2c2c2e);
  static const backgroundLight = Color(0xFFf5f5f7);
  static const backgroundDark = Color(0xFF1c1c1e);
  static const onSurfaceLight = Color(0xFF1d1d1f);
  static const onSurfaceDark = Color(0xFFf5f5f7);
  static const outlineLight = Color(0xFF6e6e73);
  static const outlineDark = Color(0xFFa1a1a6);
}

class GitSyncMarksApp extends StatelessWidget {
  const GitSyncMarksApp({super.key, this.provider});

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
        home: _isMobileShareTarget()
            ? _ShareIntentWrapper(bookmarkProvider: bookmarkProvider)
            : const HomeScreen(),
      ),
    );
  }

  static ThemeData get testLightTheme => _buildLightTheme();
  static ThemeData get testDarkTheme => _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    const scheme = ColorScheme.light(
      primary: _AppColors.primaryLight,
      onPrimary: Colors.white,
      surface: _AppColors.surfaceLight,
      onSurface: _AppColors.onSurfaceLight,
      surfaceContainerHighest: Color(0xFFe8e8ed),
      primaryContainer: Color(0xFFdce8f8),
      onPrimaryContainer: Color(0xFF003a75),
      error: Color(0xFFff3b30),
      onError: Colors.white,
      errorContainer: Color(0xFFffdad6),
      outline: _AppColors.outlineLight,
      outlineVariant: Color(0xFFd1d1d6),
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: _AppColors.backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.outline,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: scheme.primary, width: 3),
          borderRadius: BorderRadius.circular(3),
        ),
        dividerColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    const scheme = ColorScheme.dark(
      primary: _AppColors.primaryDark,
      onPrimary: Colors.white,
      surface: _AppColors.surfaceDark,
      onSurface: _AppColors.onSurfaceDark,
      surfaceContainerHighest: Color(0xFF3a3a3c),
      primaryContainer: Color(0xFF003a75),
      onPrimaryContainer: Color(0xFFdce8f8),
      error: Color(0xFFff453a),
      onError: Colors.white,
      errorContainer: Color(0xFF93000a),
      outline: _AppColors.outlineDark,
      outlineVariant: Color(0xFF48484a),
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: _AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.outline,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: scheme.primary, width: 3),
          borderRadius: BorderRadius.circular(3),
        ),
        dividerColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }
}

/// Wraps [HomeScreen] and listens for incoming share intents.
class _ShareIntentWrapper extends StatefulWidget {
  const _ShareIntentWrapper({required this.bookmarkProvider});

  final BookmarkProvider bookmarkProvider;

  @override
  State<_ShareIntentWrapper> createState() => _ShareIntentWrapperState();
}

class _ShareIntentWrapperState extends State<_ShareIntentWrapper> {
  StreamSubscription<List<SharedMediaFile>>? _sub;
  final _importExport = SettingsImportExportService();

  @override
  void initState() {
    super.initState();

    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      _handleSharedFiles(files);
      ReceiveSharingIntent.instance.reset();
    });

    _sub = ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      _handleSharedFiles(files);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  static final _urlRegex = RegExp(
    r'https?://[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  String? _extractUrl(String text, SharedMediaType type) {
    final t = text.trim();
    if (t.isEmpty) return null;
    if (type == SharedMediaType.url) return t;
    final match = _urlRegex.firstMatch(t);
    return match?.group(0);
  }

  String _urlToTitle(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.isNotEmpty) return uri.host;
    } catch (_) {}
    return '';
  }

  Future<void> _handleSharedFiles(List<SharedMediaFile> files) async {
    if (files.isEmpty) return;

    for (final file in files) {
      if (file.type == SharedMediaType.text || file.type == SharedMediaType.url) {
        final url = _extractUrl(file.path, file.type);
        if (url == null || url.isEmpty) continue;

        if (!mounted) return;
        final title = _urlToTitle(url);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AddBookmarkDialog(
            url: url,
            initialTitle: title,
            provider: widget.bookmarkProvider,
          ),
        );
        if (confirmed == true) {
          ReceiveSharingIntent.instance.reset();
          return;
        }
        continue;
      }

      final path = file.path;
      if (!path.endsWith('.json')) continue;

      try {
        final content = await File(path).readAsString();
        final parsed = _importExport.parseSettingsJson(content);

        if (!mounted) return;

        final l = AppLocalizations.of(context);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l?.importSettings ?? 'Import Settings'),
            content: Text(
              l?.importConfirm(parsed.profiles.length) ??
                  'Import ${parsed.profiles.length} profile(s)?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l?.cancel ?? 'Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l?.replace ?? 'Replace'),
              ),
            ],
          ),
        );
        if (confirmed != true) continue;

        await widget.bookmarkProvider.replaceProfiles(
          parsed.profiles,
          activeId: parsed.activeProfileId,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l?.importSuccess(parsed.profiles.length) ??
                  'Imported ${parsed.profiles.length} profile(s)',
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.importFailed(e.toString()) ??
                  'Import failed: $e',
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
