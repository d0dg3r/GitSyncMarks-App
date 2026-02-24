// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get help => 'Help';

  @override
  String get noBookmarksYet => 'No bookmarks yet';

  @override
  String get tapSyncToFetch => 'Tap Sync to fetch bookmarks from GitHub';

  @override
  String get configureInSettings => 'Configure GitHub connection in Settings';

  @override
  String get sync => 'Sync';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String couldNotOpenUrl(Object url) {
    return 'Could not open $url';
  }

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String get pleaseFillTokenOwnerRepo => 'Please fill Token, Owner, and Repo';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get connectionSuccessful => 'Connection successful';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get syncComplete => 'Sync complete';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get githubConnection => 'GitHub Connection';

  @override
  String get personalAccessToken => 'Personal Access Token (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. Create at: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => 'Repository Owner';

  @override
  String get ownerHint => 'your-github-username';

  @override
  String get repositoryName => 'Repository Name';

  @override
  String get repoHint => 'my-bookmarks';

  @override
  String get branch => 'Branch';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => 'Base Path';

  @override
  String get basePathHint => 'bookmarks';

  @override
  String get displayedFolders => 'Displayed Folders';

  @override
  String get displayedFoldersHelp =>
      'Available after Test Connection. Empty selection = all folders. At least one selected = only these folders.';

  @override
  String get save => 'Save';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get syncBookmarks => 'Sync Bookmarks';

  @override
  String version(String appVersion) {
    return 'Version $appVersion';
  }

  @override
  String get authorBy => 'By Joe Mild';

  @override
  String get aboutDescription =>
      'Mobile app for GitSyncMarks – view bookmarks from your GitHub repo and open them in your browser.';

  @override
  String get projects => 'Projects';

  @override
  String get formatFromGitSyncMarks =>
      'The bookmark format comes from GitSyncMarks.';

  @override
  String get gitSyncMarksDesc =>
      'Based on GitSyncMarks – the browser extension for bidirectional bookmark sync. This project was developed with GitSyncMarks as reference.';

  @override
  String get licenseMit => 'License: MIT';

  @override
  String get quickGuide => 'Quick Guide';

  @override
  String get help1Title => '1. Set up token';

  @override
  String get help1Body =>
      'Create a GitHub Personal Access Token (PAT). Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. Create at: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. Connect repo';

  @override
  String get help2Body =>
      'Enter Owner, Repo name, and Branch in Settings. Your repo should follow the GitSyncMarks format (folders like toolbar, menu, other with JSON files per bookmark).';

  @override
  String get help3Title => '3. Test Connection';

  @override
  String get help3Body =>
      'Click \"Test Connection\" to verify token and repo access. On success, the available root folders are shown.';

  @override
  String get help4Title => '4. Select folders';

  @override
  String get help4Body =>
      'Choose which folders to display (e.g. toolbar, mobile). Empty selection = all folders. At least one selected = only these folders.';

  @override
  String get help5Title => '5. Sync';

  @override
  String get help5Body =>
      'Click \"Sync Bookmarks\" to load bookmarks. Pull-to-refresh on the main screen reloads.';

  @override
  String get whichRepoFormat => 'Which repo format?';

  @override
  String get repoFormatDescription =>
      'The repo should follow the GitSyncMarks format: Base Path (e.g. \"bookmarks\") with subfolders like toolbar, menu, other, mobile. Each folder has _order.json and JSON files per bookmark with title and url.';

  @override
  String get support => 'Support';

  @override
  String get supportText =>
      'Questions or error messages? Open an issue in the project repository.';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-Mobile (GitHub Issues)';

  @override
  String get profiles => 'Profiles';

  @override
  String get profile => 'Profile';

  @override
  String get activeProfile => 'Active Profile';

  @override
  String get addProfile => 'Add Profile';

  @override
  String get renameProfile => 'Rename Profile';

  @override
  String get deleteProfile => 'Delete Profile';

  @override
  String deleteProfileConfirm(String name) {
    return 'Delete profile \"$name\"?';
  }

  @override
  String get profileName => 'Profile name';

  @override
  String profileCount(int count, int max) {
    return '$count/$max profiles';
  }

  @override
  String maxProfilesReached(int max) {
    return 'Maximum number of profiles reached ($max)';
  }

  @override
  String profileAdded(String name) {
    return 'Profile \"$name\" added';
  }

  @override
  String profileRenamed(String name) {
    return 'Profile renamed to \"$name\"';
  }

  @override
  String get profileDeleted => 'Profile deleted';

  @override
  String get cannotDeleteLastProfile => 'Cannot delete the last profile';

  @override
  String get importExport => 'Import / Export';

  @override
  String get importSettings => 'Import Settings';

  @override
  String get exportSettings => 'Export Settings';

  @override
  String get importSettingsDesc =>
      'Import profiles from a GitSyncMarks settings file (JSON)';

  @override
  String get exportSettingsDesc =>
      'Export all profiles as a GitSyncMarks settings file';

  @override
  String importSuccess(int count) {
    return 'Imported $count profile(s)';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String importConfirm(int count) {
    return 'Import $count profile(s)? This will replace all existing profiles.';
  }

  @override
  String get exportSuccess => 'Settings exported';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get rename => 'Rename';

  @override
  String get add => 'Add';

  @override
  String get import_ => 'Import';

  @override
  String get replace => 'Replace';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get info => 'Info';

  @override
  String get connection => 'Connection';

  @override
  String get folders => 'Folders';

  @override
  String get tabGitHub => 'GitHub';

  @override
  String get tabSync => 'Sync';

  @override
  String get tabFiles => 'Files';

  @override
  String get tabHelp => 'Help';

  @override
  String get tabAbout => 'About';

  @override
  String get subTabProfile => 'Profile';

  @override
  String get subTabConnection => 'Connection';

  @override
  String get subTabExportImport => 'Export / Import';

  @override
  String get subTabSettings => 'Settings';

  @override
  String get searchPlaceholder => 'Search bookmarks...';

  @override
  String noSearchResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get clearSearch => 'Clear search';

  @override
  String get automaticSync => 'Automatic synchronization';

  @override
  String get autoSyncActive => 'Auto-sync active';

  @override
  String get autoSyncDisabled => 'Auto-sync disabled';

  @override
  String nextSyncIn(String time) {
    return 'Next sync in $time';
  }

  @override
  String get syncProfileRealtime => 'Real-time';

  @override
  String get syncProfileFrequent => 'Frequent';

  @override
  String get syncProfileNormal => 'Normal';

  @override
  String get syncProfilePowersave => 'Power save';

  @override
  String get syncProfileCustom => 'Custom';

  @override
  String lastSynced(String time) {
    return 'Last synced $time';
  }

  @override
  String get neverSynced => 'Never synced';

  @override
  String get syncOnStart => 'Sync on app start';

  @override
  String get allowMoveReorder => 'Allow move and reorder';

  @override
  String get allowMoveReorderDesc =>
      'Drag handles and move-to-folder. Disable for read-only view.';

  @override
  String get allowMoveReorderDisable => 'Enable read-only (hide handles)';

  @override
  String get allowMoveReorderEnable => 'Enable editing (show handles)';

  @override
  String bookmarkCount(int count, int folders) {
    return '$count bookmarks in $folders folders';
  }

  @override
  String get syncNow => 'Sync Now';

  @override
  String get addBookmark => 'Add bookmark';

  @override
  String get addBookmarkTitle => 'Add Bookmark';

  @override
  String get bookmarkTitle => 'Bookmark title';

  @override
  String get selectFolder => 'Select folder';

  @override
  String get exportBookmarks => 'Export bookmarks';

  @override
  String get settingsSyncToGit => 'Sync settings to Git (encrypted)';

  @override
  String get settingsSyncPassword => 'Encryption password';

  @override
  String get settingsSyncPasswordHint =>
      'Set once per device. Must be the same on all devices.';

  @override
  String get settingsSyncRememberPassword => 'Remember password';

  @override
  String get settingsSyncPasswordSaved => 'Password saved (used for Push/Pull)';

  @override
  String get settingsSyncClearPassword => 'Clear saved password';

  @override
  String get settingsSyncSaveBtn => 'Save password';

  @override
  String get settingsSyncPasswordMissing => 'Please enter a password.';

  @override
  String get settingsSyncWithBookmarks =>
      'Sync settings when syncing bookmarks';

  @override
  String get settingsSyncPush => 'Push settings';

  @override
  String get settingsSyncPull => 'Pull settings';

  @override
  String get settingsSyncModeLabel => 'Sync mode';

  @override
  String get settingsSyncModeGlobal => 'Global — shared across all devices';

  @override
  String get settingsSyncModeIndividual => 'Individual — this device only';

  @override
  String get settingsSyncImportTitle => 'Import from other device';

  @override
  String get settingsSyncLoadConfigs => 'Load available configs';

  @override
  String get settingsSyncImport => 'Import';

  @override
  String get settingsSyncImportEmpty => 'No device configs found';

  @override
  String get settingsSyncImportSuccess => 'Settings imported successfully';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get documentation => 'Documentation';

  @override
  String get voteBacklog => 'Vote on backlog';

  @override
  String get discussions => 'Discussions';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get shareLinkAddBookmark => 'Add shared link as bookmark';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get clearCacheDesc =>
      'Remove cached bookmark data. Sync will run automatically if GitHub is configured.';

  @override
  String get clearCacheSuccess => 'Cache cleared.';

  @override
  String get moveToFolder => 'Move to folder';

  @override
  String get moveToFolderSuccess => 'Bookmark moved';

  @override
  String get moveToFolderFailed => 'Failed to move bookmark';

  @override
  String get deleteBookmark => 'Delete Bookmark';

  @override
  String deleteBookmarkConfirm(String title) {
    return 'Delete bookmark \"$title\"?';
  }

  @override
  String get bookmarkDeleted => 'Bookmark deleted';

  @override
  String get orderUpdated => 'Order updated';

  @override
  String get rootFolder => 'Root Folder';

  @override
  String get rootFolderHelp =>
      'Select a folder whose subfolders become the tabs. Default shows all top-level folders.';

  @override
  String get allFolders => 'All Folders';

  @override
  String get selectRootFolder => 'Select Root Folder';

  @override
  String get exportPasswordTitle => 'Export Password';

  @override
  String get exportPasswordHint => 'Leave empty for unencrypted export';

  @override
  String get importPasswordTitle => 'Encrypted File';

  @override
  String get importPasswordHint => 'Enter the encryption password';

  @override
  String get importSettingsAction => 'Import Settings';

  @override
  String get importingSettings => 'Importing settings…';

  @override
  String get orImportExisting => 'or import existing settings';

  @override
  String get wrongPassword => 'Wrong password. Please try again.';

  @override
  String get export_ => 'Export';

  @override
  String get resetAll => 'Reset all data';

  @override
  String get resetConfirmTitle => 'Reset App?';

  @override
  String get resetConfirmMessage =>
      'This will delete all profiles, settings and cached bookmarks. The app will return to its initial state.';

  @override
  String get resetSuccess => 'All data has been reset';
}
