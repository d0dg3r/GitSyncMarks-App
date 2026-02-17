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
}

void _screenshot(
  String description,
  Widget Function(BookmarkProvider provider) buildContent,
) {
  group(description, () {
    for (final goldenDevice in GoldenScreenshotDevices.values) {
      testGoldens('for ${goldenDevice.name}', (tester) async {
        final device = goldenDevice.device;

        final provider = BookmarkProvider();
        final content = buildContent(provider);

        await tester.pumpWidget(
          ScreenshotApp(
            device: device,
            title: 'GitSyncMarks',
            theme: GitSyncMarksApp.testLightTheme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
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

        await tester.expectScreenshot(device, description);
      });
    }
  });
}
