// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => '설정';

  @override
  String get about => '앱 정보';

  @override
  String get help => '도움말';

  @override
  String get noBookmarksYet => '북마크가 아직 없습니다';

  @override
  String get tapSyncToFetch => 'GitHub에서 북마크를 가져오려면 동기화를 탭하세요';

  @override
  String get configureInSettings => '설정에서 GitHub 연결을 구성하세요';

  @override
  String get sync => '동기화';

  @override
  String get openSettings => '설정 열기';

  @override
  String get error => '오류';

  @override
  String get retry => '다시 시도';

  @override
  String couldNotOpenUrl(Object url) {
    return '$url을 열 수 없습니다';
  }

  @override
  String get couldNotOpenLink => '링크를 열 수 없습니다';

  @override
  String get pleaseFillTokenOwnerRepo => 'Token, Owner, Repo를 입력해 주세요';

  @override
  String get settingsSaved => '설정이 저장되었습니다';

  @override
  String get connectionSuccessful => '연결 성공';

  @override
  String get connectionFailed => '연결 실패';

  @override
  String get syncComplete => '동기화 완료';

  @override
  String get syncFailed => '동기화 실패';

  @override
  String get githubConnection => 'GitHub 연결';

  @override
  String get gitConnection => 'Git 연결';

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
  String get personalAccessToken => '개인 액세스 토큰 (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. 생성 위치: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => '저장소 소유자';

  @override
  String get ownerHint => 'your-github-username';

  @override
  String get repositoryName => '저장소 이름';

  @override
  String get repoHint => 'my-bookmarks';

  @override
  String get branch => '브랜치';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => '기본 경로';

  @override
  String get basePathHint => 'bookmarks';

  @override
  String get displayedFolders => '표시할 폴더';

  @override
  String get displayedFoldersHelp =>
      '연결 테스트 후 사용 가능. 빈 선택 = 모든 폴더. 하나 이상 선택 = 선택한 폴더만.';

  @override
  String get save => '저장';

  @override
  String get testConnection => '연결 테스트';

  @override
  String get syncBookmarks => '북마크 동기화';

  @override
  String version(String appVersion) {
    return '버전 $appVersion';
  }

  @override
  String get authorBy => 'Joe Mild 제작';

  @override
  String get aboutDescription =>
      'GitSyncMarks용 모바일 앱 – GitHub 저장소의 북마크를 보고 브라우저에서 엽니다.';

  @override
  String get projects => '프로젝트';

  @override
  String get formatFromGitSyncMarks => '북마크 형식은 GitSyncMarks에서 가져옵니다.';

  @override
  String get gitSyncMarksDesc =>
      'GitSyncMarks 기반 – 양방향 북마크 동기화를 위한 브라우저 확장 프로그램. 이 프로젝트는 GitSyncMarks를 참조로 개발되었습니다.';

  @override
  String get licenseMit => '라이선스: MIT';

  @override
  String get quickGuide => '빠른 가이드';

  @override
  String get help1Title => '1. 토큰 설정';

  @override
  String get help1Body =>
      'GitHub Personal Access Token (PAT)를 생성하세요. Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. 생성 위치: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. 저장소 연결';

  @override
  String get help2Body =>
      '설정에서 Owner, Repo 이름, Branch를 입력하세요. 저장소는 GitSyncMarks 형식(브라우저 확장이 만드는 루트 폴더 toolbar와 other, 예: 2.7.x, 각각 _order.json과 북마크당 JSON)을 따라야 합니다.';

  @override
  String get help3Title => '3. 연결 테스트';

  @override
  String get help3Body =>
      '「Test Connection」을 클릭하여 토큰 및 저장소 접근을 확인하세요. 성공하면 사용 가능한 루트 폴더가 표시됩니다.';

  @override
  String get help4Title => '4. 폴더 선택';

  @override
  String get help4Body =>
      '표시할 루트 폴더를 선택하세요 (예: toolbar, other). 빈 선택 = 모두. 하나 이상 선택 = 선택한 폴더만.';

  @override
  String get help5Title => '5. 동기화';

  @override
  String get help5Body =>
      '「Sync Bookmarks」를 클릭하여 북마크를 불러옵니다. 메인 화면에서 당겨서 새로 고칩니다.';

  @override
  String get whichRepoFormat => '어떤 저장소 형식인가요?';

  @override
  String get repoFormatDescription =>
      '저장소는 GitSyncMarks 형식을 따릅니다: Base Path(예: \"bookmarks\")에 하위 폴더 toolbar와 other(확장 기능은 menu/mobile을 루트로 동기화하지 않음). 각 폴더에 _order.json과 북마크당 JSON(title, url). GitSyncMarks 브라우저 확장(예: 2.7.x)과 호환됩니다.';

  @override
  String get support => '지원';

  @override
  String get supportText => '질문이나 오류 메시지가 있으신가요? 프로젝트 저장소에 이슈를 열어 주세요.';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (GitHub Issues)';

  @override
  String get profiles => '프로필';

  @override
  String get profile => '프로필';

  @override
  String get activeProfile => '활성 프로필';

  @override
  String get addProfile => '프로필 추가';

  @override
  String get renameProfile => '프로필 이름 변경';

  @override
  String get deleteProfile => '프로필 삭제';

  @override
  String deleteProfileConfirm(String name) {
    return '프로필 \"$name\"을 삭제하시겠습니까?';
  }

  @override
  String get profileName => '프로필 이름';

  @override
  String profileCount(int count, int max) {
    return '$count/$max 프로필';
  }

  @override
  String maxProfilesReached(int max) {
    return '최대 프로필 수에 도달했습니다 ($max)';
  }

  @override
  String profileAdded(String name) {
    return '프로필 \"$name\"이 추가되었습니다';
  }

  @override
  String profileRenamed(String name) {
    return '프로필이 \"$name\"으로 변경되었습니다';
  }

  @override
  String get profileDeleted => '프로필이 삭제되었습니다';

  @override
  String get cannotDeleteLastProfile => '마지막 프로필은 삭제할 수 없습니다';

  @override
  String get importExport => '가져오기 / 내보내기';

  @override
  String get importSettings => '설정 가져오기';

  @override
  String get exportSettings => '설정 내보내기';

  @override
  String get importSettingsDesc => 'GitSyncMarks 설정 파일(JSON)에서 프로필 가져오기';

  @override
  String get exportSettingsDesc => '모든 프로필을 GitSyncMarks 설정 파일로 내보내기';

  @override
  String importSuccess(int count) {
    return '$count개의 프로필을 가져왔습니다';
  }

  @override
  String importFailed(String error) {
    return '가져오기 실패: $error';
  }

  @override
  String importConfirm(int count) {
    return '$count개의 프로필을 가져오시겠습니까? 기존 모든 프로필이 교체됩니다.';
  }

  @override
  String get exportSuccess => '설정을 내보냈습니다';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get rename => '이름 변경';

  @override
  String get add => '추가';

  @override
  String get import_ => '가져오기';

  @override
  String get replace => '교체';

  @override
  String get bookmarks => '북마크';

  @override
  String get info => '정보';

  @override
  String get connection => '연결';

  @override
  String get folders => '폴더';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => '동기화';

  @override
  String get tabFiles => '파일';

  @override
  String get tabGeneral => '일반';

  @override
  String get tabHelp => '도움말';

  @override
  String get tabAbout => '앱 정보';

  @override
  String get subTabProfile => '프로필';

  @override
  String get subTabConnection => '연결';

  @override
  String get subTabExportImport => '내보내기 / 가져오기';

  @override
  String get subTabSettings => '설정';

  @override
  String get searchPlaceholder => '북마크 검색...';

  @override
  String noSearchResults(String query) {
    return '\"$query\"에 대한 결과 없음';
  }

  @override
  String get clearSearch => '검색 지우기';

  @override
  String get automaticSync => '자동 동기화';

  @override
  String get autoSyncActive => '자동 동기화 활성';

  @override
  String get autoSyncDisabled => '자동 동기화 비활성';

  @override
  String nextSyncIn(String time) {
    return '다음 동기화까지 $time';
  }

  @override
  String get syncProfileRealtime => '실시간';

  @override
  String get syncProfileFrequent => '자주';

  @override
  String get syncProfileNormal => '보통';

  @override
  String get syncProfilePowersave => '절전';

  @override
  String get syncProfileCustom => '사용자 정의';

  @override
  String get syncProfileMeaningTitle => '각 프로필의 의미:';

  @override
  String get syncProfileMeaningRealtime =>
      '실시간: 1분마다 동기화 (최고의 신선도, 더 높은 배터리 소모).';

  @override
  String get syncProfileMeaningFrequent => '자주: 5분마다 동기화 (활성 사용에 균형).';

  @override
  String get syncProfileMeaningNormal => '보통: 15분마다 동기화 (권장 기본값).';

  @override
  String get syncProfileMeaningPowersave => '절전: 60분마다 동기화 (최소 배터리/네트워크 소모).';

  @override
  String get syncProfileMeaningCustom => '사용자 정의: 분 단위로 직접 간격을 설정합니다.';

  @override
  String get customSyncIntervalLabel => '사용자 정의 동기화 간격 (분)';

  @override
  String get customSyncIntervalHint => '1~1440 사이의 값을 입력하세요';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return '$min~$max분 사이의 유효한 간격을 입력하세요.';
  }

  @override
  String get syncCommit => '커밋';

  @override
  String lastSynced(String time) {
    return '마지막 동기화 $time';
  }

  @override
  String get neverSynced => '동기화한 적 없음';

  @override
  String get syncOnStart => '앱 시작 시 동기화';

  @override
  String get allowMoveReorder => '이동 및 순서 변경 허용';

  @override
  String get allowMoveReorderDesc => '드래그 핸들 및 폴더 이동. 읽기 전용 보기를 위해 비활성화합니다.';

  @override
  String get allowMoveReorderDisable => '읽기 전용 활성화 (핸들 숨기기)';

  @override
  String get allowMoveReorderEnable => '편집 활성화 (핸들 표시)';

  @override
  String bookmarkCount(int count, int folders) {
    return '$folders개 폴더에 $count개 북마크';
  }

  @override
  String get syncNow => '지금 동기화';

  @override
  String get addBookmark => '북마크 추가';

  @override
  String get addBookmarkTitle => '북마크 추가';

  @override
  String get bookmarkTitle => '북마크 제목';

  @override
  String get selectFolder => '폴더 선택';

  @override
  String get exportBookmarks => '북마크 내보내기';

  @override
  String get settingsSyncToGit => '설정을 Git에 동기화 (암호화)';

  @override
  String get settingsSyncPassword => '암호화 비밀번호';

  @override
  String get settingsSyncPasswordHint => '기기당 한 번 설정. 모든 기기에서 동일해야 합니다.';

  @override
  String get settingsSyncRememberPassword => '비밀번호 기억';

  @override
  String get settingsSyncPasswordSaved => '비밀번호 저장됨 (Push/Pull에 사용)';

  @override
  String get settingsSyncClearPassword => '저장된 비밀번호 지우기';

  @override
  String get settingsSyncSaveBtn => '비밀번호 저장';

  @override
  String get settingsSyncPasswordMissing => '비밀번호를 입력해 주세요.';

  @override
  String get settingsSyncWithBookmarks => '북마크 동기화 시 설정도 동기화';

  @override
  String get settingsSyncPush => '설정 푸시';

  @override
  String get settingsSyncPull => '설정 풀';

  @override
  String get settingsSyncModeLabel => '동기화 모드 (개별 전용)';

  @override
  String get settingsSyncModeGlobal => '글로벌 — 모든 기기 공유 (레거시, 마이그레이션됨)';

  @override
  String get settingsSyncModeIndividual => '개별 — 이 기기만';

  @override
  String get settingsSyncImportTitle => '다른 기기에서 가져오기';

  @override
  String get settingsSyncLoadConfigs => '사용 가능한 설정 불러오기';

  @override
  String get settingsSyncImport => '가져오기';

  @override
  String get settingsSyncImportEmpty => '기기 설정을 찾을 수 없습니다';

  @override
  String get settingsSyncImportSuccess => '설정을 성공적으로 가져왔습니다';

  @override
  String get reportIssue => '문제 신고';

  @override
  String get documentation => '문서';

  @override
  String get voteBacklog => '백로그 투표';

  @override
  String get discussions => '토론';

  @override
  String get moveUp => '위로 이동';

  @override
  String get moveDown => '아래로 이동';

  @override
  String get shareLinkAddBookmark => '공유 링크를 북마크로 추가';

  @override
  String get clearCache => '캐시 지우기';

  @override
  String get clearCacheDesc =>
      '캐시된 북마크 데이터를 제거합니다. GitHub가 구성된 경우 자동으로 동기화됩니다.';

  @override
  String get clearCacheSuccess => '캐시가 지워졌습니다.';

  @override
  String get moveToFolder => '폴더로 이동';

  @override
  String get moveToFolderSuccess => '북마크가 이동되었습니다';

  @override
  String get moveToFolderFailed => '북마크 이동에 실패했습니다';

  @override
  String get deleteBookmark => '북마크 삭제';

  @override
  String deleteBookmarkConfirm(String title) {
    return '북마크 \"$title\"을 삭제하시겠습니까?';
  }

  @override
  String get bookmarkDeleted => '북마크가 삭제되었습니다';

  @override
  String get orderUpdated => '순서가 업데이트되었습니다';

  @override
  String get rootFolder => '루트 폴더';

  @override
  String get rootFolderHelp => '하위 폴더가 탭이 될 폴더를 선택합니다. 기본값은 모든 최상위 폴더를 표시합니다.';

  @override
  String get allFolders => '모든 폴더';

  @override
  String get selectRootFolder => '루트 폴더 선택';

  @override
  String get exportPasswordTitle => '내보내기 비밀번호';

  @override
  String get exportPasswordHint => '암호화하지 않으려면 비워 두세요';

  @override
  String get importPasswordTitle => '암호화된 파일';

  @override
  String get importPasswordHint => '암호화 비밀번호를 입력하세요';

  @override
  String get importSettingsAction => '설정 가져오기';

  @override
  String get importingSettings => '설정 가져오는 중…';

  @override
  String get orImportExisting => '또는 기존 설정 가져오기';

  @override
  String get wrongPassword => '비밀번호가 잘못되었습니다. 다시 시도하세요.';

  @override
  String get showSecret => '비밀 표시';

  @override
  String get hideSecret => '비밀 숨기기';

  @override
  String get export_ => '내보내기';

  @override
  String get resetAll => '모든 데이터 초기화';

  @override
  String get resetConfirmTitle => '앱을 초기화하시겠습니까?';

  @override
  String get resetConfirmMessage =>
      '모든 프로필, 설정 및 캐시된 북마크가 삭제됩니다. 앱이 초기 상태로 돌아갑니다.';

  @override
  String get resetSuccess => '모든 데이터가 초기화되었습니다';

  @override
  String get settingsSyncClientName => '클라이언트 이름';

  @override
  String get settingsSyncClientNameHint => '예: base-android 또는 laptop-linux';

  @override
  String get settingsSyncClientNameRequired => '개별 모드의 클라이언트 이름을 입력해 주세요.';

  @override
  String get settingsSyncCreateBtn => '내 클라이언트 설정 만들기';

  @override
  String get generalLanguageTitle => '언어';

  @override
  String get generalThemeTitle => '테마';

  @override
  String get appLanguage => '앱 언어';

  @override
  String get appTheme => '앱 테마';

  @override
  String get appLanguageSystem => '시스템 기본값';

  @override
  String get appThemeSystem => '시스템 기본값';

  @override
  String get appThemeLight => '밝게';

  @override
  String get appThemeDark => '어둡게';

  @override
  String get appLanguageGerman => '독일어';

  @override
  String get appLanguageEnglish => '영어';

  @override
  String get appLanguageSpanish => '스페인어';

  @override
  String get appLanguageFrench => '프랑스어';

  @override
  String get basePathBrowse => '폴더 찾아보기';

  @override
  String get basePathBrowseTitle => '저장소 폴더 선택';

  @override
  String get subTabFolders => '폴더';

  @override
  String get appLanguagePortugueseBrazil => '포르투갈어 (브라질)';

  @override
  String get appLanguageItalian => '이탈리아어';

  @override
  String get appLanguageJapanese => '일본어';

  @override
  String get appLanguageChineseSimplified => '중국어 (간체)';

  @override
  String get appLanguageKorean => '한국어';

  @override
  String get appLanguageRussian => '러시아어';

  @override
  String get appLanguageTurkish => '터키어';

  @override
  String get appLanguagePolish => '폴란드어';
}
