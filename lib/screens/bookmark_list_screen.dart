import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/bookmark_node.dart';
import '../providers/bookmark_provider.dart';
import '../services/settings_crypto.dart';
import '../services/settings_import_export.dart';
import '../services/web_import_picker_stub.dart'
    if (dart.library.html) '../services/web_import_picker_web.dart';
import '../utils/favicon_utils.dart';
import 'settings_screen.dart';

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/app_icon.png', width: size, height: size);
  }
}

Future<void> _handleImport(
  BuildContext context, {
  bool isImporting = false,
  void Function(bool)? onImporting,
}) async {
  if (isImporting) return;
  final l = AppLocalizations.of(context)!;
  final importExport = SettingsImportExportService();
  try {
    final result = kIsWeb
        ? null
        : await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: false,
            withData: false,
          );
    WebPickedFile? webFallback;
    if (kIsWeb && (result == null || result.files.isEmpty)) {
      webFallback = await pickFileBytesWithWebFallback();
    }
    if ((result == null || result.files.isEmpty) && webFallback == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected.')),
        );
      }
      return;
    }
    final picked = result?.files.isNotEmpty == true ? result!.files.single : null;
    String content;
    if (kIsWeb) {
      final bytes = picked?.bytes ?? webFallback?.bytes;
      if (bytes == null) return;
      content = utf8.decode(bytes);
    } else {
      final path = picked?.path;
      if (path == null) return;
      content = await File(path).readAsString();
    }

    if (SettingsImportExportService.isEncrypted(content)) {
      if (!context.mounted) return;
      final controller = TextEditingController();
      final password = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.importPasswordTitle),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(hintText: l.importPasswordHint),
            autofocus: true,
            onSubmitted: (v) => Navigator.pop(ctx, v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: Text(l.import_),
            ),
          ],
        ),
      );
      if (password == null || password.isEmpty) return;
      try {
        content = await SettingsCrypto.decryptWithPassword(content, password);
      } on FormatException {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.wrongPassword),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
        return;
      }
    }

    if (!context.mounted) return;
    onImporting?.call(true);
    try {
      final parsed = importExport.parseSettingsJson(content);
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.importSettings),
          content: Text(l.importConfirm(parsed.profiles.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.replace),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      var activeId = parsed.activeProfileId;
      if (!parsed.profiles.any((p) => p.id == activeId)) {
        activeId = parsed.profiles.first.id;
      }
      final selected = parsed.profiles.firstWhere((p) => p.id == activeId);
      if (!selected.credentials.isValid) {
        for (final p in parsed.profiles) {
          if (p.credentials.isValid) {
            activeId = p.id;
            break;
          }
        }
      }
      if (!context.mounted) return;
      await context.read<BookmarkProvider>().replaceProfiles(
            parsed.profiles,
            activeId: activeId,
            triggerSync: false,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.importSuccess(parsed.profiles.length))),
        );
        final provider = context.read<BookmarkProvider>();
        if (provider.hasCredentials) {
          provider.syncBookmarks();
        }
      }
    } finally {
      onImporting?.call(false);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.importFailed(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }
}

class BookmarkListScreen extends StatefulWidget {
  const BookmarkListScreen({super.key});

  @override
  State<BookmarkListScreen> createState() => _BookmarkListScreenState();
}

