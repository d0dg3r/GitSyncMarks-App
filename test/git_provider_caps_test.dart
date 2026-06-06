import 'package:flutter_test/flutter_test.dart';
import 'package:gitsyncmarks/config/git_credentials.dart';
import 'package:gitsyncmarks/config/git_provider_caps.dart';
import 'package:gitsyncmarks/services/git_provider.dart';

void main() {
  group('git_provider_caps', () {
    test('resolveApiBase defaults to GitHub', () {
      expect(
        resolveApiBase(GitProviders.github, ''),
        'https://api.github.com',
      );
    });

    test('resolveApiBase GitHub Enterprise', () {
      expect(
        resolveApiBase(GitProviders.github, 'https://github.mycompany.com'),
        'https://github.mycompany.com/api/v3',
      );
    });

    test('resolveApiBase GitLab subgroup project path encoding', () {
      final creds = GitCredentials(
        token: 't',
        owner: 'group/sub',
        repo: 'proj',
        branch: 'main',
        gitProvider: GitProviders.gitlab,
      );
      final api = createGitProvider(creds);
      expect(api.owner, 'group/sub');
      api.close();
    });

    test('usesContentsApiReads for Gitea family', () {
      expect(usesContentsApiReads(GitProviders.gitea), isTrue);
      expect(usesContentsApiReads(GitProviders.codeberg), isTrue);
      expect(usesContentsApiReads(GitProviders.github), isFalse);
      expect(usesContentsApiReads(GitProviders.gitlab), isFalse);
    });

    test('buildCommitUrl GitLab infix', () {
      final url = buildCommitUrl(
        providerId: GitProviders.gitlab,
        owner: 'group',
        repo: 'proj',
        commitSha: 'abc123',
      );
      expect(url, contains('/-/commit/abc123'));
    });

    test('GitCredentials migration defaults gitProvider to github', () {
      final creds = GitCredentials.fromJson({
        'token': 'x',
        'owner': 'o',
        'repo': 'r',
        'branch': 'main',
        'filePath': 'bookmarks',
      });
      expect(creds.gitProvider, GitProviders.github);
      expect(creds.isValid, isTrue);
    });
  });
}
