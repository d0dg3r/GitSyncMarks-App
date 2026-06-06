// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => 'Ayarlar';

  @override
  String get about => 'Hakkında';

  @override
  String get help => 'Yardım';

  @override
  String get noBookmarksYet => 'Henüz yer imi yok';

  @override
  String get tapSyncToFetch =>
      'GitHub\'dan yer imlerini çekmek için Senkronize\'ye dokunun';

  @override
  String get configureInSettings =>
      'Ayarlar\'da GitHub bağlantısını yapılandırın';

  @override
  String get sync => 'Senkronize Et';

  @override
  String get openSettings => 'Ayarları Aç';

  @override
  String get error => 'Hata';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String couldNotOpenUrl(Object url) {
    return '$url açılamadı';
  }

  @override
  String get couldNotOpenLink => 'Bağlantı açılamadı';

  @override
  String get pleaseFillTokenOwnerRepo =>
      'Lütfen Token, Owner ve Repo\'yu doldurun';

  @override
  String get settingsSaved => 'Ayarlar kaydedildi';

  @override
  String get connectionSuccessful => 'Bağlantı başarılı';

  @override
  String get connectionFailed => 'Bağlantı başarısız';

  @override
  String get syncComplete => 'Senkronizasyon tamamlandı';

  @override
  String get syncFailed => 'Senkronizasyon başarısız';

  @override
  String get githubConnection => 'GitHub Bağlantısı';

  @override
  String get gitConnection => 'Git Bağlantısı';

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
  String get personalAccessToken => 'Kişisel Erişim Tokeni (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'Klasik PAT: Kapsam \'repo\'. Fine-grained: Contents Read. Oluştur: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => 'Depo Sahibi';

  @override
  String get ownerHint => 'github-kullanici-adiniz';

  @override
  String get repositoryName => 'Depo Adı';

  @override
  String get repoHint => 'yer-imlerim';

  @override
  String get branch => 'Dal';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => 'Temel Yol';

  @override
  String get basePathHint => 'yer-imleri';

  @override
  String get displayedFolders => 'Görüntülenen Klasörler';

  @override
  String get displayedFoldersHelp =>
      'Bağlantı Testi\'nden sonra kullanılabilir. Boş seçim = tüm klasörler. En az bir seçili = yalnızca bu klasörler.';

  @override
  String get save => 'Kaydet';

  @override
  String get testConnection => 'Bağlantıyı Test Et';

  @override
  String get syncBookmarks => 'Yer İmlerini Senkronize Et';

  @override
  String version(String appVersion) {
    return 'Sürüm $appVersion';
  }

  @override
  String get authorBy => 'Joe Mild tarafından';

  @override
  String get aboutDescription =>
      'GitSyncMarks için mobil uygulama – GitHub deposundaki yer imlerinizi görüntüleyin ve tarayıcınızda açın.';

  @override
  String get projects => 'Projeler';

  @override
  String get formatFromGitSyncMarks =>
      'Yer imi formatı GitSyncMarks\'tan gelmektedir.';

  @override
  String get gitSyncMarksDesc =>
      'GitSyncMarks\'a dayalı – çift yönlü yer imi senkronizasyonu için tarayıcı uzantısı. Bu proje GitSyncMarks referans alınarak geliştirilmiştir.';

  @override
  String get licenseMit => 'Lisans: MIT';

  @override
  String get quickGuide => 'Hızlı Kılavuz';

  @override
  String get help1Title => '1. Token kurulumu';

  @override
  String get help1Body =>
      'Bir GitHub Personal Access Token (PAT) oluşturun. Klasik PAT: Kapsam \'repo\'. Fine-grained: Contents Read. Oluştur: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. Depoyu bağlayın';

  @override
  String get help2Body =>
      'Ayarlar\'da Owner, Repo adı ve Branch\'i girin. Deponuz GitSyncMarks formatını takip etmelidir: kök klasörler toolbar ve other (tarayıcı uzantısının oluşturduğu, ör. 2.7.x), her birinde _order.json ve yer imi başına bir JSON dosyası.';

  @override
  String get help3Title => '3. Bağlantıyı Test Edin';

  @override
  String get help3Body =>
      'Token ve depo erişimini doğrulamak için \"Test Connection\"a tıklayın. Başarılıysa, mevcut kök klasörler gösterilir.';

  @override
  String get help4Title => '4. Klasörleri seçin';

  @override
  String get help4Body =>
      'Hangi kök klasörlerin görüntüleneceğini seçin (örn. toolbar, other). Boş seçim = hepsi. En az bir seçili = yalnızca bu klasörler.';

  @override
  String get help5Title => '5. Senkronize Edin';

  @override
  String get help5Body =>
      'Yer imlerini yüklemek için \"Sync Bookmarks\"a tıklayın. Ana ekranda yenilemek için aşağı çekin.';

  @override
  String get whichRepoFormat => 'Hangi depo formatı?';

  @override
  String get repoFormatDescription =>
      'Depo GitSyncMarks formatını takip etmelidir: Base Path (örn. \"bookmarks\") ve alt klasörler toolbar ve other (uzantı menu/mobile’ı kök olarak eşitlemez). Her klasörde _order.json ve title, url içeren JSON dosyaları. GitSyncMarks tarayıcı uzantısı (örn. 2.7.x) ile uyumludur.';

  @override
  String get support => 'Destek';

  @override
  String get supportText =>
      'Sorular veya hata mesajları? Proje deposunda bir issue açın.';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (GitHub Issues)';

  @override
  String get profiles => 'Profiller';

  @override
  String get profile => 'Profil';

  @override
  String get activeProfile => 'Aktif Profil';

  @override
  String get addProfile => 'Profil Ekle';

  @override
  String get renameProfile => 'Profili Yeniden Adlandır';

  @override
  String get deleteProfile => 'Profili Sil';

  @override
  String deleteProfileConfirm(String name) {
    return '\"$name\" profili silinsin mi?';
  }

  @override
  String get profileName => 'Profil adı';

  @override
  String profileCount(int count, int max) {
    return '$count/$max profil';
  }

  @override
  String maxProfilesReached(int max) {
    return 'Maksimum profil sayısına ulaşıldı ($max)';
  }

  @override
  String profileAdded(String name) {
    return '\"$name\" profili eklendi';
  }

  @override
  String profileRenamed(String name) {
    return 'Profil \"$name\" olarak yeniden adlandırıldı';
  }

  @override
  String get profileDeleted => 'Profil silindi';

  @override
  String get cannotDeleteLastProfile => 'Son profil silinemez';

  @override
  String get importExport => 'İçe / Dışa Aktar';

  @override
  String get importSettings => 'Ayarları İçe Aktar';

  @override
  String get exportSettings => 'Ayarları Dışa Aktar';

  @override
  String get importSettingsDesc =>
      'GitSyncMarks ayar dosyasından (JSON) profilleri içe aktar';

  @override
  String get exportSettingsDesc =>
      'Tüm profilleri GitSyncMarks ayar dosyası olarak dışa aktar';

  @override
  String importSuccess(int count) {
    return '$count profil içe aktarıldı';
  }

  @override
  String importFailed(String error) {
    return 'İçe aktarma başarısız: $error';
  }

  @override
  String importConfirm(int count) {
    return '$count profil içe aktarılsın mı? Tüm mevcut profiller değiştirilecektir.';
  }

  @override
  String get exportSuccess => 'Ayarlar dışa aktarıldı';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get rename => 'Yeniden Adlandır';

  @override
  String get add => 'Ekle';

  @override
  String get import_ => 'İçe Aktar';

  @override
  String get replace => 'Değiştir';

  @override
  String get bookmarks => 'Yer İmleri';

  @override
  String get info => 'Bilgi';

  @override
  String get connection => 'Bağlantı';

  @override
  String get folders => 'Klasörler';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => 'Senkronize Et';

  @override
  String get tabFiles => 'Dosyalar';

  @override
  String get tabGeneral => 'Genel';

  @override
  String get tabHelp => 'Yardım';

  @override
  String get tabAbout => 'Hakkında';

  @override
  String get subTabProfile => 'Profil';

  @override
  String get subTabConnection => 'Bağlantı';

  @override
  String get subTabExportImport => 'Dışa / İçe Aktar';

  @override
  String get subTabSettings => 'Ayarlar';

  @override
  String get searchPlaceholder => 'Yer imlerini ara...';

  @override
  String noSearchResults(String query) {
    return '\"$query\" için sonuç yok';
  }

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String get automaticSync => 'Otomatik senkronizasyon';

  @override
  String get autoSyncActive => 'Otomatik senkronizasyon aktif';

  @override
  String get autoSyncDisabled => 'Otomatik senkronizasyon devre dışı';

  @override
  String nextSyncIn(String time) {
    return 'Sonraki senkronizasyon $time içinde';
  }

  @override
  String get syncProfileRealtime => 'Gerçek zamanlı';

  @override
  String get syncProfileFrequent => 'Sık';

  @override
  String get syncProfileNormal => 'Normal';

  @override
  String get syncProfilePowersave => 'Güç tasarrufu';

  @override
  String get syncProfileCustom => 'Özel';

  @override
  String get syncProfileMeaningTitle => 'Bu profiller ne anlama gelir:';

  @override
  String get syncProfileMeaningRealtime =>
      'Gerçek zamanlı: her dakika senkronize eder (en güncel, daha yüksek pil kullanımı).';

  @override
  String get syncProfileMeaningFrequent =>
      'Sık: her 5 dakikada senkronize eder (aktif kullanım için dengeli).';

  @override
  String get syncProfileMeaningNormal =>
      'Normal: her 15 dakikada senkronize eder (önerilen varsayılan).';

  @override
  String get syncProfileMeaningPowersave =>
      'Güç tasarrufu: her 60 dakikada senkronize eder (en düşük pil/ağ kullanımı).';

  @override
  String get syncProfileMeaningCustom =>
      'Özel: kendi aralığınızı dakika cinsinden belirleyin.';

  @override
  String get customSyncIntervalLabel => 'Özel senkronizasyon aralığı (dakika)';

  @override
  String get customSyncIntervalHint => '1 ile 1440 arasında bir değer girin';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return 'Lütfen $min ile $max dakika arasında geçerli bir aralık girin.';
  }

  @override
  String get syncCommit => 'Commit';

  @override
  String lastSynced(String time) {
    return 'Son senkronizasyon $time';
  }

  @override
  String get neverSynced => 'Hiç senkronize edilmedi';

  @override
  String get syncOnStart => 'Uygulama başlangıcında senkronize et';

  @override
  String get allowMoveReorder => 'Taşımaya ve yeniden sıralamaya izin ver';

  @override
  String get allowMoveReorderDesc =>
      'Sürükleme tutamaçları ve klasöre taşıma. Salt okunur görünüm için devre dışı bırakın.';

  @override
  String get allowMoveReorderDisable => 'Salt okunur (tutamaçları gizle)';

  @override
  String get allowMoveReorderEnable =>
      'Düzenlemeyi etkinleştir (tutamaçları göster)';

  @override
  String bookmarkCount(int count, int folders) {
    return '$folders klasörde $count yer imi';
  }

  @override
  String get syncNow => 'Şimdi Senkronize Et';

  @override
  String get addBookmark => 'Yer imi ekle';

  @override
  String get addBookmarkTitle => 'Yer İmi Ekle';

  @override
  String get bookmarkTitle => 'Yer imi başlığı';

  @override
  String get selectFolder => 'Klasör seç';

  @override
  String get exportBookmarks => 'Yer imlerini dışa aktar';

  @override
  String get settingsSyncToGit => 'Ayarları Git\'e senkronize et (şifreli)';

  @override
  String get settingsSyncPassword => 'Şifreleme şifresi';

  @override
  String get settingsSyncPasswordHint =>
      'Cihaz başına bir kez ayarlayın. Tüm cihazlarda aynı olmalıdır.';

  @override
  String get settingsSyncRememberPassword => 'Şifreyi hatırla';

  @override
  String get settingsSyncPasswordSaved =>
      'Şifre kaydedildi (Push/Pull için kullanılır)';

  @override
  String get settingsSyncClearPassword => 'Kayıtlı şifreyi temizle';

  @override
  String get settingsSyncSaveBtn => 'Şifreyi kaydet';

  @override
  String get settingsSyncPasswordMissing => 'Lütfen bir şifre girin.';

  @override
  String get settingsSyncWithBookmarks =>
      'Yer imi senkronizasyonunda ayarları da senkronize et';

  @override
  String get settingsSyncPush => 'Ayarları gönder';

  @override
  String get settingsSyncPull => 'Ayarları çek';

  @override
  String get settingsSyncModeLabel => 'Senkronizasyon modu (yalnızca bireysel)';

  @override
  String get settingsSyncModeGlobal =>
      'Global — tüm cihazlarda paylaşılan (eski, taşındı)';

  @override
  String get settingsSyncModeIndividual => 'Bireysel — yalnızca bu cihaz';

  @override
  String get settingsSyncImportTitle => 'Başka cihazdan içe aktar';

  @override
  String get settingsSyncLoadConfigs => 'Mevcut yapılandırmaları yükle';

  @override
  String get settingsSyncImport => 'İçe Aktar';

  @override
  String get settingsSyncImportEmpty => 'Cihaz yapılandırması bulunamadı';

  @override
  String get settingsSyncImportSuccess => 'Ayarlar başarıyla içe aktarıldı';

  @override
  String get reportIssue => 'Sorun Bildir';

  @override
  String get documentation => 'Belgeleme';

  @override
  String get voteBacklog => 'Kapsam listesine oy ver';

  @override
  String get discussions => 'Tartışmalar';

  @override
  String get moveUp => 'Yukarı taşı';

  @override
  String get moveDown => 'Aşağı taşı';

  @override
  String get shareLinkAddBookmark =>
      'Paylaşılan bağlantıyı yer imi olarak ekle';

  @override
  String get clearCache => 'Önbelleği temizle';

  @override
  String get clearCacheDesc =>
      'Önbelleğe alınmış yer imi verilerini kaldırın. GitHub yapılandırılmışsa senkronizasyon otomatik çalışır.';

  @override
  String get clearCacheSuccess => 'Önbellek temizlendi.';

  @override
  String get moveToFolder => 'Klasöre taşı';

  @override
  String get moveToFolderSuccess => 'Yer imi taşındı';

  @override
  String get moveToFolderFailed => 'Yer imi taşınamadı';

  @override
  String get deleteBookmark => 'Yer İmini Sil';

  @override
  String deleteBookmarkConfirm(String title) {
    return '\"$title\" yer imi silinsin mi?';
  }

  @override
  String get bookmarkDeleted => 'Yer imi silindi';

  @override
  String get orderUpdated => 'Sıralama güncellendi';

  @override
  String get rootFolder => 'Kök Klasör';

  @override
  String get rootFolderHelp =>
      'Alt klasörleri sekme olacak bir klasör seçin. Varsayılan tüm üst düzey klasörleri gösterir.';

  @override
  String get allFolders => 'Tüm Klasörler';

  @override
  String get selectRootFolder => 'Kök Klasör Seç';

  @override
  String get exportPasswordTitle => 'Dışa Aktarma Şifresi';

  @override
  String get exportPasswordHint => 'Şifresiz dışa aktarma için boş bırakın';

  @override
  String get importPasswordTitle => 'Şifreli Dosya';

  @override
  String get importPasswordHint => 'Şifreleme şifresini girin';

  @override
  String get importSettingsAction => 'Ayarları İçe Aktar';

  @override
  String get importingSettings => 'Ayarlar içe aktarılıyor…';

  @override
  String get orImportExisting => 'veya mevcut ayarları içe aktar';

  @override
  String get wrongPassword => 'Yanlış şifre. Lütfen tekrar deneyin.';

  @override
  String get showSecret => 'Gizliliği göster';

  @override
  String get hideSecret => 'Gizliliği gizle';

  @override
  String get export_ => 'Dışa Aktar';

  @override
  String get resetAll => 'Tüm verileri sıfırla';

  @override
  String get resetConfirmTitle => 'Uygulama Sıfırlansın mı?';

  @override
  String get resetConfirmMessage =>
      'Tüm profiller, ayarlar ve önbelleğe alınmış yer imleri silinecektir. Uygulama ilk durumuna dönecektir.';

  @override
  String get resetSuccess => 'Tüm veriler sıfırlandı';

  @override
  String get settingsSyncClientName => 'İstemci adı';

  @override
  String get settingsSyncClientNameHint =>
      'örn. base-android veya laptop-linux';

  @override
  String get settingsSyncClientNameRequired =>
      'Lütfen bireysel mod için bir istemci adı girin.';

  @override
  String get settingsSyncCreateBtn => 'İstemci ayarımı oluştur';

  @override
  String get generalLanguageTitle => 'Dil';

  @override
  String get generalThemeTitle => 'Tema';

  @override
  String get appLanguage => 'Uygulama dili';

  @override
  String get appTheme => 'Uygulama teması';

  @override
  String get appLanguageSystem => 'Sistem varsayılanı';

  @override
  String get appThemeSystem => 'Sistem varsayılanı';

  @override
  String get appThemeLight => 'Açık';

  @override
  String get appThemeDark => 'Koyu';

  @override
  String get appLanguageGerman => 'Almanca';

  @override
  String get appLanguageEnglish => 'İngilizce';

  @override
  String get appLanguageSpanish => 'İspanyolca';

  @override
  String get appLanguageFrench => 'Fransızca';

  @override
  String get basePathBrowse => 'Klasörlere göz at';

  @override
  String get basePathBrowseTitle => 'Depo klasörünü seçin';

  @override
  String get subTabFolders => 'Klasörler';

  @override
  String get appLanguagePortugueseBrazil => 'Portekizce (Brezilya)';

  @override
  String get appLanguageItalian => 'İtalyanca';

  @override
  String get appLanguageJapanese => 'Japonca';

  @override
  String get appLanguageChineseSimplified => 'Çince (Basitleştirilmiş)';

  @override
  String get appLanguageKorean => 'Korece';

  @override
  String get appLanguageRussian => 'Rusça';

  @override
  String get appLanguageTurkish => 'Türkçe';

  @override
  String get appLanguagePolish => 'Lehçe';
}
