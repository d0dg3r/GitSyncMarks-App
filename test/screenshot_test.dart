/// Screenshot golden tests for README, Flatpak metainfo and store metadata.
///
/// Run with `flutter test test/screenshot_test.dart --update-goldens`
/// to generate / refresh screenshot PNGs.
///
/// Output lands in test/goldens/. The CI workflow copies these into
/// flatpak/screenshots/ so the AppStream metainfo can reference them.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gitsyncmarks/app.dart';
import 'package:gitsyncmarks/models/bookmark_node.dart';
import 'package:gitsyncmarks/providers/bookmark_provider.dart';
import 'package:gitsyncmarks/screens/bookmark_list_screen.dart';
import 'package:gitsyncmarks/screens/settings_screen.dart';

import 'package:gitsyncmarks/l10n/app_localizations.dart';

final _sampleFolders = [
  const BookmarkFolder(
    title: 'toolbar',
    children: [
      Bookmark(title: 'GitHub', url: 'https://github.com'),
      Bookmark(title: 'Flutter Docs', url: 'https://docs.flutter.dev'),
      Bookmark(title: 'Stack Overflow', url: 'https://stackoverflow.com'),
      BookmarkFolder(
        title: 'Dev Tools',
        children: [
          Bookmark(title: 'Pub.dev', url: 'https://pub.dev'),
          Bookmark(title: 'DartPad', url: 'https://dartpad.dev'),
        ],
      ),
      BookmarkFolder(
        title: 'News',
        children: [
          Bookmark(title: 'Hacker News', url: 'https://news.ycombinator.com'),
          Bookmark(title: 'TechCrunch', url: 'https://techcrunch.com'),
        ],
      ),
    ],
  ),
  const BookmarkFolder(
    title: 'other bookmarks',
    children: [
      Bookmark(title: 'Wikipedia', url: 'https://wikipedia.org'),
      Bookmark(title: 'Reddit', url: 'https://reddit.com'),
    ],
  ),
];

const _localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _width = 480.0;
const _height = 960.0;
const _pixelRatio = 2.0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getTemporaryDirectory' ||
          call.method == 'getApplicationSupportDirectory' ||
          call.method == 'getApplicationDocumentsDirectory') {
        return '/tmp/test_screenshots';
      }
      return null;
    });
  });

  group('Screenshots', () {
    _goldenTest('bookmark-list', (provider) {
      provider.seedWith(_sampleFolders);
      return const BookmarkListScreen();
    });

    _goldenTest('bookmark-list-dark', (provider) {
      provider.seedWith(_sampleFolders);
      return const BookmarkListScreen();
    }, dark: true);

    _goldenTest('settings-github', (provider) {
      provider.seedWith(_sampleFolders);
      return const SettingsScreen();
    });
  });
}

void _goldenTest(
  String name,
  Widget Function(BookmarkProvider provider) buildContent, {
  bool dark = false,
}) {
  testWidgets(name, (tester) async {
    tester.view.physicalSize = const Size(_width * _pixelRatio, _height * _pixelRatio);
    tester.view.devicePixelRatio = _pixelRatio;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final provider = BookmarkProvider();
    final content = buildContent(provider);
    final theme =
        dark ? GitSyncMarksApp.testDarkTheme : GitSyncMarksApp.testLightTheme;

    await tester.pumpWidget(
      MaterialApp(
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

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  });
}
