// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => 'Настройки';

  @override
  String get about => 'О приложении';

  @override
  String get help => 'Справка';

  @override
  String get noBookmarksYet => 'Закладок пока нет';

  @override
  String get tapSyncToFetch =>
      'Нажмите «Синхронизировать», чтобы загрузить закладки с GitHub';

  @override
  String get configureInSettings =>
      'Настройте подключение к GitHub в Настройках';

  @override
  String get sync => 'Синхронизировать';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get error => 'Ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String couldNotOpenUrl(Object url) {
    return 'Не удалось открыть $url';
  }

  @override
  String get couldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get pleaseFillTokenOwnerRepo =>
      'Пожалуйста, заполните Token, Owner и Repo';

  @override
  String get settingsSaved => 'Настройки сохранены';

  @override
  String get connectionSuccessful => 'Подключение успешно';

  @override
  String get connectionFailed => 'Ошибка подключения';

  @override
  String get syncComplete => 'Синхронизация завершена';

  @override
  String get syncFailed => 'Синхронизация не удалась';

  @override
  String get githubConnection => 'Подключение к GitHub';

  @override
  String get gitConnection => 'Подключение к Git';

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
  String get personalAccessToken => 'Персональный токен доступа (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'Классический PAT: Область \'repo\'. Fine-grained: Contents Read. Создать в: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => 'Владелец репозитория';

  @override
  String get ownerHint => 'ваше-имя-пользователя-github';

  @override
  String get repositoryName => 'Название репозитория';

  @override
  String get repoHint => 'мои-закладки';

  @override
  String get branch => 'Ветка';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => 'Базовый путь';

  @override
  String get basePathHint => 'закладки';

  @override
  String get displayedFolders => 'Отображаемые папки';

  @override
  String get displayedFoldersHelp =>
      'Доступно после теста подключения. Пустой выбор = все папки. Хотя бы одна выбрана = только эти папки.';

  @override
  String get save => 'Сохранить';

  @override
  String get testConnection => 'Проверить подключение';

  @override
  String get syncBookmarks => 'Синхронизировать закладки';

  @override
  String version(String appVersion) {
    return 'Версия $appVersion';
  }

  @override
  String get authorBy => 'Автор: Joe Mild';

  @override
  String get aboutDescription =>
      'Мобильное приложение для GitSyncMarks – просматривайте закладки из вашего репозитория GitHub и открывайте их в браузере.';

  @override
  String get projects => 'Проекты';

  @override
  String get formatFromGitSyncMarks => 'Формат закладок взят из GitSyncMarks.';

  @override
  String get gitSyncMarksDesc =>
      'Основано на GitSyncMarks – браузерном расширении для двунаправленной синхронизации закладок. Этот проект был разработан с использованием GitSyncMarks в качестве справочника.';

  @override
  String get licenseMit => 'Лицензия: MIT';

  @override
  String get quickGuide => 'Краткое руководство';

  @override
  String get help1Title => '1. Настройте токен';

  @override
  String get help1Body =>
      'Создайте GitHub Personal Access Token (PAT). Классический PAT: Область \'repo\'. Fine-grained: Contents Read. Создать в: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. Подключите репозиторий';

  @override
  String get help2Body =>
      'Введите Owner, имя Repo и Branch в Настройках. Репозиторий должен соответствовать GitSyncMarks: корневые папки toolbar и other (как создаёт расширение, напр. 2.7.x), в каждой — _order.json и JSON на закладку.';

  @override
  String get help3Title => '3. Проверьте подключение';

  @override
  String get help3Body =>
      'Нажмите «Test Connection» для проверки токена и доступа к репозиторию. В случае успеха отображаются доступные корневые папки.';

  @override
  String get help4Title => '4. Выберите папки';

  @override
  String get help4Body =>
      'Выберите, какие корневые папки отображать (например, toolbar, other). Пустой выбор = все. Хотя бы одна выбрана = только эти папки.';

  @override
  String get help5Title => '5. Синхронизируйте';

  @override
  String get help5Body =>
      'Нажмите «Sync Bookmarks» для загрузки закладок. Потяните для обновления на главном экране.';

  @override
  String get whichRepoFormat => 'Какой формат репозитория?';

  @override
  String get repoFormatDescription =>
      'Репозиторий в формате GitSyncMarks: Base Path (например, \"bookmarks\") с подпапками toolbar и other (расширение не синхронизирует menu/mobile как корни). В папке — _order.json и JSON с title и url. Совместимо с GitSyncMarks 2.7.x.';

  @override
  String get support => 'Поддержка';

  @override
  String get supportText =>
      'Вопросы или сообщения об ошибках? Откройте issue в репозитории проекта.';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (GitHub Issues)';

  @override
  String get profiles => 'Профили';

  @override
  String get profile => 'Профиль';

  @override
  String get activeProfile => 'Активный профиль';

  @override
  String get addProfile => 'Добавить профиль';

  @override
  String get renameProfile => 'Переименовать профиль';

  @override
  String get deleteProfile => 'Удалить профиль';

  @override
  String deleteProfileConfirm(String name) {
    return 'Удалить профиль «$name»?';
  }

  @override
  String get profileName => 'Название профиля';

  @override
  String profileCount(int count, int max) {
    return '$count/$max профилей';
  }

  @override
  String maxProfilesReached(int max) {
    return 'Достигнуто максимальное количество профилей ($max)';
  }

  @override
  String profileAdded(String name) {
    return 'Профиль «$name» добавлен';
  }

  @override
  String profileRenamed(String name) {
    return 'Профиль переименован в «$name»';
  }

  @override
  String get profileDeleted => 'Профиль удалён';

  @override
  String get cannotDeleteLastProfile => 'Нельзя удалить последний профиль';

  @override
  String get importExport => 'Импорт / Экспорт';

  @override
  String get importSettings => 'Импорт настроек';

  @override
  String get exportSettings => 'Экспорт настроек';

  @override
  String get importSettingsDesc =>
      'Импортировать профили из файла настроек GitSyncMarks (JSON)';

  @override
  String get exportSettingsDesc =>
      'Экспортировать все профили как файл настроек GitSyncMarks';

  @override
  String importSuccess(int count) {
    return 'Импортировано $count профиль(ей)';
  }

  @override
  String importFailed(String error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String importConfirm(int count) {
    return 'Импортировать $count профиль(ей)? Все существующие профили будут заменены.';
  }

  @override
  String get exportSuccess => 'Настройки экспортированы';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get rename => 'Переименовать';

  @override
  String get add => 'Добавить';

  @override
  String get import_ => 'Импорт';

  @override
  String get replace => 'Заменить';

  @override
  String get bookmarks => 'Закладки';

  @override
  String get info => 'Информация';

  @override
  String get connection => 'Подключение';

  @override
  String get folders => 'Папки';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => 'Синхронизация';

  @override
  String get tabFiles => 'Файлы';

  @override
  String get tabGeneral => 'Общие';

  @override
  String get tabHelp => 'Справка';

  @override
  String get tabAbout => 'О приложении';

  @override
  String get subTabProfile => 'Профиль';

  @override
  String get subTabConnection => 'Подключение';

  @override
  String get subTabExportImport => 'Экспорт / Импорт';

  @override
  String get subTabSettings => 'Настройки';

  @override
  String get searchPlaceholder => 'Поиск закладок...';

  @override
  String noSearchResults(String query) {
    return 'Нет результатов для «$query»';
  }

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get automaticSync => 'Автоматическая синхронизация';

  @override
  String get autoSyncActive => 'Автосинхронизация активна';

  @override
  String get autoSyncDisabled => 'Автосинхронизация отключена';

  @override
  String nextSyncIn(String time) {
    return 'Следующая синхронизация через $time';
  }

  @override
  String get syncProfileRealtime => 'Реальное время';

  @override
  String get syncProfileFrequent => 'Частая';

  @override
  String get syncProfileNormal => 'Нормальная';

  @override
  String get syncProfilePowersave => 'Экономия энергии';

  @override
  String get syncProfileCustom => 'Пользовательская';

  @override
  String get syncProfileMeaningTitle => 'Что означают эти профили:';

  @override
  String get syncProfileMeaningRealtime =>
      'Реальное время: синхронизация каждую минуту (максимальная актуальность, повышенный расход батареи).';

  @override
  String get syncProfileMeaningFrequent =>
      'Частая: синхронизация каждые 5 минут (сбалансированно для активного использования).';

  @override
  String get syncProfileMeaningNormal =>
      'Нормальная: синхронизация каждые 15 минут (рекомендуемый режим по умолчанию).';

  @override
  String get syncProfileMeaningPowersave =>
      'Экономия энергии: синхронизация каждые 60 минут (минимальный расход батареи/сети).';

  @override
  String get syncProfileMeaningCustom =>
      'Пользовательская: выберите собственный интервал в минутах.';

  @override
  String get customSyncIntervalLabel =>
      'Пользовательский интервал синхронизации (минуты)';

  @override
  String get customSyncIntervalHint => 'Введите значение от 1 до 1440';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return 'Введите корректный интервал от $min до $max минут.';
  }

  @override
  String get syncCommit => 'Коммит';

  @override
  String lastSynced(String time) {
    return 'Последняя синхронизация $time';
  }

  @override
  String get neverSynced => 'Никогда не синхронизировалось';

  @override
  String get syncOnStart => 'Синхронизировать при запуске';

  @override
  String get allowMoveReorder => 'Разрешить перемещение и изменение порядка';

  @override
  String get allowMoveReorderDesc =>
      'Ручки перетаскивания и перемещение в папку. Отключите для режима только чтение.';

  @override
  String get allowMoveReorderDisable => 'Только чтение (скрыть ручки)';

  @override
  String get allowMoveReorderEnable =>
      'Включить редактирование (показать ручки)';

  @override
  String bookmarkCount(int count, int folders) {
    return '$count закладок в $folders папках';
  }

  @override
  String get syncNow => 'Синхронизировать сейчас';

  @override
  String get addBookmark => 'Добавить закладку';

  @override
  String get addBookmarkTitle => 'Добавить закладку';

  @override
  String get bookmarkTitle => 'Название закладки';

  @override
  String get selectFolder => 'Выбрать папку';

  @override
  String get exportBookmarks => 'Экспортировать закладки';

  @override
  String get settingsSyncToGit =>
      'Синхронизировать настройки с Git (зашифровано)';

  @override
  String get settingsSyncPassword => 'Пароль шифрования';

  @override
  String get settingsSyncPasswordHint =>
      'Установить один раз для устройства. Должен быть одинаковым на всех устройствах.';

  @override
  String get settingsSyncRememberPassword => 'Запомнить пароль';

  @override
  String get settingsSyncPasswordSaved =>
      'Пароль сохранён (используется для Push/Pull)';

  @override
  String get settingsSyncClearPassword => 'Очистить сохранённый пароль';

  @override
  String get settingsSyncSaveBtn => 'Сохранить пароль';

  @override
  String get settingsSyncPasswordMissing => 'Пожалуйста, введите пароль.';

  @override
  String get settingsSyncWithBookmarks =>
      'Синхронизировать настройки при синхронизации закладок';

  @override
  String get settingsSyncPush => 'Загрузить настройки';

  @override
  String get settingsSyncPull => 'Скачать настройки';

  @override
  String get settingsSyncModeLabel =>
      'Режим синхронизации (только индивидуальный)';

  @override
  String get settingsSyncModeGlobal =>
      'Глобальный — общий для всех устройств (legacy, мигрировано)';

  @override
  String get settingsSyncModeIndividual =>
      'Индивидуальный — только это устройство';

  @override
  String get settingsSyncImportTitle => 'Импорт с другого устройства';

  @override
  String get settingsSyncLoadConfigs => 'Загрузить доступные конфигурации';

  @override
  String get settingsSyncImport => 'Импорт';

  @override
  String get settingsSyncImportEmpty => 'Конфигурации устройств не найдены';

  @override
  String get settingsSyncImportSuccess => 'Настройки успешно импортированы';

  @override
  String get reportIssue => 'Сообщить о проблеме';

  @override
  String get documentation => 'Документация';

  @override
  String get voteBacklog => 'Проголосовать за бэклог';

  @override
  String get discussions => 'Обсуждения';

  @override
  String get moveUp => 'Переместить вверх';

  @override
  String get moveDown => 'Переместить вниз';

  @override
  String get shareLinkAddBookmark => 'Добавить общую ссылку как закладку';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get clearCacheDesc =>
      'Удалить кэшированные данные закладок. Синхронизация запустится автоматически, если GitHub настроен.';

  @override
  String get clearCacheSuccess => 'Кэш очищен.';

  @override
  String get moveToFolder => 'Переместить в папку';

  @override
  String get moveToFolderSuccess => 'Закладка перемещена';

  @override
  String get moveToFolderFailed => 'Не удалось переместить закладку';

  @override
  String get deleteBookmark => 'Удалить закладку';

  @override
  String deleteBookmarkConfirm(String title) {
    return 'Удалить закладку «$title»?';
  }

  @override
  String get bookmarkDeleted => 'Закладка удалена';

  @override
  String get orderUpdated => 'Порядок обновлён';

  @override
  String get rootFolder => 'Корневая папка';

  @override
  String get rootFolderHelp =>
      'Выберите папку, подпапки которой станут вкладками. По умолчанию отображаются все папки верхнего уровня.';

  @override
  String get allFolders => 'Все папки';

  @override
  String get selectRootFolder => 'Выбрать корневую папку';

  @override
  String get exportPasswordTitle => 'Пароль экспорта';

  @override
  String get exportPasswordHint =>
      'Оставьте пустым для незашифрованного экспорта';

  @override
  String get importPasswordTitle => 'Зашифрованный файл';

  @override
  String get importPasswordHint => 'Введите пароль шифрования';

  @override
  String get importSettingsAction => 'Импорт настроек';

  @override
  String get importingSettings => 'Импортирование настроек…';

  @override
  String get orImportExisting => 'или импортировать существующие настройки';

  @override
  String get wrongPassword => 'Неверный пароль. Пожалуйста, попробуйте снова.';

  @override
  String get showSecret => 'Показать секрет';

  @override
  String get hideSecret => 'Скрыть секрет';

  @override
  String get export_ => 'Экспорт';

  @override
  String get resetAll => 'Сбросить все данные';

  @override
  String get resetConfirmTitle => 'Сбросить приложение?';

  @override
  String get resetConfirmMessage =>
      'Все профили, настройки и кэшированные закладки будут удалены. Приложение вернётся в исходное состояние.';

  @override
  String get resetSuccess => 'Все данные сброшены';

  @override
  String get settingsSyncClientName => 'Имя клиента';

  @override
  String get settingsSyncClientNameHint =>
      'например, base-android или laptop-linux';

  @override
  String get settingsSyncClientNameRequired =>
      'Пожалуйста, введите имя клиента для индивидуального режима.';

  @override
  String get settingsSyncCreateBtn => 'Создать настройки моего клиента';

  @override
  String get generalLanguageTitle => 'Язык';

  @override
  String get generalThemeTitle => 'Тема';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get appTheme => 'Тема приложения';

  @override
  String get appLanguageSystem => 'Системный по умолчанию';

  @override
  String get appThemeSystem => 'Системный по умолчанию';

  @override
  String get appThemeLight => 'Светлая';

  @override
  String get appThemeDark => 'Тёмная';

  @override
  String get appLanguageGerman => 'Немецкий';

  @override
  String get appLanguageEnglish => 'Английский';

  @override
  String get appLanguageSpanish => 'Испанский';

  @override
  String get appLanguageFrench => 'Французский';

  @override
  String get basePathBrowse => 'Обзор папок';

  @override
  String get basePathBrowseTitle => 'Выбрать папку репозитория';

  @override
  String get subTabFolders => 'Папки';

  @override
  String get appLanguagePortugueseBrazil => 'Португальский (Бразилия)';

  @override
  String get appLanguageItalian => 'Итальянский';

  @override
  String get appLanguageJapanese => 'Японский';

  @override
  String get appLanguageChineseSimplified => 'Китайский (упрощённый)';

  @override
  String get appLanguageKorean => 'Корейский';

  @override
  String get appLanguageRussian => 'Русский';

  @override
  String get appLanguageTurkish => 'Турецкий';

  @override
  String get appLanguagePolish => 'Польский';
}