class _BookmarkListScreenState extends State<BookmarkListScreen> {
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<BookmarkProvider>(
          builder: (context, provider, _) {
            if (provider.error != null) {
              return Scaffold(
                appBar: _buildAppBar(context, provider),
                body: _ErrorView(
                  message: provider.error!,
                  onRetry: () {
                    provider.clearError();
                    provider.syncBookmarks();
                  },
                ),
              );
            }

            if (!provider.hasCredentials) {
              return Scaffold(
                appBar: _buildAppBar(context, provider),
                body: _EmptyState(
                  onOpenSettings: null,
                  onImport: () => _handleImport(
                    context,
                    isImporting: _isImporting,
                    onImporting: (v) => setState(() => _isImporting = v),
                  ),
                ),
              );
            }

            if (provider.isLoading && !provider.hasBookmarks) {
              return Scaffold(
                appBar: _buildAppBar(context, provider),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            if (!provider.hasBookmarks) {
              return Scaffold(
                appBar: _buildAppBar(context, provider),
                body: _EmptyState(
                  hasCredentials: true,
                  onSync: () => provider.syncBookmarks(),
                  onOpenSettings: null,
                ),
              );
            }

            final folders = provider.filteredDisplayedRootFolders;
            final hasSearch = provider.searchQuery.trim().isNotEmpty;
            if (hasSearch && folders.isEmpty) {
              return Scaffold(
                appBar: _buildAppBar(context, provider),
                body: _SearchNoResultsView(
                  query: provider.searchQuery,
                  onClearSearch: () => provider.setSearchQuery(''),
                ),
              );
            }

            return _TabbedBookmarkView(
              folders: folders,
              provider: provider,
            );
          },
        ),
        if (_isImporting)
          Positioned.fill(
            child: ModalBarrier(dismissible: false),
          ),
        if (_isImporting)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.importingSettings),
              ],
            ),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, BookmarkProvider provider) {
    return AppBar(
      title: _ProfileDropdown(),
      centerTitle: false,
      actions: [
        if (provider.hasCredentials)
          IconButton(
            icon: provider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed:
                provider.isLoading ? null : () => provider.syncBookmarks(),
          ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          tooltip: AppLocalizations.of(context)!.settings,
        ),
      ],
    );
  }
}

// =============================================================================
// Tabbed bookmark view (shown when bookmarks exist)
// =============================================================================

class _TabbedBookmarkView extends StatefulWidget {
  const _TabbedBookmarkView({
    required this.folders,
    required this.provider,
  });

  final List<BookmarkFolder> folders;
  final BookmarkProvider provider;

  @override
  State<_TabbedBookmarkView> createState() => _TabbedBookmarkViewState();
}

class _TabbedBookmarkViewState extends State<_TabbedBookmarkView> {
  static const _editLockDuration = Duration(seconds: 60);

