import 'package:flutter_test/flutter_test.dart';
import 'package:gitsyncmarks/services/bookmark_service.dart';

void main() {
  group('BookmarkService Tests', () {
    late BookmarkService service;

    setUp(() {
      service = BookmarkService();
    });

    test('BookmarkService instantiation', () {
      expect(service, isNotNull);
    });

    test('Verify bookmarks URL is set', () {
      expect(BookmarkService.bookmarksUrl, isNotEmpty);
      expect(BookmarkService.bookmarksUrl, contains('github'));
    });

    test('Clear cache should not throw error', () async {
      await expectLater(
        service.clearCache(),
        completes,
      );
    });

    test('Get last sync time returns null when no sync has occurred', () async {
      await service.clearCache();
      final lastSync = await service.getLastSyncTime();
      expect(lastSync, isNull);
    });
  });
}
