import 'package:flutter/foundation.dart';
import '../models/collection.dart';
import '../services/database_service.dart';

class CollectionProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;

  List<Collection> _collections = [];
  bool _isLoading = false;
  String? _error;

  List<Collection> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCollections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _collections = await _dbService.getAllCollections();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCollection(String name) async {
    try {
      final maxOrder = _collections.isEmpty
          ? 0
          : _collections.map((c) => c.displayOrder).reduce((a, b) => a > b ? a : b);

      final collection = Collection(
        name: name,
        displayOrder: maxOrder + 1,
      );

      await _dbService.createCollection(collection);
      await loadCollections();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCollection(Collection collection) async {
    try {
      await _dbService.updateCollection(collection);
      await loadCollections();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCollection(String id) async {
    try {
      await _dbService.deleteCollection(id);
      await loadCollections();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> reorderCollections(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final item = _collections.removeAt(oldIndex);
      _collections.insert(newIndex, item);

      // Update display orders
      for (int i = 0; i < _collections.length; i++) {
        final updatedCollection = _collections[i].copyWith(displayOrder: i);
        await _dbService.updateCollection(updatedCollection);
      }

      await loadCollections();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addUrlToCollection(String urlItemId, String collectionId) async {
    try {
      await _dbService.addUrlToCollection(urlItemId, collectionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeUrlFromCollection(
      String urlItemId, String collectionId) async {
    try {
      await _dbService.removeUrlFromCollection(urlItemId, collectionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addUrlsToCollection(
      List<String> urlItemIds, String collectionId) async {
    try {
      await _dbService.addUrlsToCollection(urlItemIds, collectionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Collection>> getCollectionsForUrl(String urlItemId) async {
    try {
      return await _dbService.getCollectionsForUrl(urlItemId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
