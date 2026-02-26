import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GitSyncMarks'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @noBookmarksYet.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get noBookmarksYet;

  /// No description provided for @tapSyncToFetch.
  ///
  /// In en, this message translates to:
  /// **'Tap Sync to fetch bookmarks from GitHub'**
  String get tapSyncToFetch;

  /// No description provided for @configureInSettings.
  ///
  /// In en, this message translates to:
  /// **'Configure GitHub connection in Settings'**
  String get configureInSettings;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @couldNotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpenUrl(Object url);

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// No description provided for @pleaseFillTokenOwnerRepo.
  ///
  /// In en, this message translates to:
  /// **'Please fill Token, Owner, and Repo'**
  String get pleaseFillTokenOwnerRepo;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @connectionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Connection successful'**
  String get connectionSuccessful;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectionFailed;

  /// No description provided for @syncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncComplete;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @githubConnection.
  ///
  /// In en, this message translates to:
  /// **'GitHub Connection'**
  String get githubConnection;

  /// No description provided for @personalAccessToken.
  ///
  /// In en, this message translates to:
  /// **'Personal Access Token (PAT)'**
  String get personalAccessToken;

  /// No description provided for @tokenHint.
  ///
  /// In en, this message translates to:
  /// **'ghp_xxxxxxxxxxxxxxxxxxxx'**
  String get tokenHint;

  /// No description provided for @tokenHelper.
  ///
  /// In en, this message translates to:
  /// **'Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. Create at: GitHub → Settings → Developer settings → Personal access tokens'**
  String get tokenHelper;

  /// No description provided for @repositoryOwner.
  ///
  /// In en, this message translates to:
  /// **'Repository Owner'**
  String get repositoryOwner;

  /// No description provided for @ownerHint.
  ///
  /// In en, this message translates to:
  /// **'your-github-username'**
  String get ownerHint;

  /// No description provided for @repositoryName.
  ///
  /// In en, this message translates to:
  /// **'Repository Name'**
  String get repositoryName;

  /// No description provided for @repoHint.
  ///
  /// In en, this message translates to:
  /// **'my-bookmarks'**
  String get repoHint;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @branchHint.
  ///
  /// In en, this message translates to:
  /// **'main'**
  String get branchHint;

  /// No description provided for @basePath.
  ///
  /// In en, this message translates to:
  /// **'Base Path'**
  String get basePath;

  /// No description provided for @basePathHint.
  ///
  /// In en, this message translates to:
  /// **'bookmarks'**
  String get basePathHint;

  /// No description provided for @displayedFolders.
  ///
  /// In en, this message translates to:
  /// **'Displayed Folders'**
  String get displayedFolders;

  /// No description provided for @displayedFoldersHelp.
  ///
  /// In en, this message translates to:
  /// **'Available after Test Connection. Empty selection = all folders. At least one selected = only these folders.'**
  String get displayedFoldersHelp;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @syncBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Sync Bookmarks'**
  String get syncBookmarks;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {appVersion}'**
  String version(String appVersion);

  /// No description provided for @authorBy.
  ///
  /// In en, this message translates to:
  /// **'By Joe Mild'**
  String get authorBy;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Mobile app for GitSyncMarks – view bookmarks from your GitHub repo and open them in your browser.'**
  String get aboutDescription;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @formatFromGitSyncMarks.
  ///
  /// In en, this message translates to:
  /// **'The bookmark format comes from GitSyncMarks.'**
  String get formatFromGitSyncMarks;

  /// No description provided for @gitSyncMarksDesc.
  ///
  /// In en, this message translates to:
  /// **'Based on GitSyncMarks – the browser extension for bidirectional bookmark sync. This project was developed with GitSyncMarks as reference.'**
  String get gitSyncMarksDesc;

  /// No description provided for @licenseMit.
  ///
  /// In en, this message translates to:
  /// **'License: MIT'**
  String get licenseMit;

  /// No description provided for @quickGuide.
  ///
  /// In en, this message translates to:
  /// **'Quick Guide'**
  String get quickGuide;

  /// No description provided for @help1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Set up token'**
  String get help1Title;

  /// No description provided for @help1Body.
  ///
  /// In en, this message translates to:
  /// **'Create a GitHub Personal Access Token (PAT). Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. Create at: GitHub → Settings → Developer settings → Personal access tokens'**
  String get help1Body;

  /// No description provided for @help2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Connect repo'**
  String get help2Title;

  /// No description provided for @help2Body.
  ///
  /// In en, this message translates to:
  /// **'Enter Owner, Repo name, and Branch in Settings. Your repo should follow the GitSyncMarks format (folders like toolbar, menu, other with JSON files per bookmark).'**
  String get help2Body;

  /// No description provided for @help3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Test Connection'**
  String get help3Title;

  /// No description provided for @help3Body.
  ///
  /// In en, this message translates to:
  /// **'Click \"Test Connection\" to verify token and repo access. On success, the available root folders are shown.'**
  String get help3Body;

  /// No description provided for @help4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Select folders'**
  String get help4Title;

  /// No description provided for @help4Body.
  ///
  /// In en, this message translates to:
  /// **'Choose which folders to display (e.g. toolbar, mobile). Empty selection = all folders. At least one selected = only these folders.'**
  String get help4Body;

  /// No description provided for @help5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Sync'**
  String get help5Title;

  /// No description provided for @help5Body.
  ///
  /// In en, this message translates to:
  /// **'Click \"Sync Bookmarks\" to load bookmarks. Pull-to-refresh on the main screen reloads.'**
  String get help5Body;

  /// No description provided for @whichRepoFormat.
  ///
  /// In en, this message translates to:
  /// **'Which repo format?'**
  String get whichRepoFormat;

  /// No description provided for @repoFormatDescription.
  ///
  /// In en, this message translates to:
  /// **'The repo should follow the GitSyncMarks format: Base Path (e.g. \"bookmarks\") with subfolders like toolbar, menu, other, mobile. Each folder has _order.json and JSON files per bookmark with title and url.'**
  String get repoFormatDescription;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportText.
  ///
  /// In en, this message translates to:
  /// **'Questions or error messages? Open an issue in the project repository.'**
  String get supportText;

  /// No description provided for @gitSyncMarksAndroidIssues.
  ///
  /// In en, this message translates to:
  /// **'GitSyncMarks-App (GitHub Issues)'**
  String get gitSyncMarksAndroidIssues;

  /// No description provided for @profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @activeProfile.
  ///
  /// In en, this message translates to:
  /// **'Active Profile'**
  String get activeProfile;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add Profile'**
  String get addProfile;

  /// No description provided for @renameProfile.
  ///
  /// In en, this message translates to:
  /// **'Rename Profile'**
  String get renameProfile;

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteProfile;

  /// No description provided for @deleteProfileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete profile \"{name}\"?'**
  String deleteProfileConfirm(String name);

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get profileName;

  /// No description provided for @profileCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} profiles'**
  String profileCount(int count, int max);

  /// No description provided for @maxProfilesReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of profiles reached ({max})'**
  String maxProfilesReached(int max);

  /// No description provided for @profileAdded.
  ///
  /// In en, this message translates to:
  /// **'Profile \"{name}\" added'**
  String profileAdded(String name);

  /// No description provided for @profileRenamed.
  ///
  /// In en, this message translates to:
  /// **'Profile renamed to \"{name}\"'**
  String profileRenamed(String name);

  /// No description provided for @profileDeleted.
  ///
  /// In en, this message translates to:
  /// **'Profile deleted'**
  String get profileDeleted;

  /// No description provided for @cannotDeleteLastProfile.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete the last profile'**
  String get cannotDeleteLastProfile;

  /// No description provided for @importExport.
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get importExport;

  /// No description provided for @importSettings.
  ///
  /// In en, this message translates to:
  /// **'Import Settings'**
  String get importSettings;

  /// No description provided for @exportSettings.
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get exportSettings;

  /// No description provided for @importSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Import profiles from a GitSyncMarks settings file (JSON)'**
  String get importSettingsDesc;

  /// No description provided for @exportSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Export all profiles as a GitSyncMarks settings file'**
  String get exportSettingsDesc;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} profile(s)'**
  String importSuccess(int count);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @importConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import {count} profile(s)? This will replace all existing profiles.'**
  String importConfirm(int count);

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings exported'**
  String get exportSuccess;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @import_.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import_;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @tabGitHub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get tabGitHub;

  /// No description provided for @tabSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get tabSync;

  /// No description provided for @tabFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get tabFiles;

  /// No description provided for @tabHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get tabHelp;

  /// No description provided for @tabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tabAbout;

  /// No description provided for @subTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get subTabProfile;

  /// No description provided for @subTabConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get subTabConnection;

  /// No description provided for @subTabExportImport.
  ///
  /// In en, this message translates to:
  /// **'Export / Import'**
  String get subTabExportImport;

  /// No description provided for @subTabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get subTabSettings;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search bookmarks...'**
  String get searchPlaceholder;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noSearchResults(String query);

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @automaticSync.
  ///
  /// In en, this message translates to:
  /// **'Automatic synchronization'**
  String get automaticSync;

  /// No description provided for @autoSyncActive.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync active'**
  String get autoSyncActive;

  /// No description provided for @autoSyncDisabled.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync disabled'**
  String get autoSyncDisabled;

  /// No description provided for @nextSyncIn.
  ///
  /// In en, this message translates to:
  /// **'Next sync in {time}'**
  String nextSyncIn(String time);

  /// No description provided for @syncProfileRealtime.
  ///
  /// In en, this message translates to:
  /// **'Real-time'**
  String get syncProfileRealtime;

  /// No description provided for @syncProfileFrequent.
  ///
  /// In en, this message translates to:
  /// **'Frequent'**
  String get syncProfileFrequent;

  /// No description provided for @syncProfileNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get syncProfileNormal;

  /// No description provided for @syncProfilePowersave.
  ///
  /// In en, this message translates to:
  /// **'Power save'**
  String get syncProfilePowersave;

  /// No description provided for @syncProfileCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get syncProfileCustom;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String lastSynced(String time);

  /// No description provided for @neverSynced.
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get neverSynced;

  /// No description provided for @syncOnStart.
  ///
  /// In en, this message translates to:
  /// **'Sync on app start'**
  String get syncOnStart;

  /// No description provided for @allowMoveReorder.
  ///
  /// In en, this message translates to:
  /// **'Allow move and reorder'**
  String get allowMoveReorder;

  /// No description provided for @allowMoveReorderDesc.
  ///
  /// In en, this message translates to:
  /// **'Drag handles and move-to-folder. Disable for read-only view.'**
  String get allowMoveReorderDesc;

  /// No description provided for @allowMoveReorderDisable.
  ///
  /// In en, this message translates to:
  /// **'Enable read-only (hide handles)'**
  String get allowMoveReorderDisable;

  /// No description provided for @allowMoveReorderEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable editing (show handles)'**
  String get allowMoveReorderEnable;

  /// No description provided for @bookmarkCount.
  ///
  /// In en, this message translates to:
  /// **'{count} bookmarks in {folders} folders'**
  String bookmarkCount(int count, int folders);

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @addBookmark.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get addBookmark;

  /// No description provided for @addBookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Bookmark'**
  String get addBookmarkTitle;

  /// No description provided for @bookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmark title'**
  String get bookmarkTitle;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select folder'**
  String get selectFolder;

  /// No description provided for @exportBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Export bookmarks'**
  String get exportBookmarks;

  /// No description provided for @settingsSyncToGit.
  ///
  /// In en, this message translates to:
  /// **'Sync settings to Git (encrypted)'**
  String get settingsSyncToGit;

  /// No description provided for @settingsSyncPassword.
  ///
  /// In en, this message translates to:
  /// **'Encryption password'**
  String get settingsSyncPassword;

  /// No description provided for @settingsSyncPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Set once per device. Must be the same on all devices.'**
  String get settingsSyncPasswordHint;

  /// No description provided for @settingsSyncRememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember password'**
  String get settingsSyncRememberPassword;

  /// No description provided for @settingsSyncPasswordSaved.
  ///
  /// In en, this message translates to:
  /// **'Password saved (used for Push/Pull)'**
  String get settingsSyncPasswordSaved;

  /// No description provided for @settingsSyncClearPassword.
  ///
  /// In en, this message translates to:
  /// **'Clear saved password'**
  String get settingsSyncClearPassword;

  /// No description provided for @settingsSyncSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get settingsSyncSaveBtn;

  /// No description provided for @settingsSyncPasswordMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get settingsSyncPasswordMissing;

  /// No description provided for @settingsSyncWithBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Sync settings when syncing bookmarks'**
  String get settingsSyncWithBookmarks;

  /// No description provided for @settingsSyncPush.
  ///
  /// In en, this message translates to:
  /// **'Push settings'**
  String get settingsSyncPush;

  /// No description provided for @settingsSyncPull.
  ///
  /// In en, this message translates to:
  /// **'Pull settings'**
  String get settingsSyncPull;

  /// No description provided for @settingsSyncModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync mode'**
  String get settingsSyncModeLabel;

  /// No description provided for @settingsSyncModeGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global — shared across all devices'**
  String get settingsSyncModeGlobal;

  /// No description provided for @settingsSyncModeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual — this device only'**
  String get settingsSyncModeIndividual;

  /// No description provided for @settingsSyncImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from other device'**
  String get settingsSyncImportTitle;

  /// No description provided for @settingsSyncLoadConfigs.
  ///
  /// In en, this message translates to:
  /// **'Load available configs'**
  String get settingsSyncLoadConfigs;

  /// No description provided for @settingsSyncImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsSyncImport;

  /// No description provided for @settingsSyncImportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No device configs found'**
  String get settingsSyncImportEmpty;

  /// No description provided for @settingsSyncImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings imported successfully'**
  String get settingsSyncImportSuccess;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @documentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get documentation;

  /// No description provided for @voteBacklog.
  ///
  /// In en, this message translates to:
  /// **'Vote on backlog'**
  String get voteBacklog;

  /// No description provided for @discussions.
  ///
  /// In en, this message translates to:
  /// **'Discussions'**
  String get discussions;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @shareLinkAddBookmark.
  ///
  /// In en, this message translates to:
  /// **'Add shared link as bookmark'**
  String get shareLinkAddBookmark;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @clearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove cached bookmark data. Sync will run automatically if GitHub is configured.'**
  String get clearCacheDesc;

  /// No description provided for @clearCacheSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared.'**
  String get clearCacheSuccess;

  /// No description provided for @moveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get moveToFolder;

  /// No description provided for @moveToFolderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Bookmark moved'**
  String get moveToFolderSuccess;

  /// No description provided for @moveToFolderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to move bookmark'**
  String get moveToFolderFailed;

  /// No description provided for @deleteBookmark.
  ///
  /// In en, this message translates to:
  /// **'Delete Bookmark'**
  String get deleteBookmark;

  /// No description provided for @deleteBookmarkConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete bookmark \"{title}\"?'**
  String deleteBookmarkConfirm(String title);

  /// No description provided for @bookmarkDeleted.
  ///
  /// In en, this message translates to:
  /// **'Bookmark deleted'**
  String get bookmarkDeleted;

  /// No description provided for @orderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order updated'**
  String get orderUpdated;

  /// No description provided for @rootFolder.
  ///
  /// In en, this message translates to:
  /// **'Root Folder'**
  String get rootFolder;

  /// No description provided for @rootFolderHelp.
  ///
  /// In en, this message translates to:
  /// **'Select a folder whose subfolders become the tabs. Default shows all top-level folders.'**
  String get rootFolderHelp;

  /// No description provided for @allFolders.
  ///
  /// In en, this message translates to:
  /// **'All Folders'**
  String get allFolders;

  /// No description provided for @selectRootFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Root Folder'**
  String get selectRootFolder;

  /// No description provided for @exportPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Password'**
  String get exportPasswordTitle;

  /// No description provided for @exportPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for unencrypted export'**
  String get exportPasswordHint;

  /// No description provided for @importPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted File'**
  String get importPasswordTitle;

  /// No description provided for @importPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the encryption password'**
  String get importPasswordHint;

  /// No description provided for @importSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Import Settings'**
  String get importSettingsAction;

  /// No description provided for @importingSettings.
  ///
  /// In en, this message translates to:
  /// **'Importing settings…'**
  String get importingSettings;

  /// No description provided for @orImportExisting.
  ///
  /// In en, this message translates to:
  /// **'or import existing settings'**
  String get orImportExisting;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password. Please try again.'**
  String get wrongPassword;

  /// No description provided for @export_.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export_;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get resetAll;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset App?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all profiles, settings and cached bookmarks. The app will return to its initial state.'**
  String get resetConfirmMessage;

  /// No description provided for @resetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data has been reset'**
  String get resetSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
