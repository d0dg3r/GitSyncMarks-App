import 'package:flutter_test/flutter_test.dart';
import 'package:gitsyncmarks/models/bookmark.dart';

void main() {
  group('Bookmark Model Tests', () {
    test('Parse bookmark from JSON with url', () {
      final json = {
        'id': '1',
        'title': 'Google',
        'type': 'url',
        'url': 'https://www.google.com',
      };

      final bookmark = Bookmark.fromJson(json);

      expect(bookmark.id, '1');
      expect(bookmark.title, 'Google');
      expect(bookmark.url, 'https://www.google.com');
      expect(bookmark.type, BookmarkType.link);
      expect(bookmark.isFolder, false);
    });

    test('Parse bookmark folder with children', () {
      final json = {
        'id': '1',
        'title': 'Development',
        'type': 'folder',
        'children': [
          {
            'id': '2',
            'title': 'GitHub',
            'type': 'url',
            'url': 'https://github.com',
          },
        ],
      };

      final bookmark = Bookmark.fromJson(json);

      expect(bookmark.id, '1');
      expect(bookmark.title, 'Development');
      expect(bookmark.type, BookmarkType.folder);
      expect(bookmark.isFolder, true);
      expect(bookmark.children.length, 1);
      expect(bookmark.children[0].title, 'GitHub');
    });

    test('Convert bookmark to JSON', () {
      final bookmark = Bookmark(
        id: '1',
        title: 'Test',
        url: 'https://test.com',
        type: BookmarkType.link,
      );

      final json = bookmark.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Test');
      expect(json['url'], 'https://test.com');
      expect(json['type'], 'link');
    });
  });
}