  late TextEditingController _searchController;
  bool _searchExpanded = false;
  Timer? _editLockTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.provider.searchQuery);
  }

  @override
  void didUpdateWidget(_TabbedBookmarkView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider.searchQuery != widget.provider.searchQuery &&
        _searchController.text != widget.provider.searchQuery) {
      _searchController.text = widget.provider.searchQuery;
    }
  }

  @override
  void dispose() {
    _editLockTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startEditLockTimer() {
    _editLockTimer?.cancel();
    _editLockTimer = Timer(_editLockDuration, () {
      if (mounted) {
        widget.provider.updateSyncSettings(allowMoveReorder: false);
      }
    });
  }

  void _cancelEditLockTimer() {
    _editLockTimer?.cancel();
    _editLockTimer = null;
  }

  void _onEditAction() {
    if (widget.provider.activeProfile?.allowMoveReorder ?? false) {
      _startEditLockTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final folders = widget.folders;
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final activeProfile = provider.activeProfile;
    final autoSyncEnabled = activeProfile?.autoSyncEnabled ?? false;
    final nextAt = provider.nextAutoSyncAt;

    return DefaultTabController(
      length: folders.isEmpty ? 1 : folders.length,
      child: Scaffold(
        appBar: AppBar(
          title: _ProfileDropdown(),
          centerTitle: false,
          actions: [
            IconButton(
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              onPressed:
                  provider.isLoading ? null : () => provider.syncBookmarks(),
            ),
            if (provider.hasCredentials)
              IconButton(
                icon: Icon(
                  (activeProfile?.allowMoveReorder ?? false)
                      ? Icons.reorder
                      : Icons.lock_outline,
                  color: (activeProfile?.allowMoveReorder ?? false)
                      ? null
                      : scheme.outline,
                ),
                onPressed: () {
                  final unlocking = !(activeProfile?.allowMoveReorder ?? false);
                  provider.updateSyncSettings(allowMoveReorder: unlocking);
                  if (unlocking) {
                    _startEditLockTimer();
                  } else {
                    _cancelEditLockTimer();
                  }
                },
                tooltip: (activeProfile?.allowMoveReorder ?? false)
                    ? l.allowMoveReorderDisable
                    : l.allowMoveReorderEnable,
              ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searchExpanded = true),
              tooltip: l.searchPlaceholder,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              tooltip: l.settings,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _StatusArea(provider: provider),
            ),
            if (folders.isNotEmpty)
              TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                tabs: folders
                    .map((f) => Tab(text: f.title))
                    .toList(),
              ),
            if (_searchExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l.searchPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _searchExpanded = false;
                          _searchController.clear();
                          provider.setSearchQuery('');
                        });
                      },
                    ),
                  ),
                  onChanged: (v) => provider.setSearchQuery(v),
                ),
              ),
            Expanded(
              child: folders.isEmpty
                  ? const SizedBox.shrink()
                  : TabBarView(
                      children: folders.map((folder) {
                        return RefreshIndicator(
                          onRefresh: () =>
                              provider.syncBookmarks().then((_) async {}),
                          child: _FolderContentList(
                            folder: folder,
                            provider: provider,
                            canReorder: provider.searchQuery.trim().isEmpty &&
                                (provider.activeProfile?.allowMoveReorder ?? false),
                            onEditAction: _onEditAction,
                          ),
                        );
                      }).toList(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: autoSyncEnabled
                          ? scheme.primary
                          : scheme.outline.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    autoSyncEnabled ? l.autoSyncActive : l.autoSyncDisabled,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.outline,
                        ),
                  ),
                  if (autoSyncEnabled && nextAt != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      l.nextSyncIn(_formatDuration(nextAt.difference(DateTime.now()))),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.outline,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    if (d.isNegative) return '0:00';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _StatusArea extends StatelessWidget {
  const _StatusArea({required this.provider});

  final BookmarkProvider provider;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final lastSync = provider.lastSyncTime;
    final count = provider.bookmarkCount;
    final folderCount = provider.displayedRootFolders.length;

    return Row(
      children: [
        Expanded(
          child: Text(
            lastSync != null
                ? l.lastSynced(_formatTimeAgo(lastSync))
                : l.neverSynced,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                ),
          ),
        ),
        Text(
          l.bookmarkCount(count, folderCount),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.outline,
              ),
        ),
      ],
    );
  }

  static String _formatTimeAgo(DateTime then) {
    final now = DateTime.now();
    final diff = now.difference(then);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }
}

class _SearchNoResultsView extends StatelessWidget {
  const _SearchNoResultsView({
    required this.query,
    required this.onClearSearch,
  });

  final String query;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.noSearchResults(query),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onClearSearch,
              child: Text(l.clearSearch),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Profile dropdown in AppBar
// =============================================================================

class _ProfileDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarkProvider>();
    final scheme = Theme.of(context).colorScheme;
    final activeProfile = provider.activeProfile;

    const appIcon = _AppIcon(size: 24);

