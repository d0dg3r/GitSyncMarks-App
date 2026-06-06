// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => 'Ustawienia';

  @override
  String get about => 'O aplikacji';

  @override
  String get help => 'Pomoc';

  @override
  String get noBookmarksYet => 'Brak zakładek';

  @override
  String get tapSyncToFetch =>
      'Naciśnij Synchronizuj, aby pobrać zakładki z GitHub';

  @override
  String get configureInSettings =>
      'Skonfiguruj połączenie z GitHub w Ustawieniach';

  @override
  String get sync => 'Synchronizuj';

  @override
  String get openSettings => 'Otwórz ustawienia';

  @override
  String get error => 'Błąd';

  @override
  String get retry => 'Ponów';

  @override
  String couldNotOpenUrl(Object url) {
    return 'Nie można otworzyć $url';
  }

  @override
  String get couldNotOpenLink => 'Nie można otworzyć łącza';

  @override
  String get pleaseFillTokenOwnerRepo => 'Wypełnij Token, Owner i Repo';

  @override
  String get settingsSaved => 'Ustawienia zapisane';

  @override
  String get connectionSuccessful => 'Połączenie udane';

  @override
  String get connectionFailed => 'Połączenie nieudane';

  @override
  String get syncComplete => 'Synchronizacja zakończona';

  @override
  String get syncFailed => 'Synchronizacja nieudana';

  @override
  String get githubConnection => 'Połączenie z GitHub';

  @override
  String get gitConnection => 'Połączenie z Git';

  @override
  String get gitProvider => 'Git provider';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get serverUrlHint => 'https://gitea.example.com';

  @override
  String get serverUrlHelperRequired => 'Required for self-hosted instances';

  @override
  String get serverUrlHelperOptional =>
      'Optional — for GitHub Enterprise or self-managed GitLab';

  @override
  String get gitlabOwnerHint => 'group or group/subgroup';

  @override
  String get tokenHintGitea => 'Gitea access token';

  @override
  String get tokenHintGitLab => 'glpat-xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelperGitea =>
      'Create in your instance: Settings → Applications → Generate New Token (repository read/write)';

  @override
  String get tokenHelperGitLab =>
      'Personal access token with api scope (read/write repository)';

  @override
  String get providerGitHub => 'GitHub';

  @override
  String get providerGitLab => 'GitLab';

  @override
  String get providerGitea => 'Gitea';

  @override
  String get providerForgejo => 'Forgejo';

  @override
  String get providerCodeberg => 'Codeberg';

  @override
  String get providerGogs => 'Gogs';

  @override
  String get personalAccessToken => 'Osobisty token dostępu (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'Classic PAT: Zakres \'repo\'. Fine-grained: Contents Read. Utwórz w: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => 'Właściciel repozytorium';

  @override
  String get ownerHint => 'twoja-nazwa-uzytkownika-github';

  @override
  String get repositoryName => 'Nazwa repozytorium';

  @override
  String get repoHint => 'moje-zakladki';

  @override
  String get branch => 'Gałąź';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => 'Ścieżka bazowa';

  @override
  String get basePathHint => 'zakladki';

  @override
  String get displayedFolders => 'Wyświetlane foldery';

  @override
  String get displayedFoldersHelp =>
      'Dostępne po Teście połączenia. Puste zaznaczenie = wszystkie foldery. Przynajmniej jeden wybrany = tylko te foldery.';

  @override
  String get save => 'Zapisz';

  @override
  String get testConnection => 'Testuj połączenie';

  @override
  String get syncBookmarks => 'Synchronizuj zakładki';

  @override
  String version(String appVersion) {
    return 'Wersja $appVersion';
  }

  @override
  String get authorBy => 'Autor: Joe Mild';

  @override
  String get aboutDescription =>
      'Aplikacja mobilna dla GitSyncMarks – przeglądaj zakładki z repozytorium GitHub i otwieraj je w przeglądarce.';

  @override
  String get projects => 'Projekty';

  @override
  String get formatFromGitSyncMarks =>
      'Format zakładek pochodzi z GitSyncMarks.';

  @override
  String get gitSyncMarksDesc =>
      'Oparty na GitSyncMarks – rozszerzeniu przeglądarki do dwukierunkowej synchronizacji zakładek. Projekt opracowany z GitSyncMarks jako wzorzec.';

  @override
  String get licenseMit => 'Licencja: MIT';

  @override
  String get quickGuide => 'Szybki przewodnik';

  @override
  String get help1Title => '1. Skonfiguruj token';

  @override
  String get help1Body =>
      'Utwórz GitHub Personal Access Token (PAT). Classic PAT: Zakres \'repo\'. Fine-grained: Contents Read. Utwórz w: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. Połącz repozytorium';

  @override
  String get help2Body =>
      'Wprowadź Owner, nazwę Repo i Branch w Ustawieniach. Repozytorium powinno być zgodne z formatem GitSyncMarks: foldery główne toolbar i other (tworzone przez rozszerzenie przeglądarki, np. 2.7.x), każdy z _order.json i jednym plikiem JSON na zakładkę.';

  @override
  String get help3Title => '3. Testuj połączenie';

  @override
  String get help3Body =>
      'Kliknij \"Test Connection\", aby zweryfikować token i dostęp do repozytorium. Po sukcesie wyświetlane są dostępne foldery główne.';

  @override
  String get help4Title => '4. Wybierz foldery';

  @override
  String get help4Body =>
      'Wybierz, które foldery główne wyświetlać (np. toolbar, other). Puste zaznaczenie = wszystkie. Przynajmniej jeden wybrany = tylko te foldery.';

  @override
  String get help5Title => '5. Synchronizuj';

  @override
  String get help5Body =>
      'Kliknij \"Sync Bookmarks\", aby załadować zakładki. Pociągnij, aby odświeżyć na ekranie głównym.';

  @override
  String get whichRepoFormat => 'Jaki format repozytorium?';

  @override
  String get repoFormatDescription =>
      'Repozytorium powinno być zgodne z formatem GitSyncMarks: Base Path (np. \"bookmarks\") z podfolderami toolbar i other (rozszerzenie nie synchronizuje menu/mobile jako głównych). Każdy folder ma _order.json i pliki JSON z title i url. Zgodne z rozszerzeniem GitSyncMarks (np. 2.7.x).';

  @override
  String get support => 'Wsparcie';

  @override
  String get supportText =>
      'Pytania lub komunikaty o błędach? Otwórz zgłoszenie w repozytorium projektu.';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (GitHub Issues)';

  @override
  String get profiles => 'Profile';

  @override
  String get profile => 'Profil';

  @override
  String get activeProfile => 'Aktywny profil';

  @override
  String get addProfile => 'Dodaj profil';

  @override
  String get renameProfile => 'Zmień nazwę profilu';

  @override
  String get deleteProfile => 'Usuń profil';

  @override
  String deleteProfileConfirm(String name) {
    return 'Usunąć profil \"$name\"?';
  }

  @override
  String get profileName => 'Nazwa profilu';

  @override
  String profileCount(int count, int max) {
    return '$count/$max profili';
  }

  @override
  String maxProfilesReached(int max) {
    return 'Osiągnięto maksymalną liczbę profili ($max)';
  }

  @override
  String profileAdded(String name) {
    return 'Profil \"$name\" dodany';
  }

  @override
  String profileRenamed(String name) {
    return 'Profil zmieniono na \"$name\"';
  }

  @override
  String get profileDeleted => 'Profil usunięty';

  @override
  String get cannotDeleteLastProfile => 'Nie można usunąć ostatniego profilu';

  @override
  String get importExport => 'Importuj / Eksportuj';

  @override
  String get importSettings => 'Importuj ustawienia';

  @override
  String get exportSettings => 'Eksportuj ustawienia';

  @override
  String get importSettingsDesc =>
      'Importuj profile z pliku ustawień GitSyncMarks (JSON)';

  @override
  String get exportSettingsDesc =>
      'Eksportuj wszystkie profile jako plik ustawień GitSyncMarks';

  @override
  String importSuccess(int count) {
    return 'Zaimportowano $count profil(e/i)';
  }

  @override
  String importFailed(String error) {
    return 'Import nieudany: $error';
  }

  @override
  String importConfirm(int count) {
    return 'Importować $count profil(e/i)? Wszystkie istniejące profile zostaną zastąpione.';
  }

  @override
  String get exportSuccess => 'Ustawienia wyeksportowane';

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get rename => 'Zmień nazwę';

  @override
  String get add => 'Dodaj';

  @override
  String get import_ => 'Importuj';

  @override
  String get replace => 'Zastąp';

  @override
  String get bookmarks => 'Zakładki';

  @override
  String get info => 'Informacje';

  @override
  String get connection => 'Połączenie';

  @override
  String get folders => 'Foldery';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => 'Synchronizuj';

  @override
  String get tabFiles => 'Pliki';

  @override
  String get tabGeneral => 'Ogólne';

  @override
  String get tabHelp => 'Pomoc';

  @override
  String get tabAbout => 'O aplikacji';

  @override
  String get subTabProfile => 'Profil';

  @override
  String get subTabConnection => 'Połączenie';

  @override
  String get subTabExportImport => 'Eksportuj / Importuj';

  @override
  String get subTabSettings => 'Ustawienia';

  @override
  String get searchPlaceholder => 'Szukaj zakładek...';

  @override
  String noSearchResults(String query) {
    return 'Brak wyników dla \"$query\"';
  }

  @override
  String get clearSearch => 'Wyczyść wyszukiwanie';

  @override
  String get automaticSync => 'Automatyczna synchronizacja';

  @override
  String get autoSyncActive => 'Autosynchronizacja aktywna';

  @override
  String get autoSyncDisabled => 'Autosynchronizacja wyłączona';

  @override
  String nextSyncIn(String time) {
    return 'Następna synchronizacja za $time';
  }

  @override
  String get syncProfileRealtime => 'Czas rzeczywisty';

  @override
  String get syncProfileFrequent => 'Częste';

  @override
  String get syncProfileNormal => 'Normalne';

  @override
  String get syncProfilePowersave => 'Oszczędzanie energii';

  @override
  String get syncProfileCustom => 'Niestandardowy';

  @override
  String get syncProfileMeaningTitle => 'Co oznaczają te profile:';

  @override
  String get syncProfileMeaningRealtime =>
      'Czas rzeczywisty: synchronizacja co minutę (najwyższa aktualność, wyższe zużycie baterii).';

  @override
  String get syncProfileMeaningFrequent =>
      'Częste: synchronizacja co 5 minut (zrównoważone dla aktywnego użytkowania).';

  @override
  String get syncProfileMeaningNormal =>
      'Normalne: synchronizacja co 15 minut (zalecana domyślna).';

  @override
  String get syncProfileMeaningPowersave =>
      'Oszczędzanie energii: synchronizacja co 60 minut (minimalne zużycie baterii/sieci).';

  @override
  String get syncProfileMeaningCustom =>
      'Niestandardowy: ustaw własny interwał w minutach.';

  @override
  String get customSyncIntervalLabel =>
      'Niestandardowy interwał synchronizacji (minuty)';

  @override
  String get customSyncIntervalHint => 'Wprowadź wartość od 1 do 1440';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return 'Wprowadź prawidłowy interwał od $min do $max minut.';
  }

  @override
  String get syncCommit => 'Commit';

  @override
  String lastSynced(String time) {
    return 'Ostatnia synchronizacja $time';
  }

  @override
  String get neverSynced => 'Nigdy nie synchronizowano';

  @override
  String get syncOnStart => 'Synchronizuj przy uruchomieniu';

  @override
  String get allowMoveReorder =>
      'Zezwól na przenoszenie i zmienianie kolejności';

  @override
  String get allowMoveReorderDesc =>
      'Uchwyty przeciągania i przenoszenie do folderu. Wyłącz dla widoku tylko do odczytu.';

  @override
  String get allowMoveReorderDisable => 'Tylko do odczytu (ukryj uchwyty)';

  @override
  String get allowMoveReorderEnable => 'Włącz edytowanie (pokaż uchwyty)';

  @override
  String bookmarkCount(int count, int folders) {
    return '$count zakładek w $folders folderach';
  }

  @override
  String get syncNow => 'Synchronizuj teraz';

  @override
  String get addBookmark => 'Dodaj zakładkę';

  @override
  String get addBookmarkTitle => 'Dodaj zakładkę';

  @override
  String get bookmarkTitle => 'Tytuł zakładki';

  @override
  String get selectFolder => 'Wybierz folder';

  @override
  String get exportBookmarks => 'Eksportuj zakładki';

  @override
  String get settingsSyncToGit =>
      'Synchronizuj ustawienia z Git (zaszyfrowane)';

  @override
  String get settingsSyncPassword => 'Hasło szyfrowania';

  @override
  String get settingsSyncPasswordHint =>
      'Ustaw raz na urządzenie. Musi być takie samo na wszystkich urządzeniach.';

  @override
  String get settingsSyncRememberPassword => 'Zapamiętaj hasło';

  @override
  String get settingsSyncPasswordSaved =>
      'Hasło zapisane (używane do Push/Pull)';

  @override
  String get settingsSyncClearPassword => 'Wyczyść zapisane hasło';

  @override
  String get settingsSyncSaveBtn => 'Zapisz hasło';

  @override
  String get settingsSyncPasswordMissing => 'Wprowadź hasło.';

  @override
  String get settingsSyncWithBookmarks =>
      'Synchronizuj ustawienia podczas synchronizacji zakładek';

  @override
  String get settingsSyncPush => 'Wyślij ustawienia';

  @override
  String get settingsSyncPull => 'Pobierz ustawienia';

  @override
  String get settingsSyncModeLabel =>
      'Tryb synchronizacji (tylko indywidualny)';

  @override
  String get settingsSyncModeGlobal =>
      'Globalny — wspólny dla wszystkich urządzeń (legacy, zmigrowany)';

  @override
  String get settingsSyncModeIndividual => 'Indywidualny — tylko to urządzenie';

  @override
  String get settingsSyncImportTitle => 'Importuj z innego urządzenia';

  @override
  String get settingsSyncLoadConfigs => 'Załaduj dostępne konfiguracje';

  @override
  String get settingsSyncImport => 'Importuj';

  @override
  String get settingsSyncImportEmpty => 'Nie znaleziono konfiguracji urządzeń';

  @override
  String get settingsSyncImportSuccess => 'Ustawienia zaimportowane pomyślnie';

  @override
  String get reportIssue => 'Zgłoś problem';

  @override
  String get documentation => 'Dokumentacja';

  @override
  String get voteBacklog => 'Zagłosuj na backlog';

  @override
  String get discussions => 'Dyskusje';

  @override
  String get moveUp => 'Przenieś w górę';

  @override
  String get moveDown => 'Przenieś w dół';

  @override
  String get shareLinkAddBookmark => 'Dodaj udostępniony link jako zakładkę';

  @override
  String get clearCache => 'Wyczyść pamięć podręczną';

  @override
  String get clearCacheDesc =>
      'Usuń zbuforowane dane zakładek. Synchronizacja uruchomi się automatycznie, jeśli GitHub jest skonfigurowany.';

  @override
  String get clearCacheSuccess => 'Pamięć podręczna wyczyszczona.';

  @override
  String get moveToFolder => 'Przenieś do folderu';

  @override
  String get moveToFolderSuccess => 'Zakładka przeniesiona';

  @override
  String get moveToFolderFailed => 'Nie udało się przenieść zakładki';

  @override
  String get deleteBookmark => 'Usuń zakładkę';

  @override
  String deleteBookmarkConfirm(String title) {
    return 'Usunąć zakładkę \"$title\"?';
  }

  @override
  String get bookmarkDeleted => 'Zakładka usunięta';

  @override
  String get orderUpdated => 'Kolejność zaktualizowana';

  @override
  String get rootFolder => 'Folder główny';

  @override
  String get rootFolderHelp =>
      'Wybierz folder, którego podfoldery stają się kartami. Domyślnie wyświetla wszystkie foldery najwyższego poziomu.';

  @override
  String get allFolders => 'Wszystkie foldery';

  @override
  String get selectRootFolder => 'Wybierz folder główny';

  @override
  String get exportPasswordTitle => 'Hasło eksportu';

  @override
  String get exportPasswordHint =>
      'Pozostaw puste dla niezaszyfrowanego eksportu';

  @override
  String get importPasswordTitle => 'Zaszyfrowany plik';

  @override
  String get importPasswordHint => 'Wprowadź hasło szyfrowania';

  @override
  String get importSettingsAction => 'Importuj ustawienia';

  @override
  String get importingSettings => 'Importowanie ustawień…';

  @override
  String get orImportExisting => 'lub importuj istniejące ustawienia';

  @override
  String get wrongPassword => 'Błędne hasło. Spróbuj ponownie.';

  @override
  String get showSecret => 'Pokaż sekret';

  @override
  String get hideSecret => 'Ukryj sekret';

  @override
  String get export_ => 'Eksportuj';

  @override
  String get resetAll => 'Zresetuj wszystkie dane';

  @override
  String get resetConfirmTitle => 'Zresetować aplikację?';

  @override
  String get resetConfirmMessage =>
      'Wszystkie profile, ustawienia i zbuforowane zakładki zostaną usunięte. Aplikacja wróci do stanu początkowego.';

  @override
  String get resetSuccess => 'Wszystkie dane zostały zresetowane';

  @override
  String get settingsSyncClientName => 'Nazwa klienta';

  @override
  String get settingsSyncClientNameHint => 'np. base-android lub laptop-linux';

  @override
  String get settingsSyncClientNameRequired =>
      'Wprowadź nazwę klienta dla trybu indywidualnego.';

  @override
  String get settingsSyncCreateBtn => 'Utwórz moje ustawienie klienta';

  @override
  String get generalLanguageTitle => 'Język';

  @override
  String get generalThemeTitle => 'Motyw';

  @override
  String get appLanguage => 'Język aplikacji';

  @override
  String get appTheme => 'Motyw aplikacji';

  @override
  String get appLanguageSystem => 'Domyślny systemowy';

  @override
  String get appThemeSystem => 'Domyślny systemowy';

  @override
  String get appThemeLight => 'Jasny';

  @override
  String get appThemeDark => 'Ciemny';

  @override
  String get appLanguageGerman => 'Niemiecki';

  @override
  String get appLanguageEnglish => 'Angielski';

  @override
  String get appLanguageSpanish => 'Hiszpański';

  @override
  String get appLanguageFrench => 'Francuski';

  @override
  String get basePathBrowse => 'Przeglądaj foldery';

  @override
  String get basePathBrowseTitle => 'Wybierz folder repozytorium';

  @override
  String get subTabFolders => 'Foldery';

  @override
  String get appLanguagePortugueseBrazil => 'Portugalski (Brazylia)';

  @override
  String get appLanguageItalian => 'Włoski';

  @override
  String get appLanguageJapanese => 'Japoński';

  @override
  String get appLanguageChineseSimplified => 'Chiński (uproszczony)';

  @override
  String get appLanguageKorean => 'Koreański';

  @override
  String get appLanguageRussian => 'Rosyjski';

  @override
  String get appLanguageTurkish => 'Turecki';

  @override
  String get appLanguagePolish => 'Polski';
}
