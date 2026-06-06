// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => '設定';

  @override
  String get about => 'アプリについて';

  @override
  String get help => 'ヘルプ';

  @override
  String get noBookmarksYet => 'ブックマークはまだありません';

  @override
  String get tapSyncToFetch => 'GitHubからブックマークを取得するにはSyncをタップ';

  @override
  String get configureInSettings => '設定でGitHub接続を構成してください';

  @override
  String get sync => '同期';

  @override
  String get openSettings => '設定を開く';

  @override
  String get error => 'エラー';

  @override
  String get retry => '再試行';

  @override
  String couldNotOpenUrl(Object url) {
    return '$urlを開けませんでした';
  }

  @override
  String get couldNotOpenLink => 'リンクを開けませんでした';

  @override
  String get pleaseFillTokenOwnerRepo => 'Token、Owner、Repoを入力してください';

  @override
  String get settingsSaved => '設定を保存しました';

  @override
  String get connectionSuccessful => '接続に成功しました';

  @override
  String get connectionFailed => '接続に失敗しました';

  @override
  String get syncComplete => '同期完了';

  @override
  String get syncFailed => '同期失敗';

  @override
  String get githubConnection => 'GitHub接続';

  @override
  String get gitConnection => 'Git接続';

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
  String get personalAccessToken => '個人アクセストークン (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'Classic PAT: スコープ \'repo\'。Fine-grained: Contents Read。作成場所: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => 'リポジトリオーナー';

  @override
  String get ownerHint => 'あなたのGitHubユーザー名';

  @override
  String get repositoryName => 'リポジトリ名';

  @override
  String get repoHint => 'my-bookmarks';

  @override
  String get branch => 'ブランチ';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => 'ベースパス';

  @override
  String get basePathHint => 'bookmarks';

  @override
  String get displayedFolders => '表示フォルダ';

  @override
  String get displayedFoldersHelp =>
      '接続テスト後に利用可能。空の選択 = すべてのフォルダ。1つ以上選択 = 選択したフォルダのみ。';

  @override
  String get save => '保存';

  @override
  String get testConnection => '接続テスト';

  @override
  String get syncBookmarks => 'ブックマークを同期';

  @override
  String version(String appVersion) {
    return 'バージョン $appVersion';
  }

  @override
  String get authorBy => 'Joe Mild 作';

  @override
  String get aboutDescription =>
      'GitSyncMarks用モバイルアプリ – GitHubリポジトリのブックマークを表示してブラウザで開きます。';

  @override
  String get projects => 'プロジェクト';

  @override
  String get formatFromGitSyncMarks => 'ブックマーク形式はGitSyncMarksによるものです。';

  @override
  String get gitSyncMarksDesc =>
      'GitSyncMarksをベースにしています – ブックマークの双方向同期のためのブラウザ拡張機能。このプロジェクトはGitSyncMarksを参照として開発されました。';

  @override
  String get licenseMit => 'ライセンス: MIT';

  @override
  String get quickGuide => 'クイックガイド';

  @override
  String get help1Title => '1. トークンの設定';

  @override
  String get help1Body =>
      'GitHub Personal Access Token (PAT)を作成してください。Classic PAT: スコープ \'repo\'。Fine-grained: Contents Read。作成場所: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. リポジトリの接続';

  @override
  String get help2Body =>
      '設定でOwner、Repo名、Branchを入力してください。リポジトリはGitSyncMarks形式（ブラウザ拡張機能が作成するルートフォルダ toolbar と other、例: 2.7.x。各フォルダに _order.json とブックマークごとのJSON）に従う必要があります。';

  @override
  String get help3Title => '3. 接続テスト';

  @override
  String get help3Body =>
      '「Test Connection」をクリックしてトークンとリポジトリアクセスを確認してください。成功すると、利用可能なルートフォルダが表示されます。';

  @override
  String get help4Title => '4. フォルダの選択';

  @override
  String get help4Body =>
      '表示するルートフォルダを選択してください（例: toolbar、other）。空の選択 = すべて。1つ以上選択 = 選択したフォルダのみ。';

  @override
  String get help5Title => '5. 同期';

  @override
  String get help5Body =>
      '「Sync Bookmarks」をクリックしてブックマークを読み込みます。メイン画面でプルして更新できます。';

  @override
  String get whichRepoFormat => 'どのリポジトリ形式ですか？';

  @override
  String get repoFormatDescription =>
      'リポジトリはGitSyncMarks形式に従います: Base Path（例: \"bookmarks\"）にサブフォルダ toolbar と other（拡張機能は menu/mobile をルートとして同期しません）。各フォルダに_order.jsonとブックマークごとのJSON（title、url）。GitSyncMarks ブラウザ拡張（例: 2.7.x）と互換です。';

  @override
  String get support => 'サポート';

  @override
  String get supportText => '質問やエラーメッセージがありますか？プロジェクトリポジトリでissueを開いてください。';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (GitHub Issues)';

  @override
  String get profiles => 'プロファイル';

  @override
  String get profile => 'プロファイル';

  @override
  String get activeProfile => 'アクティブプロファイル';

  @override
  String get addProfile => 'プロファイルを追加';

  @override
  String get renameProfile => 'プロファイルの名前を変更';

  @override
  String get deleteProfile => 'プロファイルを削除';

  @override
  String deleteProfileConfirm(String name) {
    return 'プロファイル「$name」を削除しますか？';
  }

  @override
  String get profileName => 'プロファイル名';

  @override
  String profileCount(int count, int max) {
    return '$count/$max プロファイル';
  }

  @override
  String maxProfilesReached(int max) {
    return 'プロファイルの最大数に達しました ($max)';
  }

  @override
  String profileAdded(String name) {
    return 'プロファイル「$name」を追加しました';
  }

  @override
  String profileRenamed(String name) {
    return 'プロファイルを「$name」に名前変更しました';
  }

  @override
  String get profileDeleted => 'プロファイルを削除しました';

  @override
  String get cannotDeleteLastProfile => '最後のプロファイルは削除できません';

  @override
  String get importExport => 'インポート / エクスポート';

  @override
  String get importSettings => '設定をインポート';

  @override
  String get exportSettings => '設定をエクスポート';

  @override
  String get importSettingsDesc => 'GitSyncMarks設定ファイル (JSON) からプロファイルをインポート';

  @override
  String get exportSettingsDesc => 'すべてのプロファイルをGitSyncMarks設定ファイルとしてエクスポート';

  @override
  String importSuccess(int count) {
    return '$count件のプロファイルをインポートしました';
  }

  @override
  String importFailed(String error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String importConfirm(int count) {
    return '$count件のプロファイルをインポートしますか？既存のすべてのプロファイルが置き換えられます。';
  }

  @override
  String get exportSuccess => '設定をエクスポートしました';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get rename => '名前変更';

  @override
  String get add => '追加';

  @override
  String get import_ => 'インポート';

  @override
  String get replace => '置換';

  @override
  String get bookmarks => 'ブックマーク';

  @override
  String get info => '情報';

  @override
  String get connection => '接続';

  @override
  String get folders => 'フォルダ';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => '同期';

  @override
  String get tabFiles => 'ファイル';

  @override
  String get tabGeneral => '一般';

  @override
  String get tabHelp => 'ヘルプ';

  @override
  String get tabAbout => 'アプリについて';

  @override
  String get subTabProfile => 'プロファイル';

  @override
  String get subTabConnection => '接続';

  @override
  String get subTabExportImport => 'エクスポート / インポート';

  @override
  String get subTabSettings => '設定';

  @override
  String get searchPlaceholder => 'ブックマークを検索...';

  @override
  String noSearchResults(String query) {
    return '「$query」の結果はありません';
  }

  @override
  String get clearSearch => '検索をクリア';

  @override
  String get automaticSync => '自動同期';

  @override
  String get autoSyncActive => '自動同期有効';

  @override
  String get autoSyncDisabled => '自動同期無効';

  @override
  String nextSyncIn(String time) {
    return '次の同期まで $time';
  }

  @override
  String get syncProfileRealtime => 'リアルタイム';

  @override
  String get syncProfileFrequent => '頻繁';

  @override
  String get syncProfileNormal => '通常';

  @override
  String get syncProfilePowersave => '省電力';

  @override
  String get syncProfileCustom => 'カスタム';

  @override
  String get syncProfileMeaningTitle => 'プロファイルの意味:';

  @override
  String get syncProfileMeaningRealtime => 'リアルタイム: 1分ごとに同期（最高の鮮度、バッテリー消費大）。';

  @override
  String get syncProfileMeaningFrequent => '頻繁: 5分ごとに同期（アクティブな使用でバランスが取れています）。';

  @override
  String get syncProfileMeaningNormal => '通常: 15分ごとに同期（推奨デフォルト）。';

  @override
  String get syncProfileMeaningPowersave => '省電力: 60分ごとに同期（バッテリー/ネットワーク消費最小）。';

  @override
  String get syncProfileMeaningCustom => 'カスタム: 自分でインターバルを分単位で設定。';

  @override
  String get customSyncIntervalLabel => 'カスタム同期インターバル（分）';

  @override
  String get customSyncIntervalHint => '1〜1440の値を入力';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return '$min〜$max分の有効なインターバルを入力してください。';
  }

  @override
  String get syncCommit => 'コミット';

  @override
  String lastSynced(String time) {
    return '最終同期 $time';
  }

  @override
  String get neverSynced => '未同期';

  @override
  String get syncOnStart => 'アプリ起動時に同期';

  @override
  String get allowMoveReorder => '移動と並べ替えを許可';

  @override
  String get allowMoveReorderDesc =>
      'ドラッグハンドルとフォルダへの移動。読み取り専用表示にするには無効化してください。';

  @override
  String get allowMoveReorderDisable => '読み取り専用（ハンドルを非表示）';

  @override
  String get allowMoveReorderEnable => '編集を有効（ハンドルを表示）';

  @override
  String bookmarkCount(int count, int folders) {
    return '$foldersフォルダに$count件のブックマーク';
  }

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get addBookmark => 'ブックマークを追加';

  @override
  String get addBookmarkTitle => 'ブックマークを追加';

  @override
  String get bookmarkTitle => 'ブックマークのタイトル';

  @override
  String get selectFolder => 'フォルダを選択';

  @override
  String get exportBookmarks => 'ブックマークをエクスポート';

  @override
  String get settingsSyncToGit => '設定をGitに同期（暗号化）';

  @override
  String get settingsSyncPassword => '暗号化パスワード';

  @override
  String get settingsSyncPasswordHint => 'デバイスごとに1回設定。すべてのデバイスで同じである必要があります。';

  @override
  String get settingsSyncRememberPassword => 'パスワードを記憶';

  @override
  String get settingsSyncPasswordSaved => 'パスワードを保存しました（Push/Pullで使用）';

  @override
  String get settingsSyncClearPassword => '保存したパスワードをクリア';

  @override
  String get settingsSyncSaveBtn => 'パスワードを保存';

  @override
  String get settingsSyncPasswordMissing => 'パスワードを入力してください。';

  @override
  String get settingsSyncWithBookmarks => 'ブックマーク同期時に設定も同期';

  @override
  String get settingsSyncPush => '設定をプッシュ';

  @override
  String get settingsSyncPull => '設定をプル';

  @override
  String get settingsSyncModeLabel => '同期モード（個別のみ）';

  @override
  String get settingsSyncModeGlobal => 'グローバル — すべてのデバイスで共有（レガシー、移行済み）';

  @override
  String get settingsSyncModeIndividual => '個別 — このデバイスのみ';

  @override
  String get settingsSyncImportTitle => '他のデバイスからインポート';

  @override
  String get settingsSyncLoadConfigs => '利用可能な設定を読み込む';

  @override
  String get settingsSyncImport => 'インポート';

  @override
  String get settingsSyncImportEmpty => 'デバイス設定が見つかりません';

  @override
  String get settingsSyncImportSuccess => '設定を正常にインポートしました';

  @override
  String get reportIssue => '問題を報告';

  @override
  String get documentation => 'ドキュメント';

  @override
  String get voteBacklog => 'バックログに投票';

  @override
  String get discussions => 'ディスカッション';

  @override
  String get moveUp => '上へ移動';

  @override
  String get moveDown => '下へ移動';

  @override
  String get shareLinkAddBookmark => '共有リンクをブックマークとして追加';

  @override
  String get clearCache => 'キャッシュをクリア';

  @override
  String get clearCacheDesc =>
      'キャッシュされたブックマークデータを削除。GitHubが設定されている場合は自動的に同期します。';

  @override
  String get clearCacheSuccess => 'キャッシュをクリアしました。';

  @override
  String get moveToFolder => 'フォルダへ移動';

  @override
  String get moveToFolderSuccess => 'ブックマークを移動しました';

  @override
  String get moveToFolderFailed => 'ブックマークの移動に失敗しました';

  @override
  String get deleteBookmark => 'ブックマークを削除';

  @override
  String deleteBookmarkConfirm(String title) {
    return 'ブックマーク「$title」を削除しますか？';
  }

  @override
  String get bookmarkDeleted => 'ブックマークを削除しました';

  @override
  String get orderUpdated => '順序を更新しました';

  @override
  String get rootFolder => 'ルートフォルダ';

  @override
  String get rootFolderHelp => 'サブフォルダがタブになるフォルダを選択。デフォルトではすべてのトップレベルフォルダを表示。';

  @override
  String get allFolders => 'すべてのフォルダ';

  @override
  String get selectRootFolder => 'ルートフォルダを選択';

  @override
  String get exportPasswordTitle => 'エクスポートパスワード';

  @override
  String get exportPasswordHint => '暗号化なしのエクスポートは空のままにしてください';

  @override
  String get importPasswordTitle => '暗号化ファイル';

  @override
  String get importPasswordHint => '暗号化パスワードを入力してください';

  @override
  String get importSettingsAction => '設定をインポート';

  @override
  String get importingSettings => '設定をインポート中…';

  @override
  String get orImportExisting => 'または既存の設定をインポート';

  @override
  String get wrongPassword => 'パスワードが間違っています。もう一度お試しください。';

  @override
  String get showSecret => 'シークレットを表示';

  @override
  String get hideSecret => 'シークレットを非表示';

  @override
  String get export_ => 'エクスポート';

  @override
  String get resetAll => 'すべてのデータをリセット';

  @override
  String get resetConfirmTitle => 'アプリをリセットしますか？';

  @override
  String get resetConfirmMessage =>
      'すべてのプロファイル、設定、キャッシュされたブックマークが削除されます。アプリは初期状態に戻ります。';

  @override
  String get resetSuccess => 'すべてのデータがリセットされました';

  @override
  String get settingsSyncClientName => 'クライアント名';

  @override
  String get settingsSyncClientNameHint => '例: base-android または laptop-linux';

  @override
  String get settingsSyncClientNameRequired => '個別モードのクライアント名を入力してください。';

  @override
  String get settingsSyncCreateBtn => 'クライアント設定を作成';

  @override
  String get generalLanguageTitle => '言語';

  @override
  String get generalThemeTitle => 'テーマ';

  @override
  String get appLanguage => 'アプリの言語';

  @override
  String get appTheme => 'アプリのテーマ';

  @override
  String get appLanguageSystem => 'システムデフォルト';

  @override
  String get appThemeSystem => 'システム設定';

  @override
  String get appThemeLight => 'ライト';

  @override
  String get appThemeDark => 'ダーク';

  @override
  String get appLanguageGerman => 'ドイツ語';

  @override
  String get appLanguageEnglish => '英語';

  @override
  String get appLanguageSpanish => 'スペイン語';

  @override
  String get appLanguageFrench => 'フランス語';

  @override
  String get basePathBrowse => 'フォルダを参照';

  @override
  String get basePathBrowseTitle => 'リポジトリフォルダを選択';

  @override
  String get subTabFolders => 'フォルダ';

  @override
  String get appLanguagePortugueseBrazil => 'ポルトガル語（ブラジル）';

  @override
  String get appLanguageItalian => 'イタリア語';

  @override
  String get appLanguageJapanese => '日本語';

  @override
  String get appLanguageChineseSimplified => '中国語（簡体字）';

  @override
  String get appLanguageKorean => '韓国語';

  @override
  String get appLanguageRussian => 'ロシア語';

  @override
  String get appLanguageTurkish => 'トルコ語';

  @override
  String get appLanguagePolish => 'ポーランド語';
}