    if (provider.profiles.length <= 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          appIcon,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.appTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return PopupMenuButton<String>(
      onSelected: (id) {
        if (id != provider.activeProfileId) {
          provider.switchProfile(id);
        }
      },
      offset: const Offset(0, 48),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          appIcon,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              activeProfile?.name ?? AppLocalizations.of(context)!.appTitle,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, color: scheme.outline, size: 20),
        ],
      ),
      itemBuilder: (context) => provider.profiles
          .map((p) => PopupMenuItem<String>(
                value: p.id,
                child: Row(
                  children: [
                    Icon(
                      p.id == provider.activeProfileId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: p.id == provider.activeProfileId
                          ? scheme.primary
                          : scheme.outline,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p.name,
                        style: TextStyle(
                          fontWeight: p.id == provider.activeProfileId
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// =============================================================================
// Folder content list (children of a root folder)
// =============================================================================

class _FolderContentList extends StatelessWidget {
  const _FolderContentList({
    required this.folder,
    required this.provider,
    this.canReorder = true,
    this.onEditAction,
  });

  final BookmarkFolder folder;
  final BookmarkProvider provider;
  final bool canReorder;
  final VoidCallback? onEditAction;

  @override
  Widget build(BuildContext context) {
    if (folder.children.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noBookmarksYet,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      );
    }

    if (!canReorder) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        itemCount: folder.children.length,
        itemBuilder: (context, index) {
          final node = folder.children[index];
          return switch (node) {
            BookmarkFolder() => _FolderTile(
                folder: node,
                level: 0,
                initiallyExpanded: index == 0,
                provider: provider,
                onEditAction: onEditAction,
              ),
            Bookmark() => _BookmarkTile(
                bookmark: node,
                sourceFolder: folder,
                provider: provider,
                onEditAction: onEditAction,
              ),
          };
        },
      );
    }

    return ReorderableListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      itemCount: folder.children.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        final adj = oldIndex < newIndex ? newIndex - 1 : newIndex;
        final folderPath = provider.getFolderPath(folder);
        if (folderPath != null) {
          onEditAction?.call();
          provider.reorderInFolder(folder, folderPath, oldIndex, adj).then((ok) {
            if (context.mounted) {
              final l = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? l.orderUpdated : (provider.error ?? l.moveToFolderFailed),
                  ),
                  backgroundColor: ok ? null : Theme.of(context).colorScheme.errorContainer,
                ),
              );
            }
          });
        }
      },
      itemBuilder: (context, index) {
        final node = folder.children[index];
        final key = switch (node) {
          Bookmark(:final url) => ValueKey('b-$index-$url'),
          BookmarkFolder(:final dirName, :final title) =>
            ValueKey('f-$index-${dirName ?? title}'),
        };
        return switch (node) {
          BookmarkFolder() => _FolderTile(
              key: key,
              folder: node,
              level: 0,
              initiallyExpanded: index == 0,
              reorderIndex: index,
              provider: provider,
              folderPath: provider.getFolderPath(node),
              canReorder: canReorder,
              onEditAction: onEditAction,
            ),
          Bookmark() => _ReorderableBookmarkTile(
              key: key,
              bookmark: node,
              index: index,
              sourceFolder: folder,
              provider: provider,
              onEditAction: onEditAction,
            ),
        };
      },
    );
  }
}

// =============================================================================
// Empty state
// =============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    this.hasCredentials = false,
    this.onSync,
    this.onOpenSettings,
    this.onImport,
  });

  final bool hasCredentials;
  final VoidCallback? onSync;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const _AppIcon(size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              l.noBookmarksYet,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              hasCredentials ? l.tapSyncToFetch : l.configureInSettings,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (hasCredentials && onSync != null)
              FilledButton.icon(
                onPressed: onSync,
                icon: const Icon(Icons.sync, size: 18),
                label: Text(l.sync),
              ),
            if (!hasCredentials && onImport != null) ...[
              const SizedBox(height: 8),
              Text(
                l.orImportExisting,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.outline,
                    ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.file_download, size: 18),
                label: Text(l.importSettingsAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Error view
// =============================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: scheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.error,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Move to folder dialog
// =============================================================================

void _showMoveToFolderDialog(
  BuildContext context,
  Bookmark bookmark,
  BookmarkFolder sourceFolder,
  BookmarkProvider provider,
) {
  final l = AppLocalizations.of(context)!;
  final rootFolders = provider.rootFolders;

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.selectFolder),
      content: SizedBox(
        width: double.maxFinite,
        child: _FolderPickerList(
          folders: rootFolders,
          sourceFolder: sourceFolder,
          onSelect: (target) async {
            Navigator.of(context).pop();
            final ok = await provider.moveBookmarkToFolder(
              bookmark,
              sourceFolder,
              target,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? l.moveToFolderSuccess : (provider.error ?? l.moveToFolderFailed),
                  ),
                  backgroundColor: ok ? null : Theme.of(context).colorScheme.errorContainer,
                ),
              );
            }
          },
        ),
      ),
    ),
  );
}

