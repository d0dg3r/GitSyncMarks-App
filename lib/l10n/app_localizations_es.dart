// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => 'Ajustes';

  @override
  String get about => 'Acerca de';

  @override
  String get help => 'Ayuda';

  @override
  String get noBookmarksYet => 'Sin marcadores aún';

  @override
  String get tapSyncToFetch => 'Toca Sync para cargar marcadores desde GitHub';

  @override
  String get configureInSettings =>
      'Configura la conexión de GitHub en Ajustes';

  @override
  String get sync => 'Sync';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String couldNotOpenUrl(Object url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get pleaseFillTokenOwnerRepo =>
      'Por favor, completa Token, Owner y Repo';

  @override
  String get settingsSaved => 'Ajustes guardados';

  @override
  String get connectionSuccessful => 'Conexión exitosa';

  @override
  String get connectionFailed => 'Conexión fallida';

  @override
  String get syncComplete => 'Sync completado';

  @override
  String get syncFailed => 'Sync fallido';

  @override
  String get githubConnection => 'Conexión GitHub';

  @override
  String get personalAccessToken => 'Personal Access Token (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. Crear en: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => 'Propietario del repositorio';

  @override
  String get ownerHint => 'tu-usuario-github';

  @override
  String get repositoryName => 'Nombre del repositorio';

  @override
  String get repoHint => 'my-bookmarks';

  @override
  String get branch => 'Rama';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => 'Ruta base';

  @override
  String get basePathHint => 'bookmarks';

  @override
  String get displayedFolders => 'Carpetas mostradas';

  @override
  String get displayedFoldersHelp =>
      'Disponible después de Test Connection. Selección vacía = todas las carpetas. Al menos una seleccionada = solo esas carpetas.';

  @override
  String get save => 'Guardar';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get syncBookmarks => 'Sync Bookmarks';

  @override
  String version(String appVersion) {
    return 'Versión $appVersion';
  }

  @override
  String get authorBy => 'Por Joe Mild';

  @override
  String get aboutDescription =>
      'App móvil para GitSyncMarks – ver marcadores de tu repositorio GitHub y abrirlos en el navegador.';

  @override
  String get projects => 'Proyectos';

  @override
  String get formatFromGitSyncMarks =>
      'El formato de marcadores proviene de GitSyncMarks.';

  @override
  String get gitSyncMarksDesc =>
      'Basado en GitSyncMarks – la extensión del navegador para sincronización bidireccional de marcadores. Este proyecto se desarrolló con GitSyncMarks como referencia.';

  @override
  String get licenseMit => 'Licencia: MIT';

  @override
  String get quickGuide => 'Guía rápida';

  @override
  String get help1Title => '1. Configurar token';

  @override
  String get help1Body =>
      'Crea un GitHub Personal Access Token (PAT). Classic PAT: Scope \'repo\'. Fine-grained: Contents Read. Crear en: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. Conectar repositorio';

  @override
  String get help2Body =>
      'Introduce Owner, nombre del Repo y Branch en Ajustes. Tu repositorio debe seguir el formato GitSyncMarks (carpetas como toolbar, menu, other con archivos JSON por marcador).';

  @override
  String get help3Title => '3. Test Connection';

  @override
  String get help3Body =>
      'Haz clic en \"Test Connection\" para verificar el token y el acceso al repositorio. Si tiene éxito, se muestran las carpetas raíz disponibles.';

  @override
  String get help4Title => '4. Seleccionar carpetas';

  @override
  String get help4Body =>
      'Elige qué carpetas mostrar (ej. toolbar, mobile). Selección vacía = todas. Al menos una seleccionada = solo esas carpetas.';

  @override
  String get help5Title => '5. Sync';

  @override
  String get help5Body =>
      'Haz clic en \"Sync Bookmarks\" para cargar los marcadores. Pull-to-refresh en la pantalla principal recarga.';

  @override
  String get whichRepoFormat => '¿Qué formato de repositorio?';

  @override
  String get repoFormatDescription =>
      'El repositorio debe seguir el formato GitSyncMarks: Base Path (ej. \"bookmarks\") con subcarpetas como toolbar, menu, other, mobile. Cada carpeta tiene _order.json y archivos JSON por marcador con title y url.';

  @override
  String get support => 'Soporte';

  @override
  String get supportText =>
      '¿Preguntas o mensajes de error? Abre un issue en el repositorio del proyecto.';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-Mobile (GitHub Issues)';

  @override
  String get profiles => 'Perfiles';

  @override
  String get profile => 'Perfil';

  @override
  String get activeProfile => 'Perfil activo';

  @override
  String get addProfile => 'Añadir perfil';

  @override
  String get renameProfile => 'Renombrar perfil';

  @override
  String get deleteProfile => 'Eliminar perfil';

  @override
  String deleteProfileConfirm(String name) {
    return '¿Eliminar perfil \"$name\"?';
  }

  @override
  String get profileName => 'Nombre del perfil';

  @override
  String profileCount(int count, int max) {
    return '$count/$max perfiles';
  }

  @override
  String maxProfilesReached(int max) {
    return 'Número máximo de perfiles alcanzado ($max)';
  }

  @override
  String profileAdded(String name) {
    return 'Perfil \"$name\" añadido';
  }

  @override
  String profileRenamed(String name) {
    return 'Perfil renombrado a \"$name\"';
  }

  @override
  String get profileDeleted => 'Perfil eliminado';

  @override
  String get cannotDeleteLastProfile => 'No se puede eliminar el último perfil';

  @override
  String get importExport => 'Importar / Exportar';

  @override
  String get importSettings => 'Importar ajustes';

  @override
  String get exportSettings => 'Exportar ajustes';

  @override
  String get importSettingsDesc =>
      'Importar perfiles desde un archivo de ajustes GitSyncMarks (JSON)';

  @override
  String get exportSettingsDesc =>
      'Exportar todos los perfiles como archivo de ajustes GitSyncMarks';

  @override
  String importSuccess(int count) {
    return '$count perfil(es) importado(s)';
  }

  @override
  String importFailed(String error) {
    return 'Importación fallida: $error';
  }

  @override
  String importConfirm(int count) {
    return '¿Importar $count perfil(es)? Se reemplazarán todos los perfiles existentes.';
  }

  @override
  String get exportSuccess => 'Ajustes exportados';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get rename => 'Renombrar';

  @override
  String get add => 'Añadir';

  @override
  String get import_ => 'Importar';

  @override
  String get replace => 'Reemplazar';

  @override
  String get bookmarks => 'Marcadores';

  @override
  String get info => 'Info';

  @override
  String get connection => 'Conexión';

  @override
  String get folders => 'Carpetas';

  @override
  String get tabGitHub => 'GitHub';

  @override
  String get tabSync => 'Sync';

  @override
  String get tabFiles => 'Archivos';

  @override
  String get tabHelp => 'Ayuda';

  @override
  String get tabAbout => 'Acerca de';

  @override
  String get subTabProfile => 'Perfil';

  @override
  String get subTabConnection => 'Conexión';

  @override
  String get subTabExportImport => 'Exportar / Importar';

  @override
  String get subTabSettings => 'Ajustes';

  @override
  String get searchPlaceholder => 'Buscar marcadores...';

  @override
  String noSearchResults(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get automaticSync => 'Sincronización automática';

  @override
  String get autoSyncActive => 'Auto-sync activo';

  @override
  String get autoSyncDisabled => 'Auto-sync desactivado';

  @override
  String nextSyncIn(String time) {
    return 'Próximo sync en $time';
  }

  @override
  String get syncProfileRealtime => 'Tiempo real';

  @override
  String get syncProfileFrequent => 'Frecuente';

  @override
  String get syncProfileNormal => 'Normal';

  @override
  String get syncProfilePowersave => 'Ahorro de energía';

  @override
  String get syncProfileCustom => 'Personalizado';

  @override
  String lastSynced(String time) {
    return 'Última sincronización $time';
  }

  @override
  String get neverSynced => 'Nunca sincronizado';

  @override
  String get syncOnStart => 'Sync al iniciar la app';

  @override
  String get allowMoveReorder => 'Permitir mover y reordenar';

  @override
  String get allowMoveReorderDesc =>
      'Asas de arrastre y mover a carpeta. Desactivar para vista solo lectura.';

  @override
  String get allowMoveReorderDisable => 'Solo lectura (ocultar asas)';

  @override
  String get allowMoveReorderEnable => 'Activar edición (mostrar asas)';

  @override
  String bookmarkCount(int count, int folders) {
    return '$count marcadores en $folders carpetas';
  }

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get addBookmark => 'Añadir marcador';

  @override
  String get addBookmarkTitle => 'Añadir marcador';

  @override
  String get bookmarkTitle => 'Título del marcador';

  @override
  String get selectFolder => 'Seleccionar carpeta';

  @override
  String get exportBookmarks => 'Exportar marcadores';

  @override
  String get settingsSyncToGit => 'Sincronizar ajustes con Git (encriptado)';

  @override
  String get settingsSyncPassword => 'Contraseña de cifrado';

  @override
  String get settingsSyncPasswordHint =>
      'Establecer una vez por dispositivo. Debe ser la misma en todos los dispositivos.';

  @override
  String get settingsSyncRememberPassword => 'Recordar contraseña';

  @override
  String get settingsSyncPasswordSaved =>
      'Contraseña guardada (para Push/Pull)';

  @override
  String get settingsSyncClearPassword => 'Borrar contraseña guardada';

  @override
  String get settingsSyncSaveBtn => 'Guardar contraseña';

  @override
  String get settingsSyncPasswordMissing =>
      'Por favor, introduce la contraseña.';

  @override
  String get settingsSyncWithBookmarks => 'Sincronizar ajustes con marcadores';

  @override
  String get settingsSyncPush => 'Subir ajustes';

  @override
  String get settingsSyncPull => 'Cargar ajustes';

  @override
  String get settingsSyncModeLabel => 'Modo de sincronización';

  @override
  String get settingsSyncModeGlobal =>
      'Global — compartido en todos los dispositivos';

  @override
  String get settingsSyncModeIndividual => 'Individual — solo este dispositivo';

  @override
  String get settingsSyncImportTitle => 'Importar desde otro dispositivo';

  @override
  String get settingsSyncLoadConfigs => 'Cargar configuraciones disponibles';

  @override
  String get settingsSyncImport => 'Importar';

  @override
  String get settingsSyncImportEmpty =>
      'No se encontraron configuraciones de dispositivos';

  @override
  String get settingsSyncImportSuccess => 'Ajustes importados correctamente';

  @override
  String get reportIssue => 'Reportar problema';

  @override
  String get documentation => 'Documentación';

  @override
  String get voteBacklog => 'Votar en backlog';

  @override
  String get discussions => 'Discusiones';

  @override
  String get moveUp => 'Subir';

  @override
  String get moveDown => 'Bajar';

  @override
  String get shareLinkAddBookmark => 'Añadir enlace compartido como marcador';

  @override
  String get clearCache => 'Borrar caché';

  @override
  String get clearCacheDesc =>
      'Eliminar datos en caché. Se sincronizará automáticamente si GitHub está configurado.';

  @override
  String get clearCacheSuccess => 'Caché borrada.';

  @override
  String get moveToFolder => 'Mover a carpeta';

  @override
  String get moveToFolderSuccess => 'Marcador movido';

  @override
  String get moveToFolderFailed => 'Error al mover el marcador';

  @override
  String get deleteBookmark => 'Eliminar marcador';

  @override
  String deleteBookmarkConfirm(String title) {
    return '¿Eliminar marcador \"$title\"?';
  }

  @override
  String get bookmarkDeleted => 'Marcador eliminado';

  @override
  String get orderUpdated => 'Orden actualizado';

  @override
  String get rootFolder => 'Carpeta raíz';

  @override
  String get rootFolderHelp =>
      'Selecciona una carpeta cuyos subcarpetas se muestran como pestañas. Por defecto muestra todas las carpetas de nivel superior.';

  @override
  String get allFolders => 'Todas las carpetas';

  @override
  String get selectRootFolder => 'Seleccionar carpeta raíz';

  @override
  String get exportPasswordTitle => 'Contraseña de exportación';

  @override
  String get exportPasswordHint => 'Dejar vacío para exportación sin cifrar';

  @override
  String get importPasswordTitle => 'Archivo cifrado';

  @override
  String get importPasswordHint => 'Introduce la contraseña de cifrado';

  @override
  String get importSettingsAction => 'Importar ajustes';

  @override
  String get importingSettings => 'Importando ajustes…';

  @override
  String get orImportExisting => 'o importar ajustes existentes';

  @override
  String get wrongPassword => 'Contraseña incorrecta. Inténtalo de nuevo.';

  @override
  String get export_ => 'Exportar';

  @override
  String get resetAll => 'Restablecer todos los datos';

  @override
  String get resetConfirmTitle => '¿Restablecer la aplicación?';

  @override
  String get resetConfirmMessage =>
      'Se eliminarán todos los perfiles, ajustes y marcadores en caché. La aplicación volverá a su estado inicial.';

  @override
  String get resetSuccess => 'Todos los datos han sido restablecidos';
}
