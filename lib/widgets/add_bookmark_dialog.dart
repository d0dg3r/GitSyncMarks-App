import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/bookmark_provider.dart';

/// Dialog to add a shared URL as a bookmark.
/// User can edit title and select target folder.
class AddBookmarkDialog extends StatefulWidget {
  const AddBookmarkDialog({
    super.key,
    required this.url,
    this.initialTitle,
    required this.provider,
  });

  final String url;
  final String? initialTitle;
  final BookmarkProvider provider;

  @override
  State<AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<AddBookmarkDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _urlController;
  String? _selectedFolder;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _urlController = TextEditingController(text: widget.url);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  List<String> get _folderOptions {
    final creds = widget.provider.credentials;
    if (creds == null) return [];
    final names = widget.provider.availableRootFolderNames;
    if (names.isEmpty) return ['toolbar', 'other', 'menu', 'mobile'];
    return names;
  }

  String _folderPath(String folderName) {
    final creds = widget.provider.credentials!;
    return '${creds.basePath}/$folderName';
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.bookmarkTitle ?? 'Bookmark title')),
      );
      return;
    }
    final folder = _selectedFolder ?? (_folderOptions.isNotEmpty ? _folderOptions.first : null);
    if (folder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.selectFolder ?? 'Select folder')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final ok = await widget.provider.addBookmarkFromUrl(
      widget.url,
      title,
      _folderPath(folder),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.shareLinkAddBookmark ?? 'Bookmark added',
          ),
        ),
      );
    } else {
      final err = widget.provider.error;
      if (err != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final options = _folderOptions;
    final selected = _selectedFolder ?? (options.isNotEmpty ? options.first : null);

    return AlertDialog(
      title: Text(l?.addBookmarkTitle ?? 'Add Bookmark'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l?.bookmarkTitle ?? 'Bookmark title',
                hintText: l?.bookmarkTitle ?? 'Title',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://...',
              ),
              readOnly: true,
              enabled: false,
            ),
            if (options.isNotEmpty) ...[
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l?.selectFolder ?? 'Select folder',
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selected,
                    isExpanded: true,
                    items: options
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (v) => setState(() => _selectedFolder = v),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: Text(l?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l?.add ?? 'Add'),
        ),
      ],
    );
  }
}
