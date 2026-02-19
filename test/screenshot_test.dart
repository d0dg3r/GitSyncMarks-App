/// Screenshot tests for README and store metadata.
///
/// Run with `flutter test --update-goldens` to generate screenshots
/// or `flutter test` to compare against golden files.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:provider/provider.dart';

import 'package:gitsyncmarks/app.dart';
import 'package:gitsyncmarks/models/bookmark_node.dart';
import 'package:gitsyncmarks/providers/bookmark_provider.dart';
import 'package:gitsyncmarks/screens/bookmark_list_screen.dart';
import 'package:gitsyncmarks/screens/settings_screen.dart';

import 'package:gitsyncmarks/l10n/app_localizations.dart';

final _sampleFolders = [
  BookmarkFolder(
    title: 'toolbar',
    children: [
      const Bookmark(title: 'GitHub', url: 'https://github.com'),
      const Bookmark(title: 'Flutter Docs', url: 'https://docs.flutter.dev'),
      BookmarkFolder(
        title: 'Dev',
        children: const [
          Bookmark(title: 'Pub.dev', url: 'https://pub.dev'),
        ],
      ),
    ],
  ),
];

const _localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

void main() {
  group('Screenshot:', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    _screenshot('1_bookmarks', (provider) {
      provider.seedWith(_sampleFolders);
      return const BookmarkListScreen();
    });

    _screenshot('2_empty_state', (provider) {
      provider.seedWith([]);
      return const BookmarkListScreen();
    });

    _screenshot('3_settings', (provider) {
      provider.seedWith(_sampleFolders);
      return const SettingsScreen();
    });
  });

  group('Combined:', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    _combinedScreenshot('1_bookmarks', (provider) {
      provider.seedWith(_sampleFolders);
      return const BookmarkListScreen();
    });

    _combinedScreenshot('2_empty_state', (provider) {
      provider.seedWith([]);
      return const BookmarkListScreen();
    });

    _combinedScreenshot('3_settings', (provider) {
      provider.seedWith(_sampleFolders);
      return const SettingsScreen();
    });
  });
}

/// Generates per-device screenshots in both light and dark themes.
void _screenshot(
  String description,
  Widget Function(BookmarkProvider provider) buildContent,
) {
  final themes = {
    '': GitSyncMarksApp.testLightTheme,
    '_dark': GitSyncMarksApp.testDarkTheme,
  };

  for (final entry in themes.entries) {
    final suffix = entry.key;
    final theme = entry.value;

    group('$description$suffix', () {
      for (final goldenDevice in GoldenScreenshotDevices.values) {
        testGoldens('for ${goldenDevice.name}', (tester) async {
          final device = goldenDevice.device;

          final provider = BookmarkProvider();
          final content = buildContent(provider);

          await tester.pumpWidget(
            ScreenshotApp(
              device: device,
              title: 'GitSyncMarks',
              theme: theme,
              localizationsDelegates: _localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              home: ChangeNotifierProvider<BookmarkProvider>.value(
                value: provider,
                child: content,
              ),
            ),
          );

          await tester.loadAssets();
          await tester.pumpFrames(
            tester.widget(find.byType(ScreenshotApp)),
            const Duration(seconds: 1),
          );

          await tester.expectScreenshot(device, '$description$suffix');
        });
      }
    });
  }
}

/// Generates a single golden with light (left) and dark (right) side by side.
void _combinedScreenshot(
  String description,
  Widget Function(BookmarkProvider provider) buildContent,
) {
  const phoneWidth = 427.0;
  const phoneHeight = 952.0;
  const totalWidth = phoneWidth * 2;

  testGoldens('$description combined', (tester) async {
    tester.view.physicalSize = const Size(totalWidth, phoneHeight);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final lightProvider = BookmarkProvider();
    final lightContent = buildContent(lightProvider);
    final darkProvider = BookmarkProvider();
    final darkContent = buildContent(darkProvider);

    const combinedKey = ValueKey('combined');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          key: combinedKey,
          textDirection: TextDirection.ltr,
          children: [
            _themedApp(GitSyncMarksApp.testLightTheme, lightProvider,
                lightContent, phoneWidth, phoneHeight),
            _themedApp(GitSyncMarksApp.testDarkTheme, darkProvider,
                darkContent, phoneWidth, phoneHeight),
          ],
        ),
      ),
    );

    await tester.loadAssets();
    await tester.pump(const Duration(seconds: 1));

    await expectLater(
      find.byKey(combinedKey),
      matchesGoldenFile(
          '../metadata/en-US/images/combinedScreenshots/${description}_combined.png'),
    );
  });
}

Widget _themedApp(ThemeData theme, BookmarkProvider provider, Widget content,
    double width, double height) {
  return SizedBox(
    width: width,
    height: height,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: _localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: ChangeNotifierProvider<BookmarkProvider>.value(
        value: provider,
        child: content,
      ),
    ),
  );
}
