import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/url_provider.dart';
import '../models/url_item.dart';

class EditUrlScreen extends StatefulWidget {
  final UrlItem urlItem;

  const EditUrlScreen({super.key, required this.urlItem});

  @override
  State<EditUrlScreen> createState() => _EditUrlScreenState();
}

class _EditUrlScreenState extends State<EditUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  late TextEditingController _titleController;
  late TextEditingController _htmlSelectorController;

  late CheckType _checkType;
  late HtmlCustomCondition _htmlCustomCondition;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.urlItem.url);
    _titleController = TextEditingController(text: widget.urlItem.title);
    _htmlSelectorController =
        TextEditingController(text: widget.urlItem.htmlSelector ?? '');
    _checkType = widget.urlItem.checkType;
    _htmlCustomCondition =
        widget.urlItem.htmlCustomCondition ?? HtmlCustomCondition.or;
    _isActive = widget.urlItem.isActive;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _htmlSelectorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editUrl),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openUrl,
            tooltip: 'Open URL',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteUrl,
            tooltip: l10n.delete,
          ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveUrl,
              tooltip: l10n.save,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Active toggle
            SwitchListTile(
              title: Text(l10n.active),
              subtitle: Text(_isActive ? l10n.active : l10n.inactive),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const Divider(),
            const SizedBox(height: 8),
            // URL field
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: l10n.url,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.errorEmptyUrl;
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.hasScheme) {
                  return l10n.errorInvalidUrl;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.title,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.errorEmptyTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Retake thumbnail button
            OutlinedButton.icon(
              onPressed: _retakeThumbnail,
              icon: const Icon(Icons.camera_alt),
              label: Text(l10n.retakeThumbnail),
            ),
            const SizedBox(height: 24),
            // Check type
            Text(
              l10n.checkType,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            RadioListTile<CheckType>(
              title: Text(l10n.checkTypeRss),
              subtitle: const Text('RSS/Atom feed'),
              value: CheckType.rss,
              groupValue: _checkType,
              onChanged: (value) {
                setState(() {
                  _checkType = value!;
                });
              },
            ),
            RadioListTile<CheckType>(
              title: Text(l10n.checkTypeHtmlStandard),
              subtitle: const Text('Monitor entire page body'),
              value: CheckType.htmlStandard,
              groupValue: _checkType,
              onChanged: (value) {
                setState(() {
                  _checkType = value!;
                });
              },
            ),
            RadioListTile<CheckType>(
              title: Text(l10n.checkTypeHtmlCustom),
              subtitle: const Text('Monitor specific CSS selectors'),
              value: CheckType.htmlCustom,
              groupValue: _checkType,
              onChanged: (value) {
                setState(() {
                  _checkType = value!;
                });
              },
            ),
            // HTML Custom options
            if (_checkType == CheckType.htmlCustom) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _htmlSelectorController,
                decoration: InputDecoration(
                  labelText: l10n.htmlSelector,
                  hintText: '.article-content, #main-content',
                  border: const OutlineInputBorder(),
                  helperText: 'CSS selectors separated by commas',
                ),
                maxLines: 3,
                validator: (value) {
                  if (_checkType == CheckType.htmlCustom &&
                      (value == null || value.isEmpty)) {
                    return 'HTML selector is required for custom check';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.htmlCustomCondition,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              RadioListTile<HtmlCustomCondition>(
                title: Text(l10n.conditionOr),
                value: HtmlCustomCondition.or,
                groupValue: _htmlCustomCondition,
                onChanged: (value) {
                  setState(() {
                    _htmlCustomCondition = value!;
                  });
                },
              ),
              RadioListTile<HtmlCustomCondition>(
                title: Text(l10n.conditionAnd),
                value: HtmlCustomCondition.and,
                groupValue: _htmlCustomCondition,
                onChanged: (value) {
                  setState(() {
                    _htmlCustomCondition = value!;
                  });
                },
              ),
            ],
            const SizedBox(height: 24),
            // Error info
            if (widget.urlItem.errorCount > 0) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.errorCount}: ${widget.urlItem.errorCount}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (widget.urlItem.lastErrorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.lastError}: ${widget.urlItem.lastErrorMessage}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveUrl() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final updatedItem = widget.urlItem.copyWith(
        url: _urlController.text.trim(),
        title: _titleController.text.trim(),
        checkType: _checkType,
        htmlSelector: _checkType == CheckType.htmlCustom
            ? _htmlSelectorController.text.trim()
            : null,
        htmlCustomCondition: _checkType == CheckType.htmlCustom
            ? _htmlCustomCondition
            : null,
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      await context.read<UrlProvider>().updateUrl(updatedItem);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.editUrl} ${l10n.save}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _retakeThumbnail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<UrlProvider>().retakeThumbnail(
        widget.urlItem.id,
        context: context,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thumbnail updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating thumbnail: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteUrl() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteUrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<UrlProvider>().deleteUrl(widget.urlItem.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _openUrl() async {
    final uri = Uri.parse(widget.urlItem.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
