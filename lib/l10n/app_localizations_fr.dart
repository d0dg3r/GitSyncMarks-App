// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Marques GitSync';

  @override
  String get settings => 'Paramètres';

  @override
  String get about => 'À propos';

  @override
  String get help => 'Aide';

  @override
  String get noBookmarksYet => 'Aucun favori pour le moment';

  @override
  String get tapSyncToFetch =>
      'Appuyez sur Sync pour charger les favoris depuis GitHub';

  @override
  String get configureInSettings =>
      'Configurez la connexion GitHub dans Paramètres';

  @override
  String get sync => 'Synchroniser';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get error => 'Erreur';

  @override
  String get retry => 'Réessayer';

  @override
  String couldNotOpenUrl(Object url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String get couldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get pleaseFillTokenOwnerRepo =>
      'Veuillez remplir Token, Owner et Repo';

  @override
  String get settingsSaved => 'Paramètres enregistrés';

  @override
  String get connectionSuccessful => 'Connexion réussie';

  @override
  String get connectionFailed => 'Connexion échouée';

  @override
  String get syncComplete => 'Synchronisation terminée';

  @override
  String get syncFailed => 'Synchronisation échouée';

  @override
  String get githubConnection => 'Connexion GitHub';

  @override
  String get gitConnection => 'Connexion Git';

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
  String get personalAccessToken => 'Jeton d\'accès personnel (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. Créer dans: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => 'Propriétaire du dépôt';

  @override
  String get ownerHint => 'votre-username-github';

  @override
  String get repositoryName => 'Nom du dépôt';

  @override
  String get repoHint => 'mes-favoris';

  @override
  String get branch => 'Branche';

  @override
  String get branchHint => 'principal';

  @override
  String get basePath => 'Chemin de base';

  @override
  String get basePathHint => 'signets';

  @override
  String get displayedFolders => 'Dossiers affichés';

  @override
  String get displayedFoldersHelp =>
      'Disponible après Test Connection. Sélection vide = tous les dossiers. Au moins un sélectionné = uniquement ces dossiers.';

  @override
  String get save => 'Enregistrer';

  @override
  String get testConnection => 'Tester la connexion';

  @override
  String get syncBookmarks => 'Synchroniser les signets';

  @override
  String version(String appVersion) {
    return 'Version $appVersion';
  }

  @override
  String get authorBy => 'Par Joe Mild';

  @override
  String get aboutDescription =>
      'Application mobile pour GitSyncMarks – afficher les favoris de votre dépôt GitHub et les ouvrir dans le navigateur.';

  @override
  String get projects => 'Projets';

  @override
  String get formatFromGitSyncMarks =>
      'Le format des favoris provient de GitSyncMarks.';

  @override
  String get gitSyncMarksDesc =>
      'Basé sur GitSyncMarks – l\'extension de navigateur pour la synchronisation bidirectionnelle des favoris. Ce projet a été développé avec GitSyncMarks comme référence.';

  @override
  String get licenseMit => 'Licence: MIT';

  @override
  String get quickGuide => 'Guide rapide';

  @override
  String get help1Title => '1. Configurer le token';

  @override
  String get help1Body =>
      'Créez un GitHub Personal Access Token (PAT). Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. Créer dans: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. Connecter le dépôt';

  @override
  String get help2Body =>
      'Entrez Owner, nom du Repo et Branch dans Paramètres. Votre dépôt doit suivre le format GitSyncMarks : dossiers racine toolbar et other (comme créés par l’extension navigateur, ex. 2.7.x), chacun avec _order.json et un fichier JSON par favori.';

  @override
  String get help3Title => '3. Tester la connexion';

  @override
  String get help3Body =>
      'Cliquez sur \"Test Connection\" pour vérifier le token et l\'accès au dépôt. En cas de succès, les dossiers racine disponibles sont affichés.';

  @override
  String get help4Title => '4. Sélectionner les dossiers';

  @override
  String get help4Body =>
      'Choisissez les dossiers racine à afficher (ex. toolbar, other). Sélection vide = tous. Au moins un sélectionné = uniquement ces dossiers.';

  @override
  String get help5Title => '5. Synchronisation';

  @override
  String get help5Body =>
      'Cliquez sur \"Sync Bookmarks\" pour charger les favoris. Pull-to-refresh sur l\'écran principal recharge.';

  @override
  String get whichRepoFormat => 'Quel format de dépôt ?';

  @override
  String get repoFormatDescription =>
      'Le dépôt doit suivre le format GitSyncMarks : Base Path (ex. \"bookmarks\") avec les sous-dossiers toolbar et other (l’extension ne synchronise pas menu ni mobile en racine). Chaque dossier a _order.json et des JSON par favori (title, url). Compatible avec l’extension GitSyncMarks (ex. 2.7.x).';

  @override
  String get support => 'Soutien';

  @override
  String get supportText =>
      'Questions ou messages d\'erreur ? Ouvrez une issue dans le dépôt du projet.';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (problèmes GitHub)';

  @override
  String get profiles => 'Profils';

  @override
  String get profile => 'Profil';

  @override
  String get activeProfile => 'Profil actif';

  @override
  String get addProfile => 'Ajouter un profil';

  @override
  String get renameProfile => 'Renommer le profil';

  @override
  String get deleteProfile => 'Supprimer le profil';

  @override
  String deleteProfileConfirm(String name) {
    return 'Supprimer le profil \"$name\" ?';
  }

  @override
  String get profileName => 'Nom du profil';

  @override
  String profileCount(int count, int max) {
    return '$count/$max profils';
  }

  @override
  String maxProfilesReached(int max) {
    return 'Nombre maximum de profils atteint ($max)';
  }

  @override
  String profileAdded(String name) {
    return 'Profil \"$name\" ajouté';
  }

  @override
  String profileRenamed(String name) {
    return 'Profil renommé en \"$name\"';
  }

  @override
  String get profileDeleted => 'Profil supprimé';

  @override
  String get cannotDeleteLastProfile =>
      'Impossible de supprimer le dernier profil';

  @override
  String get importExport => 'Importer / Exporter';

  @override
  String get importSettings => 'Importer les paramètres';

  @override
  String get exportSettings => 'Exporter les paramètres';

  @override
  String get importSettingsDesc =>
      'Importer des profils depuis un fichier de paramètres GitSyncMarks (JSON)';

  @override
  String get exportSettingsDesc =>
      'Exporter tous les profils en fichier de paramètres GitSyncMarks';

  @override
  String importSuccess(int count) {
    return '$count profil(s) importé(s)';
  }

  @override
  String importFailed(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String importConfirm(int count) {
    return 'Importer $count profil(s) ? Tous les profils existants seront remplacés.';
  }

  @override
  String get exportSuccess => 'Paramètres exportés';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get rename => 'Renommer';

  @override
  String get add => 'Ajouter';

  @override
  String get import_ => 'Importer';

  @override
  String get replace => 'Remplacer';

  @override
  String get bookmarks => 'Favoris';

  @override
  String get info => 'Informations';

  @override
  String get connection => 'Connexion';

  @override
  String get folders => 'Dossiers';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => 'Synchroniser';

  @override
  String get tabFiles => 'Fichiers';

  @override
  String get tabGeneral => 'Général';

  @override
  String get tabHelp => 'Aide';

  @override
  String get tabAbout => 'À propos';

  @override
  String get subTabProfile => 'Profil';

  @override
  String get subTabConnection => 'Connexion';

  @override
  String get subTabExportImport => 'Exporter / Importer';

  @override
  String get subTabSettings => 'Paramètres';

  @override
  String get searchPlaceholder => 'Rechercher des favoris...';

  @override
  String noSearchResults(String query) {
    return 'Aucun résultat pour \"$query\"';
  }

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get automaticSync => 'Synchronisation automatique';

  @override
  String get autoSyncActive => 'Auto-sync actif';

  @override
  String get autoSyncDisabled => 'Auto-sync désactivé';

  @override
  String nextSyncIn(String time) {
    return 'Prochaine sync dans $time';
  }

  @override
  String get syncProfileRealtime => 'Temps réel';

  @override
  String get syncProfileFrequent => 'Fréquent';

  @override
  String get syncProfileNormal => 'Normale';

  @override
  String get syncProfilePowersave => 'Économie d\'énergie';

  @override
  String get syncProfileCustom => 'Personnalisé';

  @override
  String get syncProfileMeaningTitle => 'Signification des profils :';

  @override
  String get syncProfileMeaningRealtime =>
      'Temps réel : synchronise chaque minute (fraîcheur maximale, batterie plus sollicitée).';

  @override
  String get syncProfileMeaningFrequent =>
      'Fréquent : synchronise toutes les 5 minutes (équilibré pour un usage actif).';

  @override
  String get syncProfileMeaningNormal =>
      'Normal : synchronise toutes les 15 minutes (valeur recommandée).';

  @override
  String get syncProfileMeaningPowersave =>
      'Économie d\'énergie : synchronise toutes les 60 minutes (batterie/réseau minimaux).';

  @override
  String get syncProfileMeaningCustom =>
      'Personnalisé : choisis ton propre intervalle en minutes.';

  @override
  String get customSyncIntervalLabel =>
      'Intervalle de sync personnalisé (minutes)';

  @override
  String get customSyncIntervalHint => 'Saisis une valeur entre 1 et 1440';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return 'Saisis un intervalle valide entre $min et $max minutes.';
  }

  @override
  String get syncCommit => 'Commettre';

  @override
  String lastSynced(String time) {
    return 'Dernière synchronisation $time';
  }

  @override
  String get neverSynced => 'Jamais synchronisé';

  @override
  String get syncOnStart => 'Sync au démarrage de l\'app';

  @override
  String get allowMoveReorder => 'Autoriser déplacer et réordonner';

  @override
  String get allowMoveReorderDesc =>
      'Poignées de glissement et déplacer vers dossier. Désactiver pour vue lecture seule.';

  @override
  String get allowMoveReorderDisable => 'Lecture seule (masquer les poignées)';

  @override
  String get allowMoveReorderEnable =>
      'Activer l\'édition (afficher les poignées)';

  @override
  String bookmarkCount(int count, int folders) {
    return '$count favoris dans $folders dossiers';
  }

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get addBookmark => 'Ajouter un favori';

  @override
  String get addBookmarkTitle => 'Ajouter un favori';

  @override
  String get bookmarkTitle => 'Titre du favori';

  @override
  String get selectFolder => 'Sélectionner le dossier';

  @override
  String get exportBookmarks => 'Exporter les favoris';

  @override
  String get settingsSyncToGit =>
      'Synchroniser les paramètres vers Git (chiffré)';

  @override
  String get settingsSyncPassword => 'Mot de passe de chiffrement';

  @override
  String get settingsSyncPasswordHint =>
      'Définir une fois par appareil. Doit être identique sur tous les appareils.';

  @override
  String get settingsSyncRememberPassword => 'Mémoriser le mot de passe';

  @override
  String get settingsSyncPasswordSaved =>
      'Mot de passe enregistré (pour Push/Pull)';

  @override
  String get settingsSyncClearPassword => 'Effacer le mot de passe enregistré';

  @override
  String get settingsSyncSaveBtn => 'Enregistrer le mot de passe';

  @override
  String get settingsSyncPasswordMissing => 'Veuillez entrer un mot de passe.';

  @override
  String get settingsSyncWithBookmarks =>
      'Synchroniser les paramètres avec les favoris';

  @override
  String get settingsSyncPush => 'Pousser les paramètres';

  @override
  String get settingsSyncPull => 'Récupérer les paramètres';

  @override
  String get settingsSyncModeLabel =>
      'Mode de synchronisation (individuel uniquement)';

  @override
  String get settingsSyncModeGlobal =>
      'Global — partagé sur tous les appareils (legacy, migré)';

  @override
  String get settingsSyncModeIndividual =>
      'Individuel — cet appareil uniquement';

  @override
  String get settingsSyncImportTitle => 'Importer depuis un autre appareil';

  @override
  String get settingsSyncLoadConfigs =>
      'Charger les configurations disponibles';

  @override
  String get settingsSyncImport => 'Importer';

  @override
  String get settingsSyncImportEmpty =>
      'Aucune configuration d\'appareil trouvée';

  @override
  String get settingsSyncImportSuccess => 'Paramètres importés avec succès';

  @override
  String get reportIssue => 'Signaler un problème';

  @override
  String get documentation => 'Documentation';

  @override
  String get voteBacklog => 'Voter sur le backlog';

  @override
  String get discussions => 'Discussions';

  @override
  String get moveUp => 'Monter';

  @override
  String get moveDown => 'Descendre';

  @override
  String get shareLinkAddBookmark => 'Ajouter le lien partagé comme favori';

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get clearCacheDesc =>
      'Supprimer les données en cache. La synchronisation se lance automatiquement si GitHub est configuré.';

  @override
  String get clearCacheSuccess => 'Cache vidé.';

  @override
  String get moveToFolder => 'Déplacer vers le dossier';

  @override
  String get moveToFolderSuccess => 'Favori déplacé';

  @override
  String get moveToFolderFailed => 'Échec du déplacement du favori';

  @override
  String get deleteBookmark => 'Supprimer le favori';

  @override
  String deleteBookmarkConfirm(String title) {
    return 'Supprimer le favori \"$title\" ?';
  }

  @override
  String get bookmarkDeleted => 'Favori supprimé';

  @override
  String get orderUpdated => 'Ordre mis à jour';

  @override
  String get rootFolder => 'Dossier racine';

  @override
  String get rootFolderHelp =>
      'Sélectionnez un dossier dont les sous-dossiers deviennent les onglets. Par défaut, tous les dossiers de premier niveau sont affichés.';

  @override
  String get allFolders => 'Tous les dossiers';

  @override
  String get selectRootFolder => 'Sélectionner le dossier racine';

  @override
  String get exportPasswordTitle => 'Mot de passe d\'export';

  @override
  String get exportPasswordHint => 'Laisser vide pour un export non chiffré';

  @override
  String get importPasswordTitle => 'Fichier chiffré';

  @override
  String get importPasswordHint => 'Entrez le mot de passe de chiffrement';

  @override
  String get importSettingsAction => 'Importer les paramètres';

  @override
  String get importingSettings => 'Importation des paramètres…';

  @override
  String get orImportExisting => 'ou importer des paramètres existants';

  @override
  String get wrongPassword => 'Mot de passe incorrect. Veuillez réessayer.';

  @override
  String get showSecret => 'Afficher le secret';

  @override
  String get hideSecret => 'Masquer le secret';

  @override
  String get export_ => 'Exporter';

  @override
  String get resetAll => 'Réinitialiser toutes les données';

  @override
  String get resetConfirmTitle => 'Réinitialiser l\'application ?';

  @override
  String get resetConfirmMessage =>
      'Tous les profils, paramètres et favoris en cache seront supprimés. L\'application reviendra à son état initial.';

  @override
  String get resetSuccess => 'Toutes les données ont été réinitialisées';

  @override
  String get settingsSyncClientName => 'Nom du client';

  @override
  String get settingsSyncClientNameHint => 'ex. base-android ou laptop-linux';

  @override
  String get settingsSyncClientNameRequired =>
      'Veuillez saisir un nom de client pour le mode individuel.';

  @override
  String get settingsSyncCreateBtn => 'Creer mon parametre client';

  @override
  String get generalLanguageTitle => 'Langue';

  @override
  String get generalThemeTitle => 'Thème';

  @override
  String get appLanguage => 'Langue de l\'app';

  @override
  String get appTheme => 'Theme de l\'app';

  @override
  String get appLanguageSystem => 'Par defaut du systeme';

  @override
  String get appThemeSystem => 'Par defaut du systeme';

  @override
  String get appThemeLight => 'Clair';

  @override
  String get appThemeDark => 'Sombre';

  @override
  String get appLanguageGerman => 'Allemand';

  @override
  String get appLanguageEnglish => 'Anglais';

  @override
  String get appLanguageSpanish => 'espagnol';

  @override
  String get appLanguageFrench => 'Français';

  @override
  String get basePathBrowse => 'Parcourir les dossiers';

  @override
  String get basePathBrowseTitle => 'Selectionner un dossier du depot';

  @override
  String get subTabFolders => 'Dossiers';

  @override
  String get appLanguagePortugueseBrazil => 'Portugais (Brésil)';

  @override
  String get appLanguageItalian => 'Italien';

  @override
  String get appLanguageJapanese => 'Japonais';

  @override
  String get appLanguageChineseSimplified => 'Chinois (simplifié)';

  @override
  String get appLanguageKorean => 'Coréen';

  @override
  String get appLanguageRussian => 'Russe';

  @override
  String get appLanguageTurkish => 'Turc';

  @override
  String get appLanguagePolish => 'Polonais';
}
