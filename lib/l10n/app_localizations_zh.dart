// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => '設定';

  @override
  String get about => '關於';

  @override
  String get help => '說明';

  @override
  String get noBookmarksYet => '尚無書籤';

  @override
  String get tapSyncToFetch => '點擊同步以從 GitHub 獲取書籤';

  @override
  String get configureInSettings => '請在設定中配置 GitHub 連線';

  @override
  String get sync => '同步';

  @override
  String get openSettings => '開啟設定';

  @override
  String get error => '錯誤';

  @override
  String get retry => '重試';

  @override
  String couldNotOpenUrl(Object url) {
    return '無法開啟 $url';
  }

  @override
  String get couldNotOpenLink => '無法開啟連結';

  @override
  String get pleaseFillTokenOwnerRepo => '請填寫 Token、Owner 和 Repo';

  @override
  String get settingsSaved => '設定已儲存';

  @override
  String get connectionSuccessful => '連線成功';

  @override
  String get connectionFailed => '連線失敗';

  @override
  String get syncComplete => '同步完成';

  @override
  String get syncFailed => '同步失敗';

  @override
  String get githubConnection => 'GitHub 連線';

  @override
  String get gitConnection => 'Git 連線';

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
  String get personalAccessToken => '個人存取權杖 (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'Classic PAT：範圍 \'repo\'。細粒度：Contents Read。建立位置：GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => '儲存庫擁有者';

  @override
  String get ownerHint => '您的-github-使用者名稱';

  @override
  String get repositoryName => '儲存庫名稱';

  @override
  String get repoHint => '我的書籤';

  @override
  String get branch => '分支';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => '基礎路徑';

  @override
  String get basePathHint => 'bookmarks';

  @override
  String get displayedFolders => '顯示的資料夾';

  @override
  String get displayedFoldersHelp => '測試連線後可用。空選擇 = 所有資料夾。至少選一個 = 僅這些資料夾。';

  @override
  String get save => '儲存';

  @override
  String get testConnection => '測試連線';

  @override
  String get syncBookmarks => '同步書籤';

  @override
  String version(String appVersion) {
    return '版本 $appVersion';
  }

  @override
  String get authorBy => '作者：Joe Mild';

  @override
  String get aboutDescription =>
      'GitSyncMarks 的行動應用程式 – 檢視您 GitHub 儲存庫中的書籤並在瀏覽器中開啟。';

  @override
  String get projects => '專案';

  @override
  String get formatFromGitSyncMarks => '書籤格式來自 GitSyncMarks。';

  @override
  String get gitSyncMarksDesc =>
      '基於 GitSyncMarks – 雙向書籤同步的瀏覽器擴充套件。本專案以 GitSyncMarks 為參考開發。';

  @override
  String get licenseMit => '授權：MIT';

  @override
  String get quickGuide => '快速指南';

  @override
  String get help1Title => '1. 設定權杖';

  @override
  String get help1Body =>
      '建立一個 GitHub Personal Access Token (PAT)。Classic PAT：範圍 \'repo\'。細粒度：Contents Read。建立位置：GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. 連接儲存庫';

  @override
  String get help2Body =>
      '在設定中輸入 Owner、Repo 名稱和 Branch。儲存庫應符合 GitSyncMarks 格式：根資料夾 toolbar 與 other（由瀏覽器擴充功能建立，例如 2.7.x），各含 _order.json 與每則書籤一個 JSON 檔。';

  @override
  String get help3Title => '3. 測試連線';

  @override
  String get help3Body => '按一下「Test Connection」以驗證權杖和儲存庫存取權限。成功後顯示可用的根資料夾。';

  @override
  String get help4Title => '4. 選擇資料夾';

  @override
  String get help4Body =>
      '選擇要顯示的根資料夾（如 toolbar、other）。空選擇 = 全部。至少選一個 = 僅這些資料夾。';

  @override
  String get help5Title => '5. 同步';

  @override
  String get help5Body => '按一下「Sync Bookmarks」載入書籤。在主畫面下拉重新整理。';

  @override
  String get whichRepoFormat => '使用哪種儲存庫格式？';

  @override
  String get repoFormatDescription =>
      '儲存庫應符合 GitSyncMarks 格式：Base Path（如「bookmarks」）下為子資料夾 toolbar 與 other（擴充功能不同步 menu/mobile 作為根）。每個資料夾有 _order.json 與書籤 JSON（title、url）。與 GitSyncMarks 瀏覽器擴充功能（例如 2.7.x）相容。';

  @override
  String get support => '支援';

  @override
  String get supportText => '有問題或錯誤訊息？請在專案儲存庫中提交 issue。';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (GitHub Issues)';

  @override
  String get profiles => '設定檔';

  @override
  String get profile => '設定檔';

  @override
  String get activeProfile => '目前設定檔';

  @override
  String get addProfile => '新增設定檔';

  @override
  String get renameProfile => '重新命名設定檔';

  @override
  String get deleteProfile => '刪除設定檔';

  @override
  String deleteProfileConfirm(String name) {
    return '刪除設定檔「$name」？';
  }

  @override
  String get profileName => '設定檔名稱';

  @override
  String profileCount(int count, int max) {
    return '$count/$max 個設定檔';
  }

  @override
  String maxProfilesReached(int max) {
    return '已達到設定檔的最大數量（$max）';
  }

  @override
  String profileAdded(String name) {
    return '設定檔「$name」已新增';
  }

  @override
  String profileRenamed(String name) {
    return '設定檔已重新命名為「$name」';
  }

  @override
  String get profileDeleted => '設定檔已刪除';

  @override
  String get cannotDeleteLastProfile => '無法刪除最後一個設定檔';

  @override
  String get importExport => '匯入 / 匯出';

  @override
  String get importSettings => '匯入設定';

  @override
  String get exportSettings => '匯出設定';

  @override
  String get importSettingsDesc => '從 GitSyncMarks 設定檔 (JSON) 匯入設定檔';

  @override
  String get exportSettingsDesc => '將所有設定檔匯出為 GitSyncMarks 設定檔';

  @override
  String importSuccess(int count) {
    return '已匯入 $count 個設定檔';
  }

  @override
  String importFailed(String error) {
    return '匯入失敗：$error';
  }

  @override
  String importConfirm(int count) {
    return '匯入 $count 個設定檔？所有現有設定檔將被取代。';
  }

  @override
  String get exportSuccess => '設定已匯出';

  @override
  String get cancel => '取消';

  @override
  String get delete => '刪除';

  @override
  String get rename => '重新命名';

  @override
  String get add => '新增';

  @override
  String get import_ => '匯入';

  @override
  String get replace => '取代';

  @override
  String get bookmarks => '書籤';

  @override
  String get info => '資訊';

  @override
  String get connection => '連線';

  @override
  String get folders => '資料夾';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => '同步';

  @override
  String get tabFiles => '檔案';

  @override
  String get tabGeneral => '一般';

  @override
  String get tabHelp => '說明';

  @override
  String get tabAbout => '關於';

  @override
  String get subTabProfile => '設定檔';

  @override
  String get subTabConnection => '連線';

  @override
  String get subTabExportImport => '匯出 / 匯入';

  @override
  String get subTabSettings => '設定';

  @override
  String get searchPlaceholder => '搜尋書籤...';

  @override
  String noSearchResults(String query) {
    return '沒有「$query」的結果';
  }

  @override
  String get clearSearch => '清除搜尋';

  @override
  String get automaticSync => '自動同步';

  @override
  String get autoSyncActive => '自動同步已啟用';

  @override
  String get autoSyncDisabled => '自動同步已停用';

  @override
  String nextSyncIn(String time) {
    return '下次同步將在 $time 後';
  }

  @override
  String get syncProfileRealtime => '即時';

  @override
  String get syncProfileFrequent => '頻繁';

  @override
  String get syncProfileNormal => '正常';

  @override
  String get syncProfilePowersave => '省電';

  @override
  String get syncProfileCustom => '自訂';

  @override
  String get syncProfileMeaningTitle => '這些設定檔的意義：';

  @override
  String get syncProfileMeaningRealtime => '即時：每分鐘同步一次（最高時效性，較高電池消耗）。';

  @override
  String get syncProfileMeaningFrequent => '頻繁：每 5 分鐘同步一次（適合活躍使用的平衡）。';

  @override
  String get syncProfileMeaningNormal => '正常：每 15 分鐘同步一次（建議預設）。';

  @override
  String get syncProfileMeaningPowersave => '省電：每 60 分鐘同步一次（最低電池/網路消耗）。';

  @override
  String get syncProfileMeaningCustom => '自訂：以分鐘為單位設定自己的間隔。';

  @override
  String get customSyncIntervalLabel => '自訂同步間隔（分鐘）';

  @override
  String get customSyncIntervalHint => '輸入 1 到 1440 之間的值';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return '請輸入 $min 到 $max 分鐘之間的有效間隔。';
  }

  @override
  String get syncCommit => '提交';

  @override
  String lastSynced(String time) {
    return '上次同步 $time';
  }

  @override
  String get neverSynced => '從未同步';

  @override
  String get syncOnStart => '應用程式啟動時同步';

  @override
  String get allowMoveReorder => '允許移動和重新排序';

  @override
  String get allowMoveReorderDesc => '拖曳把手和移動到資料夾。停用以使用唯讀檢視。';

  @override
  String get allowMoveReorderDisable => '唯讀（隱藏把手）';

  @override
  String get allowMoveReorderEnable => '啟用編輯（顯示把手）';

  @override
  String bookmarkCount(int count, int folders) {
    return '$folders 個資料夾中有 $count 個書籤';
  }

  @override
  String get syncNow => '立即同步';

  @override
  String get addBookmark => '新增書籤';

  @override
  String get addBookmarkTitle => '新增書籤';

  @override
  String get bookmarkTitle => '書籤標題';

  @override
  String get selectFolder => '選擇資料夾';

  @override
  String get exportBookmarks => '匯出書籤';

  @override
  String get settingsSyncToGit => '將設定同步至 Git（加密）';

  @override
  String get settingsSyncPassword => '加密密碼';

  @override
  String get settingsSyncPasswordHint => '每台裝置設定一次。所有裝置上必須相同。';

  @override
  String get settingsSyncRememberPassword => '記住密碼';

  @override
  String get settingsSyncPasswordSaved => '密碼已儲存（用於 Push/Pull）';

  @override
  String get settingsSyncClearPassword => '清除已儲存的密碼';

  @override
  String get settingsSyncSaveBtn => '儲存密碼';

  @override
  String get settingsSyncPasswordMissing => '請輸入密碼。';

  @override
  String get settingsSyncWithBookmarks => '同步書籤時同步設定';

  @override
  String get settingsSyncPush => '推送設定';

  @override
  String get settingsSyncPull => '拉取設定';

  @override
  String get settingsSyncModeLabel => '同步模式（僅限個人）';

  @override
  String get settingsSyncModeGlobal => '全域 — 在所有裝置間共用（舊版，已移轉）';

  @override
  String get settingsSyncModeIndividual => '個人 — 僅此裝置';

  @override
  String get settingsSyncImportTitle => '從其他裝置匯入';

  @override
  String get settingsSyncLoadConfigs => '載入可用設定';

  @override
  String get settingsSyncImport => '匯入';

  @override
  String get settingsSyncImportEmpty => '找不到裝置設定';

  @override
  String get settingsSyncImportSuccess => '設定已成功匯入';

  @override
  String get reportIssue => '回報問題';

  @override
  String get documentation => '說明文件';

  @override
  String get voteBacklog => '對待辦事項投票';

  @override
  String get discussions => '討論';

  @override
  String get moveUp => '向上移動';

  @override
  String get moveDown => '向下移動';

  @override
  String get shareLinkAddBookmark => '將共用連結新增為書籤';

  @override
  String get clearCache => '清除快取';

  @override
  String get clearCacheDesc => '刪除快取的書籤資料。如果已設定 GitHub，同步將自動執行。';

  @override
  String get clearCacheSuccess => '快取已清除。';

  @override
  String get moveToFolder => '移動到資料夾';

  @override
  String get moveToFolderSuccess => '書籤已移動';

  @override
  String get moveToFolderFailed => '書籤移動失敗';

  @override
  String get deleteBookmark => '刪除書籤';

  @override
  String deleteBookmarkConfirm(String title) {
    return '刪除書籤「$title」？';
  }

  @override
  String get bookmarkDeleted => '書籤已刪除';

  @override
  String get orderUpdated => '順序已更新';

  @override
  String get rootFolder => '根資料夾';

  @override
  String get rootFolderHelp => '選擇一個資料夾，其子資料夾將成為索引標籤。預設顯示所有最上層資料夾。';

  @override
  String get allFolders => '所有資料夾';

  @override
  String get selectRootFolder => '選擇根資料夾';

  @override
  String get exportPasswordTitle => '匯出密碼';

  @override
  String get exportPasswordHint => '留空以進行未加密的匯出';

  @override
  String get importPasswordTitle => '加密檔案';

  @override
  String get importPasswordHint => '輸入加密密碼';

  @override
  String get importSettingsAction => '匯入設定';

  @override
  String get importingSettings => '正在匯入設定…';

  @override
  String get orImportExisting => '或匯入現有設定';

  @override
  String get wrongPassword => '密碼錯誤。請重試。';

  @override
  String get showSecret => '顯示密鑰';

  @override
  String get hideSecret => '隱藏密鑰';

  @override
  String get export_ => '匯出';

  @override
  String get resetAll => '重設所有資料';

  @override
  String get resetConfirmTitle => '重設應用程式？';

  @override
  String get resetConfirmMessage => '所有設定檔、設定和快取的書籤將被刪除。應用程式將恢復到初始狀態。';

  @override
  String get resetSuccess => '所有資料已重設';

  @override
  String get settingsSyncClientName => '用戶端名稱';

  @override
  String get settingsSyncClientNameHint => '例如 base-android 或 laptop-linux';

  @override
  String get settingsSyncClientNameRequired => '請輸入個人模式的用戶端名稱。';

  @override
  String get settingsSyncCreateBtn => '建立我的用戶端設定';

  @override
  String get generalLanguageTitle => '語言';

  @override
  String get generalThemeTitle => '主題';

  @override
  String get appLanguage => '應用程式語言';

  @override
  String get appTheme => '應用程式主題';

  @override
  String get appLanguageSystem => '系統預設';

  @override
  String get appThemeSystem => '系統預設';

  @override
  String get appThemeLight => '淺色';

  @override
  String get appThemeDark => '深色';

  @override
  String get appLanguageGerman => '德語';

  @override
  String get appLanguageEnglish => '英語';

  @override
  String get appLanguageSpanish => '西班牙語';

  @override
  String get appLanguageFrench => '法語';

  @override
  String get basePathBrowse => '瀏覽資料夾';

  @override
  String get basePathBrowseTitle => '選擇儲存庫資料夾';

  @override
  String get subTabFolders => '資料夾';

  @override
  String get appLanguagePortugueseBrazil => '葡萄牙語（巴西）';

  @override
  String get appLanguageItalian => '義大利語';

  @override
  String get appLanguageJapanese => '日語';

  @override
  String get appLanguageChineseSimplified => '中文（簡體）';

  @override
  String get appLanguageKorean => '韓語';

  @override
  String get appLanguageRussian => '俄語';

  @override
  String get appLanguageTurkish => '土耳其語';

  @override
  String get appLanguagePolish => '波蘭語';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get help => '帮助';

  @override
  String get noBookmarksYet => '暂无书签';

  @override
  String get tapSyncToFetch => '点击同步以从 GitHub 获取书签';

  @override
  String get configureInSettings => '在设置中配置 GitHub 连接';

  @override
  String get sync => '同步';

  @override
  String get openSettings => '打开设置';

  @override
  String get error => '错误';

  @override
  String get retry => '重试';

  @override
  String couldNotOpenUrl(Object url) {
    return '无法打开 $url';
  }

  @override
  String get couldNotOpenLink => '无法打开链接';

  @override
  String get pleaseFillTokenOwnerRepo => '请填写 Token、Owner 和 Repo';

  @override
  String get settingsSaved => '设置已保存';

  @override
  String get connectionSuccessful => '连接成功';

  @override
  String get connectionFailed => '连接失败';

  @override
  String get syncComplete => '同步完成';

  @override
  String get syncFailed => '同步失败';

  @override
  String get githubConnection => 'GitHub 连接';

  @override
  String get gitConnection => 'Git 连接';

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
  String get personalAccessToken => '个人访问令牌 (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      '经典 PAT：范围 \'repo\'。细粒度：Contents Read。创建位置：GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => '仓库所有者';

  @override
  String get ownerHint => '您的-github-用户名';

  @override
  String get repositoryName => '仓库名称';

  @override
  String get repoHint => '我的书签';

  @override
  String get branch => '分支';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => '基础路径';

  @override
  String get basePathHint => 'bookmarks';

  @override
  String get displayedFolders => '显示的文件夹';

  @override
  String get displayedFoldersHelp => '测试连接后可用。空选择 = 所有文件夹。至少选一个 = 仅这些文件夹。';

  @override
  String get save => '保存';

  @override
  String get testConnection => '测试连接';

  @override
  String get syncBookmarks => '同步书签';

  @override
  String version(String appVersion) {
    return '版本 $appVersion';
  }

  @override
  String get authorBy => '作者：Joe Mild';

  @override
  String get aboutDescription =>
      'GitSyncMarks 的移动应用 – 查看您 GitHub 仓库中的书签并在浏览器中打开。';

  @override
  String get projects => '项目';

  @override
  String get formatFromGitSyncMarks => '书签格式来自 GitSyncMarks。';

  @override
  String get gitSyncMarksDesc =>
      '基于 GitSyncMarks – 双向书签同步的浏览器扩展。本项目以 GitSyncMarks 为参考开发。';

  @override
  String get licenseMit => '许可证：MIT';

  @override
  String get quickGuide => '快速指南';

  @override
  String get help1Title => '1. 设置令牌';

  @override
  String get help1Body =>
      '创建一个 GitHub Personal Access Token (PAT)。经典 PAT：范围 \'repo\'。细粒度：Contents Read。创建位置：GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. 连接仓库';

  @override
  String get help2Body =>
      '在设置中输入 Owner、Repo 名称和 Branch。仓库应符合 GitSyncMarks 格式：根文件夹 toolbar 与 other（由浏览器扩展创建，例如 2.7.x），各含 _order.json 与每个书签一个 JSON 文件。';

  @override
  String get help3Title => '3. 测试连接';

  @override
  String get help3Body => '点击「Test Connection」验证令牌和仓库访问权限。成功后显示可用的根文件夹。';

  @override
  String get help4Title => '4. 选择文件夹';

  @override
  String get help4Body =>
      '选择要显示的根文件夹（如 toolbar、other）。空选择 = 全部。至少选一个 = 仅这些文件夹。';

  @override
  String get help5Title => '5. 同步';

  @override
  String get help5Body => '点击「Sync Bookmarks」加载书签。在主屏幕下拉刷新。';

  @override
  String get whichRepoFormat => '使用哪种仓库格式？';

  @override
  String get repoFormatDescription =>
      '仓库应符合 GitSyncMarks 格式：Base Path（如「bookmarks」）下为子文件夹 toolbar 与 other（扩展不将 menu/mobile 作为根同步）。每个文件夹有 _order.json 和书签 JSON（title、url）。与 GitSyncMarks 浏览器扩展（如 2.7.x）兼容。';

  @override
  String get support => '支持';

  @override
  String get supportText => '有问题或错误信息？请在项目仓库中提交 issue。';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (GitHub Issues)';

  @override
  String get profiles => '配置文件';

  @override
  String get profile => '配置文件';

  @override
  String get activeProfile => '当前配置文件';

  @override
  String get addProfile => '添加配置文件';

  @override
  String get renameProfile => '重命名配置文件';

  @override
  String get deleteProfile => '删除配置文件';

  @override
  String deleteProfileConfirm(String name) {
    return '删除配置文件\"$name\"？';
  }

  @override
  String get profileName => '配置文件名称';

  @override
  String profileCount(int count, int max) {
    return '$count/$max 个配置文件';
  }

  @override
  String maxProfilesReached(int max) {
    return '已达到最大配置文件数量（$max）';
  }

  @override
  String profileAdded(String name) {
    return '配置文件\"$name\"已添加';
  }

  @override
  String profileRenamed(String name) {
    return '配置文件已重命名为\"$name\"';
  }

  @override
  String get profileDeleted => '配置文件已删除';

  @override
  String get cannotDeleteLastProfile => '无法删除最后一个配置文件';

  @override
  String get importExport => '导入 / 导出';

  @override
  String get importSettings => '导入设置';

  @override
  String get exportSettings => '导出设置';

  @override
  String get importSettingsDesc => '从 GitSyncMarks 设置文件 (JSON) 导入配置文件';

  @override
  String get exportSettingsDesc => '将所有配置文件导出为 GitSyncMarks 设置文件';

  @override
  String importSuccess(int count) {
    return '已导入 $count 个配置文件';
  }

  @override
  String importFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String importConfirm(int count) {
    return '导入 $count 个配置文件？所有现有配置文件将被替换。';
  }

  @override
  String get exportSuccess => '设置已导出';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get rename => '重命名';

  @override
  String get add => '添加';

  @override
  String get import_ => '导入';

  @override
  String get replace => '替换';

  @override
  String get bookmarks => '书签';

  @override
  String get info => '信息';

  @override
  String get connection => '连接';

  @override
  String get folders => '文件夹';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => '同步';

  @override
  String get tabFiles => '文件';

  @override
  String get tabGeneral => '通用';

  @override
  String get tabHelp => '帮助';

  @override
  String get tabAbout => '关于';

  @override
  String get subTabProfile => '配置文件';

  @override
  String get subTabConnection => '连接';

  @override
  String get subTabExportImport => '导出 / 导入';

  @override
  String get subTabSettings => '设置';

  @override
  String get searchPlaceholder => '搜索书签...';

  @override
  String noSearchResults(String query) {
    return '没有\"$query\"的结果';
  }

  @override
  String get clearSearch => '清除搜索';

  @override
  String get automaticSync => '自动同步';

  @override
  String get autoSyncActive => '自动同步已启用';

  @override
  String get autoSyncDisabled => '自动同步已禁用';

  @override
  String nextSyncIn(String time) {
    return '下次同步将在 $time 后';
  }

  @override
  String get syncProfileRealtime => '实时';

  @override
  String get syncProfileFrequent => '频繁';

  @override
  String get syncProfileNormal => '正常';

  @override
  String get syncProfilePowersave => '省电';

  @override
  String get syncProfileCustom => '自定义';

  @override
  String get syncProfileMeaningTitle => '这些配置文件的含义：';

  @override
  String get syncProfileMeaningRealtime => '实时：每分钟同步一次（最高时效性，较高电池消耗）。';

  @override
  String get syncProfileMeaningFrequent => '频繁：每 5 分钟同步一次（适合活跃使用的平衡）。';

  @override
  String get syncProfileMeaningNormal => '正常：每 15 分钟同步一次（推荐默认）。';

  @override
  String get syncProfileMeaningPowersave => '省电：每 60 分钟同步一次（最低电池/网络消耗）。';

  @override
  String get syncProfileMeaningCustom => '自定义：以分钟为单位设置自己的间隔。';

  @override
  String get customSyncIntervalLabel => '自定义同步间隔（分钟）';

  @override
  String get customSyncIntervalHint => '输入 1 到 1440 之间的值';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return '请输入 $min 到 $max 分钟之间的有效间隔。';
  }

  @override
  String get syncCommit => '提交';

  @override
  String lastSynced(String time) {
    return '上次同步 $time';
  }

  @override
  String get neverSynced => '从未同步';

  @override
  String get syncOnStart => '应用启动时同步';

  @override
  String get allowMoveReorder => '允许移动和重新排序';

  @override
  String get allowMoveReorderDesc => '拖动手柄和移动到文件夹。禁用以使用只读视图。';

  @override
  String get allowMoveReorderDisable => '只读（隐藏手柄）';

  @override
  String get allowMoveReorderEnable => '启用编辑（显示手柄）';

  @override
  String bookmarkCount(int count, int folders) {
    return '$folders 个文件夹中有 $count 个书签';
  }

  @override
  String get syncNow => '立即同步';

  @override
  String get addBookmark => '添加书签';

  @override
  String get addBookmarkTitle => '添加书签';

  @override
  String get bookmarkTitle => '书签标题';

  @override
  String get selectFolder => '选择文件夹';

  @override
  String get exportBookmarks => '导出书签';

  @override
  String get settingsSyncToGit => '将设置同步到 Git（加密）';

  @override
  String get settingsSyncPassword => '加密密码';

  @override
  String get settingsSyncPasswordHint => '每台设备设置一次。所有设备上必须相同。';

  @override
  String get settingsSyncRememberPassword => '记住密码';

  @override
  String get settingsSyncPasswordSaved => '密码已保存（用于 Push/Pull）';

  @override
  String get settingsSyncClearPassword => '清除保存的密码';

  @override
  String get settingsSyncSaveBtn => '保存密码';

  @override
  String get settingsSyncPasswordMissing => '请输入密码。';

  @override
  String get settingsSyncWithBookmarks => '同步书签时同步设置';

  @override
  String get settingsSyncPush => '推送设置';

  @override
  String get settingsSyncPull => '拉取设置';

  @override
  String get settingsSyncModeLabel => '同步模式（仅限个人）';

  @override
  String get settingsSyncModeGlobal => '全局 — 在所有设备间共享（旧版，已迁移）';

  @override
  String get settingsSyncModeIndividual => '个人 — 仅此设备';

  @override
  String get settingsSyncImportTitle => '从其他设备导入';

  @override
  String get settingsSyncLoadConfigs => '加载可用配置';

  @override
  String get settingsSyncImport => '导入';

  @override
  String get settingsSyncImportEmpty => '未找到设备配置';

  @override
  String get settingsSyncImportSuccess => '设置已成功导入';

  @override
  String get reportIssue => '报告问题';

  @override
  String get documentation => '文档';

  @override
  String get voteBacklog => '对待办事项投票';

  @override
  String get discussions => '讨论';

  @override
  String get moveUp => '向上移动';

  @override
  String get moveDown => '向下移动';

  @override
  String get shareLinkAddBookmark => '将共享链接添加为书签';

  @override
  String get clearCache => '清除缓存';

  @override
  String get clearCacheDesc => '删除缓存的书签数据。如果已配置 GitHub，同步将自动运行。';

  @override
  String get clearCacheSuccess => '缓存已清除。';

  @override
  String get moveToFolder => '移动到文件夹';

  @override
  String get moveToFolderSuccess => '书签已移动';

  @override
  String get moveToFolderFailed => '书签移动失败';

  @override
  String get deleteBookmark => '删除书签';

  @override
  String deleteBookmarkConfirm(String title) {
    return '删除书签\"$title\"？';
  }

  @override
  String get bookmarkDeleted => '书签已删除';

  @override
  String get orderUpdated => '顺序已更新';

  @override
  String get rootFolder => '根文件夹';

  @override
  String get rootFolderHelp => '选择一个文件夹，其子文件夹将成为标签页。默认显示所有顶级文件夹。';

  @override
  String get allFolders => '所有文件夹';

  @override
  String get selectRootFolder => '选择根文件夹';

  @override
  String get exportPasswordTitle => '导出密码';

  @override
  String get exportPasswordHint => '留空以进行未加密的导出';

  @override
  String get importPasswordTitle => '加密文件';

  @override
  String get importPasswordHint => '输入加密密码';

  @override
  String get importSettingsAction => '导入设置';

  @override
  String get importingSettings => '正在导入设置…';

  @override
  String get orImportExisting => '或导入现有设置';

  @override
  String get wrongPassword => '密码错误。请重试。';

  @override
  String get showSecret => '显示密钥';

  @override
  String get hideSecret => '隐藏密钥';

  @override
  String get export_ => '导出';

  @override
  String get resetAll => '重置所有数据';

  @override
  String get resetConfirmTitle => '重置应用？';

  @override
  String get resetConfirmMessage => '所有配置文件、设置和缓存的书签将被删除。应用将恢复到初始状态。';

  @override
  String get resetSuccess => '所有数据已重置';

  @override
  String get settingsSyncClientName => '客户端名称';

  @override
  String get settingsSyncClientNameHint => '例如 base-android 或 laptop-linux';

  @override
  String get settingsSyncClientNameRequired => '请输入个人模式的客户端名称。';

  @override
  String get settingsSyncCreateBtn => '创建我的客户端设置';

  @override
  String get generalLanguageTitle => '语言';

  @override
  String get generalThemeTitle => '主题';

  @override
  String get appLanguage => '应用语言';

  @override
  String get appTheme => '应用主题';

  @override
  String get appLanguageSystem => '系统默认';

  @override
  String get appThemeSystem => '系统默认';

  @override
  String get appThemeLight => '浅色';

  @override
  String get appThemeDark => '深色';

  @override
  String get appLanguageGerman => '德语';

  @override
  String get appLanguageEnglish => '英语';

  @override
  String get appLanguageSpanish => '西班牙语';

  @override
  String get appLanguageFrench => '法语';

  @override
  String get basePathBrowse => '浏览文件夹';

  @override
  String get basePathBrowseTitle => '选择仓库文件夹';

  @override
  String get subTabFolders => '文件夹';

  @override
  String get appLanguagePortugueseBrazil => '葡萄牙语（巴西）';

  @override
  String get appLanguageItalian => '意大利语';

  @override
  String get appLanguageJapanese => '日语';

  @override
  String get appLanguageChineseSimplified => '中文（简体）';

  @override
  String get appLanguageKorean => '韩语';

  @override
  String get appLanguageRussian => '俄语';

  @override
  String get appLanguageTurkish => '土耳其语';

  @override
  String get appLanguagePolish => '波兰语';
}
