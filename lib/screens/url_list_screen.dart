import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/url_provider.dart';
import '../providers/collection_provider.dart';
import '../models/url_item.dart';
import '../widgets/url_card.dart';
import 'add_url_screen.dart';
import 'edit_url_screen.dart';

class UrlListScreen extends StatefulWidget {
  const UrlListScreen({super.key});

  @override
  State<UrlListScreen> createState() => _UrlListScreenState();
}

class _UrlListScreenState extends State<UrlListScreen> {
  final Set<String> _selectedUrls = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final urlProvider = context.watch<UrlProvider>();
    final collectionProvider = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  if (_selectedUrls.length == urlProvider.urls.length) {
                    _selectedUrls.clear();
                  } else {
                    _selectedUrls.addAll(urlProvider.urls.map((u) => u.id));
                  }
                });
              },
              tooltip: _selectedUrls.length == urlProvider.urls.length
                  ? l10n.deselectAll
                  : l10n.selectAll,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedUrls.isEmpty
                  ? null
                  : () => _deleteSelectedUrls(context),
              tooltip: l10n.delete,
            ),
            IconButton(
              icon: const Icon(Icons.folder),
              onPressed: _selectedUrls.isEmpty
                  ? null
                  : () => _addToCollection(context),
              tooltip: l10n.addToCollection,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedUrls.clear();
                });
              },
            ),
          ] else ...[
            PopupMenuButton<SortBy>(
              icon: const Icon(Icons.sort),
              onSelected: (sortBy) {
                urlProvider.setSortBy(sortBy);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: SortBy.updated,
                  child: Text(l10n.sortByUpdated),
                ),
                PopupMenuItem(
                  value: SortBy.added,
                  child: Text(l10n.sortByAdded),
                ),
                PopupMenuItem(
                  value: SortBy.title,
                  child: Text(l10n.sortByTitle),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: urlProvider.isLoading
                  ? null
                  : () => urlProvider.checkForUpdates(),
              tooltip: l10n.checkForUpdates,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // View mode tabs
          Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildViewModeChip(
                    context,
                    label: l10n.all,
                    isSelected: urlProvider.viewMode == UrlViewMode.all,
                    onTap: () =>
                        urlProvider.setViewMode(UrlViewMode.all),
                  ),
                  _buildViewModeChip(
                    context,
                    label: l10n.uncategorized,
                    isSelected: urlProvider.viewMode == UrlViewMode.uncategorized,
                    onTap: () =>
                        urlProvider.setViewMode(UrlViewMode.uncategorized),
                  ),
                  ...collectionProvider.collections.map((collection) {
                    return _buildViewModeChip(
                      context,
                      label: collection.name,
                      isSelected: urlProvider.viewMode == UrlViewMode.collection &&
                          urlProvider.selectedCollectionId == collection.id,
                      onTap: () => urlProvider.setViewMode(
                        UrlViewMode.collection,
                        collectionId: collection.id,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // URL list
          Expanded(
            child: _buildUrlList(context, urlProvider),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => _navigateToAddUrl(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildViewModeChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildUrlList(BuildContext context, UrlProvider urlProvider) {
    final l10n = AppLocalizations.of(context)!;

    if (urlProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (urlProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(urlProvider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => urlProvider.loadUrls(),
              child: Text(l10n.checkForUpdates),
            ),
          ],
        ),
      );
    }

    if (urlProvider.urls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noUrlsYet,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addYourFirstUrl,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: urlProvider.urls.length,
      itemBuilder: (context, index) {
        final urlItem = urlProvider.urls[index];
        final isSelected = _selectedUrls.contains(urlItem.id);

        return UrlCard(
          urlItem: urlItem,
          isSelected: isSelected,
          isSelectionMode: _isSelectionMode,
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) {
                  _selectedUrls.remove(urlItem.id);
                } else {
                  _selectedUrls.add(urlItem.id);
                }
              });
            } else {
              _navigateToEditUrl(context, urlItem);
            }
          },
          onLongPress: () {
            setState(() {
              _isSelectionMode = true;
              _selectedUrls.add(urlItem.id);
            });
          },
        );
      },
    );
  }

  void _navigateToAddUrl(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddUrlScreen()),
    );

    if (result == true && mounted) {
      context.read<UrlProvider>().loadUrls();
    }
  }

  void _navigateToEditUrl(BuildContext context, UrlItem urlItem) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditUrlScreen(urlItem: urlItem)),
    );

    if (result == true && mounted) {
      context.read<UrlProvider>().loadUrls();
    }
  }

  void _deleteSelectedUrls(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteUrls(_selectedUrls.length)),
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
      await context.read<UrlProvider>().deleteUrls(_selectedUrls.toList());
      setState(() {
        _selectedUrls.clear();
        _isSelectionMode = false;
      });
    }
  }

  void _addToCollection(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final collectionProvider = context.read<CollectionProvider>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addToCollection),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...collectionProvider.collections.map((collection) {
              return ListTile(
                title: Text(collection.name),
                onTap: () async {
                  await collectionProvider.addUrlsToCollection(
                    _selectedUrls.toList(),
                    collection.id,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {
                      _selectedUrls.clear();
                      _isSelectionMode = false;
                    });
                  }
                },
              );
            }),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l10n.createNewCollection),
              onTap: () {
                Navigator.pop(context);
                _createNewCollection(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createNewCollection(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createNewCollection),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.collectionName,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.add),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final name = controller.text.trim();
      if (name.isNotEmpty) {
        final collectionProvider = context.read<CollectionProvider>();
        await collectionProvider.addCollection(name);

        // Add URLs to the new collection
        final newCollection = collectionProvider.collections.last;
        await collectionProvider.addUrlsToCollection(
          _selectedUrls.toList(),
          newCollection.id,
        );

        setState(() {
          _selectedUrls.clear();
          _isSelectionMode = false;
        });
      }
    }
  }
}
