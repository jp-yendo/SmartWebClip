import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/collection_provider.dart';
import '../models/collection.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionProvider>().loadCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final collectionProvider = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.collections),
      ),
      body: _buildCollectionList(context, collectionProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCollection(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCollectionList(
      BuildContext context, CollectionProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No collections yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first collection',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: provider.collections.length,
      onReorder: (oldIndex, newIndex) {
        provider.reorderCollections(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final collection = provider.collections[index];
        return ListTile(
          key: ValueKey(collection.id),
          leading: const Icon(Icons.folder),
          title: Text(collection.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editCollection(context, collection),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteCollection(context, collection),
              ),
              const Icon(Icons.drag_handle),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addCollection(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addCollection),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.collectionName,
            border: const OutlineInputBorder(),
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
        await context.read<CollectionProvider>().addCollection(name);
      }
    }
  }

  Future<void> _editCollection(
      BuildContext context, Collection collection) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: collection.name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editCollection),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.collectionName,
            border: const OutlineInputBorder(),
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
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final name = controller.text.trim();
      if (name.isNotEmpty) {
        final updatedCollection = collection.copyWith(
          name: name,
          updatedAt: DateTime.now(),
        );
        await context.read<CollectionProvider>().updateCollection(updatedCollection);
      }
    }
  }

  Future<void> _deleteCollection(
      BuildContext context, Collection collection) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteCollection),
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
      await context.read<CollectionProvider>().deleteCollection(collection.id);
    }
  }
}