class _FolderPickerList extends StatelessWidget {
  const _FolderPickerList({
    required this.folders,
    required this.sourceFolder,
    required this.onSelect,
    this.depth = 0,
  });

  final List<BookmarkFolder> folders;
  final BookmarkFolder? sourceFolder;
  final void Function(BookmarkFolder) onSelect;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return ListView(
      shrinkWrap: true,
      children: folders.map((f) {
        final isSource = identical(f, sourceFolder);
        final hasSubfolders = f.children.any((c) => c is BookmarkFolder);
        final childFolders = f.children.whereType<BookmarkFolder>().toList();

        if (hasSubfolders && childFolders.isNotEmpty) {
          return ExpansionTile(
            leading: Icon(Icons.folder, color: scheme.primary, size: 22),
            title: Row(
              children: [
                Expanded(child: Text(f.title)),
                if (!isSource)
                  TextButton(
                    onPressed: () => onSelect(f),
                    child: Text(l.selectFolder),
                  ),
              ],
            ),
            children: [
              _FolderPickerList(
                folders: childFolders,
                sourceFolder: sourceFolder,
                onSelect: onSelect,
                depth: depth + 1,
              ),
            ],
          );
        }
        if (isSource) return null;
        return ListTile(
          leading: Icon(Icons.folder, color: scheme.primary, size: 22),
          title: Text(f.title),
          trailing: TextButton(
            onPressed: () => onSelect(f),
            child: Text(l.selectFolder),
          ),
        );
      }).whereType<Widget>().toList(),
    );
  }
}

// =============================================================================
// Folder tile (expandable)
// =============================================================================

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    super.key,
    required this.folder,
    this.level = 0,
    this.initiallyExpanded = false,
    this.reorderIndex,
    this.provider,
    this.folderPath,
    this.canReorder = false,
    this.onEditAction,
  });

  final BookmarkFolder folder;
  final int level;
  final bool initiallyExpanded;
  final int? reorderIndex;
  final BookmarkProvider? provider;
  final String? folderPath;
  final bool canReorder;
  final VoidCallback? onEditAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final folderIcon = Icon(
      initiallyExpanded || level == 0
          ? Icons.folder_open
          : Icons.folder,
      color: scheme.primary,
      size: 22,
    );
    final leading = reorderIndex != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReorderableDragStartListener(
                index: reorderIndex!,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.drag_handle,
                    color: scheme.outline,
                    size: 20,
                  ),
                ),
              ),
              folderIcon,
            ],
          )
        : folderIcon;

    return Card(
      margin: EdgeInsets.only(
        left: level > 0 ? 12.0 : 4,
        right: 4,
        top: 2,
        bottom: 2,
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: leading,
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        title: Text(
          folder.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        children: _buildFolderChildren(context),
      ),
    );
  }

  List<Widget> _buildFolderChildren(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (folder.children.isEmpty) return [];
    final p = provider;
    final path = folderPath;
    final doReorder = canReorder && p != null && path != null;

    if (!doReorder) {
      return folder.children.asMap().entries.map((entry) {
        return switch (entry.value) {
          BookmarkFolder() => _FolderTile(
              folder: entry.value as BookmarkFolder,
              level: level + 1,
              provider: p,
              onEditAction: onEditAction,
            ),
          Bookmark() => _BookmarkTile(
              bookmark: entry.value as Bookmark,
              sourceFolder: folder,
              provider: p,
              onEditAction: onEditAction,
            ),
        };
      }).toList();
    }

    final c = path;
    final prov = p;
    return [
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: folder.children.length,
        onReorder: (oldIndex, newIndex) {
          final adj = oldIndex < newIndex ? newIndex - 1 : newIndex;
          onEditAction?.call();
          prov.reorderInFolder(folder, c, oldIndex, adj).then((ok) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? l.orderUpdated : (prov.error ?? l.moveToFolderFailed),
                  ),
                  backgroundColor: ok ? null : Theme.of(context).colorScheme.errorContainer,
                ),
              );
            }
          });
        },
        itemBuilder: (context, index) {
          final node = folder.children[index];
          final key = switch (node) {
            Bookmark(:final url) => ValueKey('b-$index-$url'),
            BookmarkFolder(:final dirName, :final title) =>
              ValueKey('f-$index-${dirName ?? title}'),
          };
          return switch (node) {
            BookmarkFolder() => _FolderTile(
                key: key,
                folder: node,
                level: level + 1,
                provider: prov,
                folderPath: '$c/${node.dirName ?? node.title}',
                canReorder: true,
                reorderIndex: index,
                onEditAction: onEditAction,
              ),
            Bookmark() => _ReorderableBookmarkTile(
                key: key,
                bookmark: node,
                index: index,
                sourceFolder: folder,
                provider: prov,
                onEditAction: onEditAction,
              ),
          };
        },
      ),
    ];
  }
}

