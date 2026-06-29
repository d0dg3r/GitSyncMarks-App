import 'package:flutter_test/flutter_test.dart';
import 'package:gitsyncmarks/config/git_provider_caps.dart';
import 'package:gitsyncmarks/services/remote_fetch.dart';

/// Automated parity checks aligned with GitSyncMarks extension 3.0.x
/// (`lib/git-provider-common.js`, `lib/sync-settings.js`, `lib/remote-fetch.js`).
void main() {
  group('extension 3.0 interop parity (automated)', () {
    test('six provider IDs with expected write strategies', () {
      expect(providerCaps.keys, containsAll([
        GitProviders.github,
        GitProviders.gitlab,
        GitProviders.gitea,
        GitProviders.forgejo,
        GitProviders.codeberg,
        GitProviders.gogs,
      ]));
      expect(
        getProviderCaps(GitProviders.github).writeStrategy,
        GitWriteStrategy.tree,
      );
      expect(
        getProviderCaps(GitProviders.gitlab).writeStrategy,
        GitWriteStrategy.gitlabCommits,
      );
      for (final id in [
        GitProviders.gitea,
        GitProviders.forgejo,
        GitProviders.codeberg,
        GitProviders.gogs,
      ]) {
        expect(
          getProviderCaps(id).writeStrategy,
          GitWriteStrategy.contents,
          reason: '$id should use contents write strategy',
        );
      }
    });

    test('diff ignore suffixes match extension DIFF_IGNORE_SUFFIXES', () {
      expect(diffIgnoreSuffixes, [
        '/README.md',
        '/_index.json',
        '/bookmarks.html',
        '/feed.xml',
        '/dashy-conf.yml',
      ]);
    });

    test('settings.enc pattern matches extension SETTINGS_ENC_PATTERN', () {
      expect(settingsEncPattern.hasMatch('profiles/work/settings.enc'), isTrue);
      expect(settingsEncPattern.hasMatch('bookmarks/settings-backup.enc'), isTrue);
      expect(settingsEncPattern.hasMatch('bookmarks/toolbar/foo.json'), isFalse);
    });

    test('repo folder prefixes per provider', () {
      expect(getProviderCaps(GitProviders.github).repoFolderPrefix, 'GitHubRepos');
      expect(getProviderCaps(GitProviders.gitlab).repoFolderPrefix, 'GitLabRepos');
      expect(getProviderCaps(GitProviders.codeberg).repoFolderPrefix, 'CodebergRepos');
      expect(getProviderCaps(GitProviders.gitea).repoFolderPrefix, 'GiteaRepos');
    });

    test('Gitea server URL port preserved for self-hosted interop', () {
      expect(
        normalizeServerUrl('http://gitea.lan:3000'),
        'http://gitea.lan:3000',
      );
      expect(
        resolveApiBase(GitProviders.gitea, 'http://gitea.lan:3000'),
        'http://gitea.lan:3000/api/v1',
      );
    });
  });
}
