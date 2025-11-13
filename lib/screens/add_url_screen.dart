import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/url_provider.dart';
import '../models/url_item.dart';

class AddUrlScreen extends StatefulWidget {
  const AddUrlScreen({super.key});

  @override
  State<AddUrlScreen> createState() => _AddUrlScreenState();
}

class _AddUrlScreenState extends State<AddUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _htmlSelectorController = TextEditingController();

  CheckType _checkType = CheckType.htmlStandard;
  HtmlCustomCondition _htmlCustomCondition = HtmlCustomCondition.or;
  bool _isLoading = false;

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
        title: Text(l10n.addUrl),
        actions: [
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
            // URL field
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: l10n.url,
                hintText: 'https://example.com',
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
                hintText: l10n.title,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
                helperText: 'Leave empty to auto-fetch',
              ),
              validator: (value) {
                // Title is optional, will be fetched automatically if empty
                return null;
              },
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
      final urlProvider = context.read<UrlProvider>();
      await urlProvider.addUrl(
        url: _urlController.text.trim(),
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        checkType: _checkType,
        htmlSelector: _checkType == CheckType.htmlCustom
            ? _htmlSelectorController.text.trim()
            : null,
        htmlCustomCondition: _checkType == CheckType.htmlCustom
            ? _htmlCustomCondition
            : null,
        context: context,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.addUrl} ${l10n.save}')),
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
}