// =============================================================================
// Bookmark tile
// =============================================================================

class _ReorderableBookmarkTile extends StatelessWidget {
  const _ReorderableBookmarkTile({
    super.key,
    required this.bookmark,
    required this.index,
    required this.sourceFolder,
    required this.provider,
    this.onEditAction,
  });

  final Bookmark bookmark;
  final int index;
  final BookmarkFolder sourceFolder;
  final BookmarkProvider provider;
  final VoidCallback? onEditAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 8),
              child: Icon(
                Icons.drag_handle,
                color: scheme.outline,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: _BookmarkTile(
              bookmark: bookmark,
              sourceFolder: sourceFolder,
              provider: provider,
              onEditAction: onEditAction,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({
    super.key,
    required this.bookmark,
    this.sourceFolder,
    this.provider,
    this.onEditAction,
  });

  final Bookmark bookmark;
  final BookmarkFolder? sourceFolder;
  final BookmarkProvider? provider;
  final VoidCallback? onEditAction;

  Widget _buildLeading(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallbackIcon = Icon(Icons.link, color: scheme.primary, size: 20);
    final faviconUrl = faviconUrlForBookmark(bookmark.url);
    if (faviconUrl == null) {
      return SizedBox(width: 32, child: fallbackIcon);
    }
    return SizedBox(
      width: 32,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: faviconUrl,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          placeholder: (_, __) => fallbackIcon,
          errorWidget: (_, __, ___) => fallbackIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final hasCredentials = sourceFolder != null &&
        provider != null &&
        provider!.hasCredentials;
    final canMove = hasCredentials &&
        (provider!.activeProfile?.allowMoveReorder ?? false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: _buildLeading(context),
        title: Text(
          bookmark.title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          bookmark.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.outline,
              ),
        ),
        onTap: () => _openUrl(context, bookmark.url),
        onLongPress: hasCredentials
            ? () => showModalBottomSheet<void>(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (canMove)
                          ListTile(
                            leading: const Icon(Icons.drive_file_move),
                            title: Text(l.moveToFolder),
                            onTap: () {
                              Navigator.pop(ctx);
                              onEditAction?.call();
                              _showMoveToFolderDialog(
                                context,
                                bookmark,
                                sourceFolder!,
                                provider!,
                              );
                            },
                          ),
                        ListTile(
                          leading: Icon(Icons.delete_outline,
                              color: scheme.error),
                          title: Text(l.deleteBookmark,
                              style: TextStyle(color: scheme.error)),
                          onTap: () {
                            Navigator.pop(ctx);
                            onEditAction?.call();
                            _confirmDeleteBookmark(
                              context,
                              bookmark,
                              sourceFolder!,
                              provider!,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
            : null,
      ),
    );
  }

  Future<void> _confirmDeleteBookmark(
    BuildContext context,
    Bookmark bookmark,
    BookmarkFolder sourceFolder,
    BookmarkProvider provider,
  ) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteBookmark),
        content: Text(l.deleteBookmarkConfirm(bookmark.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final ok = await provider.deleteBookmark(bookmark, sourceFolder);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.bookmarkDeleted)),
        );
      }
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    AppLocalizations.of(context)!.couldNotOpenUrl(url))),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.couldNotOpenLink)),
        );
      }
    }
  }
}
