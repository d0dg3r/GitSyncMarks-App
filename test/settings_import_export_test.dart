import 'package:flutter_test/flutter_test.dart';
import 'package:gitsyncmarks/services/settings_import_export.dart';

void main() {
  group('SettingsImportExportService', () {
    final service = SettingsImportExportService();

    test('parses extension profile with githubToken alias', () {
      const json = '''
{
  "profiles": {
    "p1": {
      "id": "p1",
      "name": "Work",
      "githubToken": "secret-token",
      "gitProvider": "gitea",
      "serverUrl": "http://gitea.lan:3000",
      "owner": "joe",
      "repo": "my-bookmarks",
      "branch": "main",
      "filePath": "bookmarks"
    }
  },
  "activeProfileId": "p1"
}
''';
      final result = service.parseSettingsJson(json);
      expect(result.profiles, hasLength(1));
      final creds = result.profiles.first.credentials;
      expect(creds.token, 'secret-token');
      expect(creds.gitProvider, 'gitea');
      expect(creds.serverUrl, 'http://gitea.lan:3000');
      expect(creds.owner, 'joe');
      expect(creds.repo, 'my-bookmarks');
    });

    test('counts profiles missing tokens', () {
      const json = '''
{
  "profiles": {
    "a": { "name": "A", "owner": "o", "repo": "r", "branch": "main" },
    "b": { "name": "B", "token": "t", "owner": "o", "repo": "r", "branch": "main" }
  }
}
''';
      final result = service.parseSettingsJson(json);
      expect(
        SettingsImportExportService.countProfilesMissingTokens(result.profiles),
        1,
      );
    });
  });
}
