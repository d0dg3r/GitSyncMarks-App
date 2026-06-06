// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => 'Impostazioni';

  @override
  String get about => 'Informazioni';

  @override
  String get help => 'Aiuto';

  @override
  String get noBookmarksYet => 'Nessun segnalibro ancora';

  @override
  String get tapSyncToFetch =>
      'Tocca Sincronizza per caricare i segnalibri da GitHub';

  @override
  String get configureInSettings =>
      'Configura la connessione GitHub nelle Impostazioni';

  @override
  String get sync => 'Sincronizza';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get error => 'Errore';

  @override
  String get retry => 'Riprova';

  @override
  String couldNotOpenUrl(Object url) {
    return 'Impossibile aprire $url';
  }

  @override
  String get couldNotOpenLink => 'Impossibile aprire il collegamento';

  @override
  String get pleaseFillTokenOwnerRepo => 'Compila Token, Owner e Repo';

  @override
  String get settingsSaved => 'Impostazioni salvate';

  @override
  String get connectionSuccessful => 'Connessione riuscita';

  @override
  String get connectionFailed => 'Connessione fallita';

  @override
  String get syncComplete => 'Sincronizzazione completata';

  @override
  String get syncFailed => 'Sincronizzazione fallita';

  @override
  String get githubConnection => 'Connessione GitHub';

  @override
  String get gitConnection => 'Connessione Git';

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
  String get personalAccessToken => 'Token di accesso personale (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. Crea su: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => 'Proprietario del repository';

  @override
  String get ownerHint => 'tuo-username-github';

  @override
  String get repositoryName => 'Nome del repository';

  @override
  String get repoHint => 'miei-segnalibri';

  @override
  String get branch => 'Branch';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => 'Percorso base';

  @override
  String get basePathHint => 'segnalibri';

  @override
  String get displayedFolders => 'Cartelle mostrate';

  @override
  String get displayedFoldersHelp =>
      'Disponibile dopo Test Connection. Selezione vuota = tutte le cartelle. Almeno una selezionata = solo queste cartelle.';

  @override
  String get save => 'Salva';

  @override
  String get testConnection => 'Testa connessione';

  @override
  String get syncBookmarks => 'Sincronizza segnalibri';

  @override
  String version(String appVersion) {
    return 'Versione $appVersion';
  }

  @override
  String get authorBy => 'Di Joe Mild';

  @override
  String get aboutDescription =>
      'App mobile per GitSyncMarks – visualizza i segnalibri dal tuo repository GitHub e aprili nel browser.';

  @override
  String get projects => 'Progetti';

  @override
  String get formatFromGitSyncMarks =>
      'Il formato dei segnalibri proviene da GitSyncMarks.';

  @override
  String get gitSyncMarksDesc =>
      'Basato su GitSyncMarks – l\'estensione del browser per la sincronizzazione bidirezionale dei segnalibri. Questo progetto è stato sviluppato con GitSyncMarks come riferimento.';

  @override
  String get licenseMit => 'Licenza: MIT';

  @override
  String get quickGuide => 'Guida rapida';

  @override
  String get help1Title => '1. Configura il token';

  @override
  String get help1Body =>
      'Crea un GitHub Personal Access Token (PAT). Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. Crea su: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. Connetti il repository';

  @override
  String get help2Body =>
      'Inserisci Owner, nome del Repo e Branch nelle Impostazioni. Il repository deve seguire il formato GitSyncMarks: cartelle radice toolbar e other (come create dall’estensione del browser, es. 2.7.x), ciascuna con _order.json e un file JSON per segnalibro.';

  @override
  String get help3Title => '3. Testa la connessione';

  @override
  String get help3Body =>
      'Clicca su \"Test Connection\" per verificare token e accesso al repository. In caso di successo, vengono mostrate le cartelle radice disponibili.';

  @override
  String get help4Title => '4. Seleziona cartelle';

  @override
  String get help4Body =>
      'Scegli quali cartelle radice mostrare (es. toolbar, other). Selezione vuota = tutte. Almeno una selezionata = solo queste cartelle.';

  @override
  String get help5Title => '5. Sincronizza';

  @override
  String get help5Body =>
      'Clicca su \"Sync Bookmarks\" per caricare i segnalibri. Pull-to-refresh nella schermata principale ricarica.';

  @override
  String get whichRepoFormat => 'Quale formato di repository?';

  @override
  String get repoFormatDescription =>
      'Il repository deve seguire il formato GitSyncMarks: Base Path (es. \"bookmarks\") con sottocartelle toolbar e other (l’estensione non sincronizza menu o mobile come radici). Ogni cartella ha _order.json e file JSON per segnalibro con title e url. Compatibile con l’estensione GitSyncMarks (es. 2.7.x).';

  @override
  String get support => 'Supporto';

  @override
  String get supportText =>
      'Domande o messaggi di errore? Apri un issue nel repository del progetto.';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (GitHub Issues)';

  @override
  String get profiles => 'Profili';

  @override
  String get profile => 'Profilo';

  @override
  String get activeProfile => 'Profilo attivo';

  @override
  String get addProfile => 'Aggiungi profilo';

  @override
  String get renameProfile => 'Rinomina profilo';

  @override
  String get deleteProfile => 'Elimina profilo';

  @override
  String deleteProfileConfirm(String name) {
    return 'Eliminare il profilo \"$name\"?';
  }

  @override
  String get profileName => 'Nome profilo';

  @override
  String profileCount(int count, int max) {
    return '$count/$max profili';
  }

  @override
  String maxProfilesReached(int max) {
    return 'Numero massimo di profili raggiunto ($max)';
  }

  @override
  String profileAdded(String name) {
    return 'Profilo \"$name\" aggiunto';
  }

  @override
  String profileRenamed(String name) {
    return 'Profilo rinominato in \"$name\"';
  }

  @override
  String get profileDeleted => 'Profilo eliminato';

  @override
  String get cannotDeleteLastProfile =>
      'Impossibile eliminare l\'ultimo profilo';

  @override
  String get importExport => 'Importa / Esporta';

  @override
  String get importSettings => 'Importa impostazioni';

  @override
  String get exportSettings => 'Esporta impostazioni';

  @override
  String get importSettingsDesc =>
      'Importa profili da un file di impostazioni GitSyncMarks (JSON)';

  @override
  String get exportSettingsDesc =>
      'Esporta tutti i profili come file di impostazioni GitSyncMarks';

  @override
  String importSuccess(int count) {
    return '$count profilo/i importato/i';
  }

  @override
  String importFailed(String error) {
    return 'Importazione fallita: $error';
  }

  @override
  String importConfirm(int count) {
    return 'Importare $count profilo/i? Tutti i profili esistenti verranno sostituiti.';
  }

  @override
  String get exportSuccess => 'Impostazioni esportate';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get rename => 'Rinomina';

  @override
  String get add => 'Aggiungi';

  @override
  String get import_ => 'Importa';

  @override
  String get replace => 'Sostituisci';

  @override
  String get bookmarks => 'Segnalibri';

  @override
  String get info => 'Info';

  @override
  String get connection => 'Connessione';

  @override
  String get folders => 'Cartelle';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => 'Sincronizza';

  @override
  String get tabFiles => 'File';

  @override
  String get tabGeneral => 'Generale';

  @override
  String get tabHelp => 'Aiuto';

  @override
  String get tabAbout => 'Informazioni';

  @override
  String get subTabProfile => 'Profilo';

  @override
  String get subTabConnection => 'Connessione';

  @override
  String get subTabExportImport => 'Esporta / Importa';

  @override
  String get subTabSettings => 'Impostazioni';

  @override
  String get searchPlaceholder => 'Cerca segnalibri...';

  @override
  String noSearchResults(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get automaticSync => 'Sincronizzazione automatica';

  @override
  String get autoSyncActive => 'Sincronizzazione automatica attiva';

  @override
  String get autoSyncDisabled => 'Sincronizzazione automatica disattivata';

  @override
  String nextSyncIn(String time) {
    return 'Prossima sincronizzazione in $time';
  }

  @override
  String get syncProfileRealtime => 'Tempo reale';

  @override
  String get syncProfileFrequent => 'Frequente';

  @override
  String get syncProfileNormal => 'Normale';

  @override
  String get syncProfilePowersave => 'Risparmio energetico';

  @override
  String get syncProfileCustom => 'Personalizzato';

  @override
  String get syncProfileMeaningTitle => 'Cosa significano questi profili:';

  @override
  String get syncProfileMeaningRealtime =>
      'Tempo reale: sincronizza ogni minuto (massima freschezza, maggior consumo batteria).';

  @override
  String get syncProfileMeaningFrequent =>
      'Frequente: sincronizza ogni 5 minuti (bilanciato per uso attivo).';

  @override
  String get syncProfileMeaningNormal =>
      'Normale: sincronizza ogni 15 minuti (impostazione predefinita consigliata).';

  @override
  String get syncProfileMeaningPowersave =>
      'Risparmio energetico: sincronizza ogni 60 minuti (consumo batteria/rete minimo).';

  @override
  String get syncProfileMeaningCustom =>
      'Personalizzato: scegli il tuo intervallo in minuti.';

  @override
  String get customSyncIntervalLabel =>
      'Intervallo sync personalizzato (minuti)';

  @override
  String get customSyncIntervalHint => 'Inserisci un valore tra 1 e 1440';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return 'Inserisci un intervallo valido tra $min e $max minuti.';
  }

  @override
  String get syncCommit => 'Commit';

  @override
  String lastSynced(String time) {
    return 'Ultima sincronizzazione $time';
  }

  @override
  String get neverSynced => 'Mai sincronizzato';

  @override
  String get syncOnStart => 'Sincronizza all\'avvio dell\'app';

  @override
  String get allowMoveReorder => 'Consenti spostamento e riordinamento';

  @override
  String get allowMoveReorderDesc =>
      'Maniglie di trascinamento e sposta in cartella. Disabilita per vista sola lettura.';

  @override
  String get allowMoveReorderDisable => 'Sola lettura (nascondi maniglie)';

  @override
  String get allowMoveReorderEnable => 'Abilita modifica (mostra maniglie)';

  @override
  String bookmarkCount(int count, int folders) {
    return '$count segnalibri in $folders cartelle';
  }

  @override
  String get syncNow => 'Sincronizza ora';

  @override
  String get addBookmark => 'Aggiungi segnalibro';

  @override
  String get addBookmarkTitle => 'Aggiungi segnalibro';

  @override
  String get bookmarkTitle => 'Titolo del segnalibro';

  @override
  String get selectFolder => 'Seleziona cartella';

  @override
  String get exportBookmarks => 'Esporta segnalibri';

  @override
  String get settingsSyncToGit =>
      'Sincronizza impostazioni su Git (crittografato)';

  @override
  String get settingsSyncPassword => 'Password di crittografia';

  @override
  String get settingsSyncPasswordHint =>
      'Impostata una volta per dispositivo. Deve essere la stessa su tutti i dispositivi.';

  @override
  String get settingsSyncRememberPassword => 'Ricorda password';

  @override
  String get settingsSyncPasswordSaved =>
      'Password salvata (usata per Push/Pull)';

  @override
  String get settingsSyncClearPassword => 'Cancella password salvata';

  @override
  String get settingsSyncSaveBtn => 'Salva password';

  @override
  String get settingsSyncPasswordMissing => 'Inserisci una password.';

  @override
  String get settingsSyncWithBookmarks =>
      'Sincronizza impostazioni con i segnalibri';

  @override
  String get settingsSyncPush => 'Carica impostazioni';

  @override
  String get settingsSyncPull => 'Scarica impostazioni';

  @override
  String get settingsSyncModeLabel => 'Modalità sync (solo individuale)';

  @override
  String get settingsSyncModeGlobal =>
      'Globale — condiviso su tutti i dispositivi (legacy, migrato)';

  @override
  String get settingsSyncModeIndividual =>
      'Individuale — solo questo dispositivo';

  @override
  String get settingsSyncImportTitle => 'Importa da un altro dispositivo';

  @override
  String get settingsSyncLoadConfigs => 'Carica configurazioni disponibili';

  @override
  String get settingsSyncImport => 'Importa';

  @override
  String get settingsSyncImportEmpty =>
      'Nessuna configurazione dispositivo trovata';

  @override
  String get settingsSyncImportSuccess => 'Impostazioni importate con successo';

  @override
  String get reportIssue => 'Segnala problema';

  @override
  String get documentation => 'Documentazione';

  @override
  String get voteBacklog => 'Vota il backlog';

  @override
  String get discussions => 'Discussioni';

  @override
  String get moveUp => 'Sposta su';

  @override
  String get moveDown => 'Sposta giù';

  @override
  String get shareLinkAddBookmark => 'Aggiungi link condiviso come segnalibro';

  @override
  String get clearCache => 'Svuota cache';

  @override
  String get clearCacheDesc =>
      'Rimuovi i dati dei segnalibri in cache. La sincronizzazione partirà automaticamente se GitHub è configurato.';

  @override
  String get clearCacheSuccess => 'Cache svuotata.';

  @override
  String get moveToFolder => 'Sposta in cartella';

  @override
  String get moveToFolderSuccess => 'Segnalibro spostato';

  @override
  String get moveToFolderFailed => 'Impossibile spostare il segnalibro';

  @override
  String get deleteBookmark => 'Elimina segnalibro';

  @override
  String deleteBookmarkConfirm(String title) {
    return 'Eliminare il segnalibro \"$title\"?';
  }

  @override
  String get bookmarkDeleted => 'Segnalibro eliminato';

  @override
  String get orderUpdated => 'Ordine aggiornato';

  @override
  String get rootFolder => 'Cartella radice';

  @override
  String get rootFolderHelp =>
      'Seleziona una cartella le cui sottocartelle diventano le schede. Per default mostra tutte le cartelle di primo livello.';

  @override
  String get allFolders => 'Tutte le cartelle';

  @override
  String get selectRootFolder => 'Seleziona cartella radice';

  @override
  String get exportPasswordTitle => 'Password di esportazione';

  @override
  String get exportPasswordHint =>
      'Lascia vuoto per esportazione non crittografata';

  @override
  String get importPasswordTitle => 'File crittografato';

  @override
  String get importPasswordHint => 'Inserisci la password di crittografia';

  @override
  String get importSettingsAction => 'Importa impostazioni';

  @override
  String get importingSettings => 'Importazione impostazioni in corso…';

  @override
  String get orImportExisting => 'o importa impostazioni esistenti';

  @override
  String get wrongPassword => 'Password errata. Riprova.';

  @override
  String get showSecret => 'Mostra segreto';

  @override
  String get hideSecret => 'Nascondi segreto';

  @override
  String get export_ => 'Esporta';

  @override
  String get resetAll => 'Reimposta tutti i dati';

  @override
  String get resetConfirmTitle => 'Reimpostare l\'app?';

  @override
  String get resetConfirmMessage =>
      'Tutti i profili, le impostazioni e i segnalibri in cache verranno eliminati. L\'app tornerà allo stato iniziale.';

  @override
  String get resetSuccess => 'Tutti i dati sono stati reimpostati';

  @override
  String get settingsSyncClientName => 'Nome client';

  @override
  String get settingsSyncClientNameHint => 'es. base-android o laptop-linux';

  @override
  String get settingsSyncClientNameRequired =>
      'Inserisci un nome client per la modalità individuale.';

  @override
  String get settingsSyncCreateBtn => 'Crea la mia impostazione client';

  @override
  String get generalLanguageTitle => 'Lingua';

  @override
  String get generalThemeTitle => 'Tema';

  @override
  String get appLanguage => 'Lingua app';

  @override
  String get appTheme => 'Tema app';

  @override
  String get appLanguageSystem => 'Predefinito di sistema';

  @override
  String get appThemeSystem => 'Predefinito di sistema';

  @override
  String get appThemeLight => 'Chiaro';

  @override
  String get appThemeDark => 'Scuro';

  @override
  String get appLanguageGerman => 'Tedesco';

  @override
  String get appLanguageEnglish => 'Inglese';

  @override
  String get appLanguageSpanish => 'Spagnolo';

  @override
  String get appLanguageFrench => 'Francese';

  @override
  String get basePathBrowse => 'Sfoglia cartelle';

  @override
  String get basePathBrowseTitle => 'Seleziona cartella del repository';

  @override
  String get subTabFolders => 'Cartelle';

  @override
  String get appLanguagePortugueseBrazil => 'Portoghese (Brasile)';

  @override
  String get appLanguageItalian => 'Italiano';

  @override
  String get appLanguageJapanese => 'Giapponese';

  @override
  String get appLanguageChineseSimplified => 'Cinese (semplificato)';

  @override
  String get appLanguageKorean => 'Coreano';

  @override
  String get appLanguageRussian => 'Russo';

  @override
  String get appLanguageTurkish => 'Turco';

  @override
  String get appLanguagePolish => 'Polacco';
}
