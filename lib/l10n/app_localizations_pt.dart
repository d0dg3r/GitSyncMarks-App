// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => 'Definições';

  @override
  String get about => 'Sobre';

  @override
  String get help => 'Ajuda';

  @override
  String get noBookmarksYet => 'Nenhum marcador ainda';

  @override
  String get tapSyncToFetch =>
      'Toque em Sincronizar para obter marcadores do GitHub';

  @override
  String get configureInSettings =>
      'Configure a ligação ao GitHub nas Definições';

  @override
  String get sync => 'Sincronizar';

  @override
  String get openSettings => 'Abrir Definições';

  @override
  String get error => 'Erro';

  @override
  String get retry => 'Tentar novamente';

  @override
  String couldNotOpenUrl(Object url) {
    return 'Não foi possível abrir $url';
  }

  @override
  String get couldNotOpenLink => 'Não foi possível abrir a ligação';

  @override
  String get pleaseFillTokenOwnerRepo =>
      'Por favor, preencha Token, Owner e Repo';

  @override
  String get settingsSaved => 'Definições guardadas';

  @override
  String get connectionSuccessful => 'Ligação bem-sucedida';

  @override
  String get connectionFailed => 'Falha na ligação';

  @override
  String get syncComplete => 'Sincronização concluída';

  @override
  String get syncFailed => 'Falha na sincronização';

  @override
  String get githubConnection => 'Ligação GitHub';

  @override
  String get gitConnection => 'Ligação Git';

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
  String get personalAccessToken => 'Token de Acesso Pessoal (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'PAT Clássico: Âmbito \'repo\'. Fine-grained: Contents Read. Crie em: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => 'Proprietário do Repositório';

  @override
  String get ownerHint => 'o-seu-utilizador-github';

  @override
  String get repositoryName => 'Nome do Repositório';

  @override
  String get repoHint => 'os-meus-marcadores';

  @override
  String get branch => 'Branch';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => 'Caminho Base';

  @override
  String get basePathHint => 'marcadores';

  @override
  String get displayedFolders => 'Pastas Apresentadas';

  @override
  String get displayedFoldersHelp =>
      'Disponível após Testar Ligação. Seleção vazia = todas as pastas. Pelo menos uma selecionada = apenas essas pastas.';

  @override
  String get save => 'Guardar';

  @override
  String get testConnection => 'Testar Ligação';

  @override
  String get syncBookmarks => 'Sincronizar Marcadores';

  @override
  String version(String appVersion) {
    return 'Versão $appVersion';
  }

  @override
  String get authorBy => 'Por Joe Mild';

  @override
  String get aboutDescription =>
      'Aplicação móvel para GitSyncMarks – veja marcadores do seu repositório GitHub e abra-os no browser.';

  @override
  String get projects => 'Projetos';

  @override
  String get formatFromGitSyncMarks =>
      'O formato de marcadores provém do GitSyncMarks.';

  @override
  String get gitSyncMarksDesc =>
      'Baseado no GitSyncMarks – a extensão de browser para sincronização bidirecional de marcadores. Este projeto foi desenvolvido com GitSyncMarks como referência.';

  @override
  String get licenseMit => 'Licença: MIT';

  @override
  String get quickGuide => 'Guia Rápido';

  @override
  String get help1Title => '1. Configurar token';

  @override
  String get help1Body =>
      'Crie um GitHub Personal Access Token (PAT). PAT Clássico: Âmbito \'repo\'. Fine-grained: Contents Read. Crie em: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. Ligar repositório';

  @override
  String get help2Body =>
      'Introduza Owner, nome do Repo e Branch nas Definições. O repositório deve seguir o formato GitSyncMarks: pastas raiz toolbar e other (como criadas pela extensão do navegador, ex. 2.7.x), cada uma com _order.json e um ficheiro JSON por marcador.';

  @override
  String get help3Title => '3. Testar Ligação';

  @override
  String get help3Body =>
      'Clique em \"Test Connection\" para verificar o token e o acesso ao repositório. Em caso de sucesso, as pastas raiz disponíveis são apresentadas.';

  @override
  String get help4Title => '4. Selecionar pastas';

  @override
  String get help4Body =>
      'Escolha quais as pastas raiz a apresentar (ex. toolbar, other). Seleção vazia = todas. Pelo menos uma selecionada = apenas essas pastas.';

  @override
  String get help5Title => '5. Sincronizar';

  @override
  String get help5Body =>
      'Clique em \"Sync Bookmarks\" para carregar os marcadores. Puxe para atualizar no ecrã principal.';

  @override
  String get whichRepoFormat => 'Qual o formato do repositório?';

  @override
  String get repoFormatDescription =>
      'O repositório deve seguir o formato GitSyncMarks: Caminho Base (ex. \"bookmarks\") com subpastas toolbar e other (a extensão não sincroniza menu ou mobile como raiz). Cada pasta tem _order.json e ficheiros JSON com title e url. Compatível com a extensão GitSyncMarks (ex. 2.7.x).';

  @override
  String get support => 'Suporte';

  @override
  String get supportText =>
      'Dúvidas ou mensagens de erro? Abra um issue no repositório do projeto.';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (GitHub Issues)';

  @override
  String get profiles => 'Perfis';

  @override
  String get profile => 'Perfil';

  @override
  String get activeProfile => 'Perfil Ativo';

  @override
  String get addProfile => 'Adicionar Perfil';

  @override
  String get renameProfile => 'Renomear Perfil';

  @override
  String get deleteProfile => 'Eliminar Perfil';

  @override
  String deleteProfileConfirm(String name) {
    return 'Eliminar perfil \"$name\"?';
  }

  @override
  String get profileName => 'Nome do perfil';

  @override
  String profileCount(int count, int max) {
    return '$count/$max perfis';
  }

  @override
  String maxProfilesReached(int max) {
    return 'Número máximo de perfis atingido ($max)';
  }

  @override
  String profileAdded(String name) {
    return 'Perfil \"$name\" adicionado';
  }

  @override
  String profileRenamed(String name) {
    return 'Perfil renomeado para \"$name\"';
  }

  @override
  String get profileDeleted => 'Perfil eliminado';

  @override
  String get cannotDeleteLastProfile =>
      'Não é possível eliminar o último perfil';

  @override
  String get importExport => 'Importar / Exportar';

  @override
  String get importSettings => 'Importar Definições';

  @override
  String get exportSettings => 'Exportar Definições';

  @override
  String get importSettingsDesc =>
      'Importar perfis de um ficheiro de definições GitSyncMarks (JSON)';

  @override
  String get exportSettingsDesc =>
      'Exportar todos os perfis como ficheiro de definições GitSyncMarks';

  @override
  String importSuccess(int count) {
    return '$count perfil(s) importado(s)';
  }

  @override
  String importFailed(String error) {
    return 'Falha na importação: $error';
  }

  @override
  String importConfirm(int count) {
    return 'Importar $count perfil(s)? Todos os perfis existentes serão substituídos.';
  }

  @override
  String get exportSuccess => 'Definições exportadas';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get rename => 'Renomear';

  @override
  String get add => 'Adicionar';

  @override
  String get import_ => 'Importar';

  @override
  String get replace => 'Substituir';

  @override
  String get bookmarks => 'Marcadores';

  @override
  String get info => 'Informações';

  @override
  String get connection => 'Ligação';

  @override
  String get folders => 'Pastas';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => 'Sincronizar';

  @override
  String get tabFiles => 'Ficheiros';

  @override
  String get tabGeneral => 'Geral';

  @override
  String get tabHelp => 'Ajuda';

  @override
  String get tabAbout => 'Sobre';

  @override
  String get subTabProfile => 'Perfil';

  @override
  String get subTabConnection => 'Ligação';

  @override
  String get subTabExportImport => 'Exportar / Importar';

  @override
  String get subTabSettings => 'Definições';

  @override
  String get searchPlaceholder => 'Pesquisar marcadores...';

  @override
  String noSearchResults(String query) {
    return 'Sem resultados para \"$query\"';
  }

  @override
  String get clearSearch => 'Limpar pesquisa';

  @override
  String get automaticSync => 'Sincronização automática';

  @override
  String get autoSyncActive => 'Sincronização automática ativa';

  @override
  String get autoSyncDisabled => 'Sincronização automática desativada';

  @override
  String nextSyncIn(String time) {
    return 'Próxima sincronização em $time';
  }

  @override
  String get syncProfileRealtime => 'Tempo real';

  @override
  String get syncProfileFrequent => 'Frequente';

  @override
  String get syncProfileNormal => 'Normal';

  @override
  String get syncProfilePowersave => 'Poupança de energia';

  @override
  String get syncProfileCustom => 'Personalizado';

  @override
  String get syncProfileMeaningTitle => 'O que estes perfis significam:';

  @override
  String get syncProfileMeaningRealtime =>
      'Tempo real: sincroniza a cada minuto (melhor atualização, maior uso de bateria).';

  @override
  String get syncProfileMeaningFrequent =>
      'Frequente: sincroniza a cada 5 minutos (equilibrado para uso ativo).';

  @override
  String get syncProfileMeaningNormal =>
      'Normal: sincroniza a cada 15 minutos (predefinição recomendada).';

  @override
  String get syncProfileMeaningPowersave =>
      'Poupança de energia: sincroniza a cada 60 minutos (menor uso de bateria/rede).';

  @override
  String get syncProfileMeaningCustom =>
      'Personalizado: escolha o seu próprio intervalo em minutos.';

  @override
  String get customSyncIntervalLabel =>
      'Intervalo personalizado de sincronização (minutos)';

  @override
  String get customSyncIntervalHint => 'Introduza um valor entre 1 e 1440';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return 'Introduza um intervalo válido entre $min e $max minutos.';
  }

  @override
  String get syncCommit => 'Commit';

  @override
  String lastSynced(String time) {
    return 'Última sincronização $time';
  }

  @override
  String get neverSynced => 'Nunca sincronizado';

  @override
  String get syncOnStart => 'Sincronizar ao iniciar a aplicação';

  @override
  String get allowMoveReorder => 'Permitir mover e reordenar';

  @override
  String get allowMoveReorderDesc =>
      'Alças de arrastar e mover para pasta. Desative para visualização só de leitura.';

  @override
  String get allowMoveReorderDisable => 'Só de leitura (ocultar alças)';

  @override
  String get allowMoveReorderEnable => 'Ativar edição (mostrar alças)';

  @override
  String bookmarkCount(int count, int folders) {
    return '$count marcadores em $folders pastas';
  }

  @override
  String get syncNow => 'Sincronizar Agora';

  @override
  String get addBookmark => 'Adicionar marcador';

  @override
  String get addBookmarkTitle => 'Adicionar Marcador';

  @override
  String get bookmarkTitle => 'Título do marcador';

  @override
  String get selectFolder => 'Selecionar pasta';

  @override
  String get exportBookmarks => 'Exportar marcadores';

  @override
  String get settingsSyncToGit => 'Sincronizar definições com Git (encriptado)';

  @override
  String get settingsSyncPassword => 'Palavra-passe de encriptação';

  @override
  String get settingsSyncPasswordHint =>
      'Definir uma vez por dispositivo. Deve ser a mesma em todos os dispositivos.';

  @override
  String get settingsSyncRememberPassword => 'Lembrar palavra-passe';

  @override
  String get settingsSyncPasswordSaved =>
      'Palavra-passe guardada (usada para Push/Pull)';

  @override
  String get settingsSyncClearPassword => 'Limpar palavra-passe guardada';

  @override
  String get settingsSyncSaveBtn => 'Guardar palavra-passe';

  @override
  String get settingsSyncPasswordMissing =>
      'Por favor, introduza uma palavra-passe.';

  @override
  String get settingsSyncWithBookmarks =>
      'Sincronizar definições ao sincronizar marcadores';

  @override
  String get settingsSyncPush => 'Enviar definições';

  @override
  String get settingsSyncPull => 'Receber definições';

  @override
  String get settingsSyncModeLabel =>
      'Modo de sincronização (apenas individual)';

  @override
  String get settingsSyncModeGlobal =>
      'Global — partilhado em todos os dispositivos (legado, migrado)';

  @override
  String get settingsSyncModeIndividual =>
      'Individual — apenas este dispositivo';

  @override
  String get settingsSyncImportTitle => 'Importar de outro dispositivo';

  @override
  String get settingsSyncLoadConfigs => 'Carregar configurações disponíveis';

  @override
  String get settingsSyncImport => 'Importar';

  @override
  String get settingsSyncImportEmpty =>
      'Nenhuma configuração de dispositivo encontrada';

  @override
  String get settingsSyncImportSuccess => 'Definições importadas com sucesso';

  @override
  String get reportIssue => 'Reportar Problema';

  @override
  String get documentation => 'Documentação';

  @override
  String get voteBacklog => 'Votar no backlog';

  @override
  String get discussions => 'Discussões';

  @override
  String get moveUp => 'Mover para cima';

  @override
  String get moveDown => 'Mover para baixo';

  @override
  String get shareLinkAddBookmark =>
      'Adicionar ligação partilhada como marcador';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get clearCacheDesc =>
      'Remover dados de marcadores em cache. A sincronização será executada automaticamente se o GitHub estiver configurado.';

  @override
  String get clearCacheSuccess => 'Cache limpa.';

  @override
  String get moveToFolder => 'Mover para pasta';

  @override
  String get moveToFolderSuccess => 'Marcador movido';

  @override
  String get moveToFolderFailed => 'Falha ao mover marcador';

  @override
  String get deleteBookmark => 'Eliminar Marcador';

  @override
  String deleteBookmarkConfirm(String title) {
    return 'Eliminar marcador \"$title\"?';
  }

  @override
  String get bookmarkDeleted => 'Marcador eliminado';

  @override
  String get orderUpdated => 'Ordem atualizada';

  @override
  String get rootFolder => 'Pasta Raiz';

  @override
  String get rootFolderHelp =>
      'Selecione uma pasta cujas subpastas se tornam os separadores. Por defeito mostra todas as pastas de nível superior.';

  @override
  String get allFolders => 'Todas as Pastas';

  @override
  String get selectRootFolder => 'Selecionar Pasta Raiz';

  @override
  String get exportPasswordTitle => 'Palavra-passe de Exportação';

  @override
  String get exportPasswordHint =>
      'Deixe vazio para exportação sem encriptação';

  @override
  String get importPasswordTitle => 'Ficheiro Encriptado';

  @override
  String get importPasswordHint => 'Introduza a palavra-passe de encriptação';

  @override
  String get importSettingsAction => 'Importar Definições';

  @override
  String get importingSettings => 'A importar definições…';

  @override
  String get orImportExisting => 'ou importar definições existentes';

  @override
  String get wrongPassword =>
      'Palavra-passe incorreta. Por favor, tente novamente.';

  @override
  String get showSecret => 'Mostrar segredo';

  @override
  String get hideSecret => 'Ocultar segredo';

  @override
  String get export_ => 'Exportar';

  @override
  String get resetAll => 'Repor todos os dados';

  @override
  String get resetConfirmTitle => 'Repor Aplicação?';

  @override
  String get resetConfirmMessage =>
      'Todos os perfis, definições e marcadores em cache serão eliminados. A aplicação voltará ao estado inicial.';

  @override
  String get resetSuccess => 'Todos os dados foram repostos';

  @override
  String get settingsSyncClientName => 'Nome do cliente';

  @override
  String get settingsSyncClientNameHint => 'ex. base-android ou laptop-linux';

  @override
  String get settingsSyncClientNameRequired =>
      'Por favor, introduza um nome de cliente para o modo individual.';

  @override
  String get settingsSyncCreateBtn => 'Criar a minha definição de cliente';

  @override
  String get generalLanguageTitle => 'Idioma';

  @override
  String get generalThemeTitle => 'Tema';

  @override
  String get appLanguage => 'Idioma da aplicação';

  @override
  String get appTheme => 'Tema da aplicação';

  @override
  String get appLanguageSystem => 'Predefinição do sistema';

  @override
  String get appThemeSystem => 'Predefinição do sistema';

  @override
  String get appThemeLight => 'Claro';

  @override
  String get appThemeDark => 'Escuro';

  @override
  String get appLanguageGerman => 'Alemão';

  @override
  String get appLanguageEnglish => 'Inglês';

  @override
  String get appLanguageSpanish => 'Espanhol';

  @override
  String get appLanguageFrench => 'Francês';

  @override
  String get basePathBrowse => 'Navegar pastas';

  @override
  String get basePathBrowseTitle => 'Selecionar pasta do repositório';

  @override
  String get subTabFolders => 'Pastas';

  @override
  String get appLanguagePortugueseBrazil => 'Português (Brasil)';

  @override
  String get appLanguageItalian => 'Italiano';

  @override
  String get appLanguageJapanese => 'Japonês';

  @override
  String get appLanguageChineseSimplified => 'Chinês (Simplificado)';

  @override
  String get appLanguageKorean => 'Coreano';

  @override
  String get appLanguageRussian => 'Russo';

  @override
  String get appLanguageTurkish => 'Turco';

  @override
  String get appLanguagePolish => 'Polaco';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'GitSyncMarks';

  @override
  String get settings => 'Configurações';

  @override
  String get about => 'Sobre';

  @override
  String get help => 'Ajuda';

  @override
  String get noBookmarksYet => 'Nenhum favorito ainda';

  @override
  String get tapSyncToFetch =>
      'Toque em Sincronizar para buscar favoritos do GitHub';

  @override
  String get configureInSettings =>
      'Configure a conexão GitHub nas Configurações';

  @override
  String get sync => 'Sincronizar';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get error => 'Erro';

  @override
  String get retry => 'Tentar novamente';

  @override
  String couldNotOpenUrl(Object url) {
    return 'Não foi possível abrir $url';
  }

  @override
  String get couldNotOpenLink => 'Não foi possível abrir o link';

  @override
  String get pleaseFillTokenOwnerRepo =>
      'Por favor, preencha Token, Owner e Repo';

  @override
  String get settingsSaved => 'Configurações salvas';

  @override
  String get connectionSuccessful => 'Conexão bem-sucedida';

  @override
  String get connectionFailed => 'Falha na conexão';

  @override
  String get syncComplete => 'Sincronização concluída';

  @override
  String get syncFailed => 'Falha na sincronização';

  @override
  String get githubConnection => 'Conexão GitHub';

  @override
  String get gitConnection => 'Conexão Git';

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
  String get personalAccessToken => 'Token de Acesso Pessoal (PAT)';

  @override
  String get tokenHint => 'ghp_xxxxxxxxxxxxxxxxxxxx';

  @override
  String get tokenHelper =>
      'PAT Clássico: Escopo \'repo\'. Fine-grained: Contents Read. Crie em: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get repositoryOwner => 'Proprietário do Repositório';

  @override
  String get ownerHint => 'seu-usuario-github';

  @override
  String get repositoryName => 'Nome do Repositório';

  @override
  String get repoHint => 'meus-favoritos';

  @override
  String get branch => 'Branch';

  @override
  String get branchHint => 'main';

  @override
  String get basePath => 'Caminho Base';

  @override
  String get basePathHint => 'favoritos';

  @override
  String get displayedFolders => 'Pastas Exibidas';

  @override
  String get displayedFoldersHelp =>
      'Disponível após Testar Conexão. Seleção vazia = todas as pastas. Pelo menos uma selecionada = apenas essas pastas.';

  @override
  String get save => 'Salvar';

  @override
  String get testConnection => 'Testar Conexão';

  @override
  String get syncBookmarks => 'Sincronizar Favoritos';

  @override
  String version(String appVersion) {
    return 'Versão $appVersion';
  }

  @override
  String get authorBy => 'Por Joe Mild';

  @override
  String get aboutDescription =>
      'Aplicativo móvel para GitSyncMarks – visualize favoritos do seu repositório GitHub e abra-os no navegador.';

  @override
  String get projects => 'Projetos';

  @override
  String get formatFromGitSyncMarks =>
      'O formato de favoritos vem do GitSyncMarks.';

  @override
  String get gitSyncMarksDesc =>
      'Baseado no GitSyncMarks – a extensão de navegador para sincronização bidirecional de favoritos. Este projeto foi desenvolvido com GitSyncMarks como referência.';

  @override
  String get licenseMit => 'Licença: MIT';

  @override
  String get quickGuide => 'Guia Rápido';

  @override
  String get help1Title => '1. Configurar token';

  @override
  String get help1Body =>
      'Crie um GitHub Personal Access Token (PAT). PAT Clássico: Escopo \'repo\'. Fine-grained: Contents Read. Crie em: GitHub → Settings → Developer settings → Personal access tokens';

  @override
  String get help2Title => '2. Conectar repositório';

  @override
  String get help2Body =>
      'Insira Owner, nome do Repo e Branch nas Configurações. O repositório deve seguir o formato GitSyncMarks: pastas raiz toolbar e other (como criadas pela extensão do navegador, ex. 2.7.x), cada uma com _order.json e um arquivo JSON por favorito.';

  @override
  String get help3Title => '3. Testar Conexão';

  @override
  String get help3Body =>
      'Clique em \"Test Connection\" para verificar o token e o acesso ao repositório. Em caso de sucesso, as pastas raiz disponíveis são mostradas.';

  @override
  String get help4Title => '4. Selecionar pastas';

  @override
  String get help4Body =>
      'Escolha quais pastas raiz exibir (ex. toolbar, other). Seleção vazia = todas. Pelo menos uma selecionada = apenas essas pastas.';

  @override
  String get help5Title => '5. Sincronizar';

  @override
  String get help5Body =>
      'Clique em \"Sync Bookmarks\" para carregar os favoritos. Arraste para atualizar na tela principal.';

  @override
  String get whichRepoFormat => 'Qual formato de repositório?';

  @override
  String get repoFormatDescription =>
      'O repositório deve seguir o formato GitSyncMarks: Caminho Base (ex. \"bookmarks\") com subpastas toolbar e other (a extensão não sincroniza menu ou mobile como raiz). Cada pasta tem _order.json e arquivos JSON com title e url. Compatível com a extensão GitSyncMarks (ex. 2.7.x).';

  @override
  String get support => 'Suporte';

  @override
  String get supportText =>
      'Dúvidas ou mensagens de erro? Abra um issue no repositório do projeto.';

  @override
  String get gitSyncMarksAndroidIssues => 'GitSyncMarks-App (GitHub Issues)';

  @override
  String get profiles => 'Perfis';

  @override
  String get profile => 'Perfil';

  @override
  String get activeProfile => 'Perfil Ativo';

  @override
  String get addProfile => 'Adicionar Perfil';

  @override
  String get renameProfile => 'Renomear Perfil';

  @override
  String get deleteProfile => 'Excluir Perfil';

  @override
  String deleteProfileConfirm(String name) {
    return 'Excluir perfil \"$name\"?';
  }

  @override
  String get profileName => 'Nome do perfil';

  @override
  String profileCount(int count, int max) {
    return '$count/$max perfis';
  }

  @override
  String maxProfilesReached(int max) {
    return 'Número máximo de perfis atingido ($max)';
  }

  @override
  String profileAdded(String name) {
    return 'Perfil \"$name\" adicionado';
  }

  @override
  String profileRenamed(String name) {
    return 'Perfil renomeado para \"$name\"';
  }

  @override
  String get profileDeleted => 'Perfil excluído';

  @override
  String get cannotDeleteLastProfile =>
      'Não é possível excluir o último perfil';

  @override
  String get importExport => 'Importar / Exportar';

  @override
  String get importSettings => 'Importar Configurações';

  @override
  String get exportSettings => 'Exportar Configurações';

  @override
  String get importSettingsDesc =>
      'Importar perfis de um arquivo de configurações GitSyncMarks (JSON)';

  @override
  String get exportSettingsDesc =>
      'Exportar todos os perfis como arquivo de configurações GitSyncMarks';

  @override
  String importSuccess(int count) {
    return '$count perfil(s) importado(s)';
  }

  @override
  String importFailed(String error) {
    return 'Falha na importação: $error';
  }

  @override
  String importConfirm(int count) {
    return 'Importar $count perfil(s)? Todos os perfis existentes serão substituídos.';
  }

  @override
  String get exportSuccess => 'Configurações exportadas';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get rename => 'Renomear';

  @override
  String get add => 'Adicionar';

  @override
  String get import_ => 'Importar';

  @override
  String get replace => 'Substituir';

  @override
  String get bookmarks => 'Favoritos';

  @override
  String get info => 'Informações';

  @override
  String get connection => 'Conexão';

  @override
  String get folders => 'Pastas';

  @override
  String get tabGitHub => 'Git';

  @override
  String get tabSync => 'Sincronizar';

  @override
  String get tabFiles => 'Arquivos';

  @override
  String get tabGeneral => 'Geral';

  @override
  String get tabHelp => 'Ajuda';

  @override
  String get tabAbout => 'Sobre';

  @override
  String get subTabProfile => 'Perfil';

  @override
  String get subTabConnection => 'Conexão';

  @override
  String get subTabExportImport => 'Exportar / Importar';

  @override
  String get subTabSettings => 'Configurações';

  @override
  String get searchPlaceholder => 'Pesquisar favoritos...';

  @override
  String noSearchResults(String query) {
    return 'Nenhum resultado para \"$query\"';
  }

  @override
  String get clearSearch => 'Limpar pesquisa';

  @override
  String get automaticSync => 'Sincronização automática';

  @override
  String get autoSyncActive => 'Sincronização automática ativa';

  @override
  String get autoSyncDisabled => 'Sincronização automática desativada';

  @override
  String nextSyncIn(String time) {
    return 'Próxima sincronização em $time';
  }

  @override
  String get syncProfileRealtime => 'Tempo real';

  @override
  String get syncProfileFrequent => 'Frequente';

  @override
  String get syncProfileNormal => 'Normal';

  @override
  String get syncProfilePowersave => 'Economia de energia';

  @override
  String get syncProfileCustom => 'Personalizado';

  @override
  String get syncProfileMeaningTitle => 'O que esses perfis significam:';

  @override
  String get syncProfileMeaningRealtime =>
      'Tempo real: sincroniza a cada minuto (melhor atualização, maior uso de bateria).';

  @override
  String get syncProfileMeaningFrequent =>
      'Frequente: sincroniza a cada 5 minutos (equilibrado para uso ativo).';

  @override
  String get syncProfileMeaningNormal =>
      'Normal: sincroniza a cada 15 minutos (padrão recomendado).';

  @override
  String get syncProfileMeaningPowersave =>
      'Economia de energia: sincroniza a cada 60 minutos (menor uso de bateria/rede).';

  @override
  String get syncProfileMeaningCustom =>
      'Personalizado: escolha seu próprio intervalo em minutos.';

  @override
  String get customSyncIntervalLabel =>
      'Intervalo personalizado de sincronização (minutos)';

  @override
  String get customSyncIntervalHint => 'Insira um valor entre 1 e 1440';

  @override
  String customSyncIntervalErrorRange(int min, int max) {
    return 'Insira um intervalo válido entre $min e $max minutos.';
  }

  @override
  String get syncCommit => 'Commit';

  @override
  String lastSynced(String time) {
    return 'Última sincronização $time';
  }

  @override
  String get neverSynced => 'Nunca sincronizado';

  @override
  String get syncOnStart => 'Sincronizar ao iniciar o app';

  @override
  String get allowMoveReorder => 'Permitir mover e reordenar';

  @override
  String get allowMoveReorderDesc =>
      'Alças de arrastar e mover para pasta. Desative para visualização somente leitura.';

  @override
  String get allowMoveReorderDisable => 'Somente leitura (ocultar alças)';

  @override
  String get allowMoveReorderEnable => 'Ativar edição (mostrar alças)';

  @override
  String bookmarkCount(int count, int folders) {
    return '$count favoritos em $folders pastas';
  }

  @override
  String get syncNow => 'Sincronizar Agora';

  @override
  String get addBookmark => 'Adicionar favorito';

  @override
  String get addBookmarkTitle => 'Adicionar Favorito';

  @override
  String get bookmarkTitle => 'Título do favorito';

  @override
  String get selectFolder => 'Selecionar pasta';

  @override
  String get exportBookmarks => 'Exportar favoritos';

  @override
  String get settingsSyncToGit =>
      'Sincronizar configurações com Git (criptografado)';

  @override
  String get settingsSyncPassword => 'Senha de criptografia';

  @override
  String get settingsSyncPasswordHint =>
      'Definir uma vez por dispositivo. Deve ser a mesma em todos os dispositivos.';

  @override
  String get settingsSyncRememberPassword => 'Lembrar senha';

  @override
  String get settingsSyncPasswordSaved => 'Senha salva (usada para Push/Pull)';

  @override
  String get settingsSyncClearPassword => 'Limpar senha salva';

  @override
  String get settingsSyncSaveBtn => 'Salvar senha';

  @override
  String get settingsSyncPasswordMissing => 'Por favor, insira uma senha.';

  @override
  String get settingsSyncWithBookmarks =>
      'Sincronizar configurações ao sincronizar favoritos';

  @override
  String get settingsSyncPush => 'Enviar configurações';

  @override
  String get settingsSyncPull => 'Receber configurações';

  @override
  String get settingsSyncModeLabel =>
      'Modo de sincronização (somente individual)';

  @override
  String get settingsSyncModeGlobal =>
      'Global — compartilhado em todos os dispositivos (legado, migrado)';

  @override
  String get settingsSyncModeIndividual =>
      'Individual — somente este dispositivo';

  @override
  String get settingsSyncImportTitle => 'Importar de outro dispositivo';

  @override
  String get settingsSyncLoadConfigs => 'Carregar configurações disponíveis';

  @override
  String get settingsSyncImport => 'Importar';

  @override
  String get settingsSyncImportEmpty =>
      'Nenhuma configuração de dispositivo encontrada';

  @override
  String get settingsSyncImportSuccess =>
      'Configurações importadas com sucesso';

  @override
  String get reportIssue => 'Reportar Problema';

  @override
  String get documentation => 'Documentação';

  @override
  String get voteBacklog => 'Votar no backlog';

  @override
  String get discussions => 'Discussões';

  @override
  String get moveUp => 'Mover para cima';

  @override
  String get moveDown => 'Mover para baixo';

  @override
  String get shareLinkAddBookmark =>
      'Adicionar link compartilhado como favorito';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get clearCacheDesc =>
      'Remover dados de favoritos em cache. A sincronização será executada automaticamente se o GitHub estiver configurado.';

  @override
  String get clearCacheSuccess => 'Cache limpo.';

  @override
  String get moveToFolder => 'Mover para pasta';

  @override
  String get moveToFolderSuccess => 'Favorito movido';

  @override
  String get moveToFolderFailed => 'Falha ao mover favorito';

  @override
  String get deleteBookmark => 'Excluir Favorito';

  @override
  String deleteBookmarkConfirm(String title) {
    return 'Excluir favorito \"$title\"?';
  }

  @override
  String get bookmarkDeleted => 'Favorito excluído';

  @override
  String get orderUpdated => 'Ordem atualizada';

  @override
  String get rootFolder => 'Pasta Raiz';

  @override
  String get rootFolderHelp =>
      'Selecione uma pasta cujas subpastas se tornam as abas. O padrão mostra todas as pastas de nível superior.';

  @override
  String get allFolders => 'Todas as Pastas';

  @override
  String get selectRootFolder => 'Selecionar Pasta Raiz';

  @override
  String get exportPasswordTitle => 'Senha de Exportação';

  @override
  String get exportPasswordHint =>
      'Deixe vazio para exportação sem criptografia';

  @override
  String get importPasswordTitle => 'Arquivo Criptografado';

  @override
  String get importPasswordHint => 'Insira a senha de criptografia';

  @override
  String get importSettingsAction => 'Importar Configurações';

  @override
  String get importingSettings => 'Importando configurações…';

  @override
  String get orImportExisting => 'ou importar configurações existentes';

  @override
  String get wrongPassword => 'Senha incorreta. Por favor, tente novamente.';

  @override
  String get showSecret => 'Mostrar segredo';

  @override
  String get hideSecret => 'Ocultar segredo';

  @override
  String get export_ => 'Exportar';

  @override
  String get resetAll => 'Redefinir todos os dados';

  @override
  String get resetConfirmTitle => 'Redefinir App?';

  @override
  String get resetConfirmMessage =>
      'Todos os perfis, configurações e favoritos em cache serão excluídos. O app retornará ao estado inicial.';

  @override
  String get resetSuccess => 'Todos os dados foram redefinidos';

  @override
  String get settingsSyncClientName => 'Nome do cliente';

  @override
  String get settingsSyncClientNameHint => 'ex. base-android ou laptop-linux';

  @override
  String get settingsSyncClientNameRequired =>
      'Por favor, insira um nome de cliente para o modo individual.';

  @override
  String get settingsSyncCreateBtn => 'Criar minha configuração de cliente';

  @override
  String get generalLanguageTitle => 'Idioma';

  @override
  String get generalThemeTitle => 'Tema';

  @override
  String get appLanguage => 'Idioma do app';

  @override
  String get appTheme => 'Tema do app';

  @override
  String get appLanguageSystem => 'Padrão do sistema';

  @override
  String get appThemeSystem => 'Padrão do sistema';

  @override
  String get appThemeLight => 'Claro';

  @override
  String get appThemeDark => 'Escuro';

  @override
  String get appLanguageGerman => 'Alemão';

  @override
  String get appLanguageEnglish => 'Inglês';

  @override
  String get appLanguageSpanish => 'Espanhol';

  @override
  String get appLanguageFrench => 'Francês';

  @override
  String get basePathBrowse => 'Navegar pastas';

  @override
  String get basePathBrowseTitle => 'Selecionar pasta do repositório';

  @override
  String get subTabFolders => 'Pastas';

  @override
  String get appLanguagePortugueseBrazil => 'Português (Brasil)';

  @override
  String get appLanguageItalian => 'Italiano';

  @override
  String get appLanguageJapanese => 'Japonês';

  @override
  String get appLanguageChineseSimplified => 'Chinês (Simplificado)';

  @override
  String get appLanguageKorean => 'Coreano';

  @override
  String get appLanguageRussian => 'Russo';

  @override
  String get appLanguageTurkish => 'Turco';

  @override
  String get appLanguagePolish => 'Polonês';
}
