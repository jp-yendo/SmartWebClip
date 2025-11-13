import 'package:flutter/foundation.dart';
import '../models/url_item.dart';
import '../services/database_service.dart';
import '../services/update_checker_service.dart';
import '../services/thumbnail_service.dart';
import '../services/web_scraper_service.dart';

enum UrlViewMode { all, collection, uncategorized }

enum SortBy { updated, added, title }

class UrlProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  final UpdateCheckerService _updateChecker = UpdateCheckerService();
  final ThumbnailService _thumbnailService = ThumbnailService();
  final WebScraperService _webScraper = WebScraperService();

  List<UrlItem> _urls = [];
  UrlViewMode _viewMode = UrlViewMode.all;
  String? _selectedCollectionId;
  SortBy _sortBy = SortBy.updated;
  bool _sortDescending = true;
  bool _isLoading = false;
  String? _error;

  List<UrlItem> get urls => _urls;
  UrlViewMode get viewMode => _viewMode;
  String? get selectedCollectionId => _selectedCollectionId;
  SortBy get sortBy => _sortBy;
  bool get sortDescending => _sortDescending;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUrls() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      switch (_viewMode) {
        case UrlViewMode.all:
          _urls = await _dbService.getAllUrlItems(
            orderBy: _getOrderByClause(),
            descending: _sortDescending,
          );
          break;
        case UrlViewMode.collection:
          if (_selectedCollectionId != null) {
            _urls = await _dbService
                .getUrlItemsByCollection(_selectedCollectionId!);
          } else {
            _urls = [];
          }
          break;
        case UrlViewMode.uncategorized:
          _urls = await _dbService.getUncategorizedUrlItems();
          break;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getOrderByClause() {
    final order = _sortDescending ? 'DESC' : 'ASC';
    switch (_sortBy) {
      case SortBy.updated:
        return 'last_updated_at $order';
      case SortBy.added:
        return 'created_at $order';
      case SortBy.title:
        return 'title $order';
    }
  }

  void setViewMode(UrlViewMode mode, {String? collectionId}) {
    _viewMode = mode;
    _selectedCollectionId = collectionId;
    loadUrls();
  }

  void setSortBy(SortBy sortBy, {bool? descending}) {
    _sortBy = sortBy;
    if (descending != null) {
      _sortDescending = descending;
    }
    loadUrls();
  }

  Future<void> addUrl({
    required String url,
    String? title,
    CheckType checkType = CheckType.htmlStandard,
    String? htmlSelector,
    HtmlCustomCondition? htmlCustomCondition,
    BuildContext? context,
  }) async {
    try {
      // Fetch title if not provided
      final finalTitle = title ?? await _webScraper.fetchTitle(url);

      // Capture thumbnail (best effort, with WebView fallback if context provided)
      final thumbnailPath = await _thumbnailService.captureThumbnail(
        url,
        context: context,
      );

      final urlItem = UrlItem(
        url: url,
        title: finalTitle,
        thumbnailPath: thumbnailPath,
        checkType: checkType,
        htmlSelector: htmlSelector,
        htmlCustomCondition: htmlCustomCondition,
      );

      await _dbService.createUrlItem(urlItem);
      await loadUrls();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateUrl(UrlItem urlItem) async {
    try {
      await _dbService.updateUrlItem(urlItem);
      await loadUrls();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteUrl(String id) async {
    try {
      final urlItem = await _dbService.getUrlItem(id);
      if (urlItem != null && urlItem.thumbnailPath != null) {
        await _thumbnailService.deleteThumbnail(urlItem.thumbnailPath);
      }
      await _dbService.deleteUrlItem(id);
      await loadUrls();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteUrls(List<String> ids) async {
    try {
      for (final id in ids) {
        final urlItem = await _dbService.getUrlItem(id);
        if (urlItem != null && urlItem.thumbnailPath != null) {
          await _thumbnailService.deleteThumbnail(urlItem.thumbnailPath);
        }
      }
      await _dbService.deleteUrlItems(ids);
      await loadUrls();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> retakeThumbnail(String id, {BuildContext? context}) async {
    try {
      final urlItem = await _dbService.getUrlItem(id);
      if (urlItem == null) return;

      // Delete old thumbnail
      if (urlItem.thumbnailPath != null) {
        await _thumbnailService.deleteThumbnail(urlItem.thumbnailPath);
      }

      // Capture new thumbnail (with WebView fallback if context provided)
      final newThumbnailPath = await _thumbnailService.captureThumbnail(
        urlItem.url,
        context: context,
      );

      final updatedItem = urlItem.copyWith(
        thumbnailPath: newThumbnailPath,
      );

      await _dbService.updateUrlItem(updatedItem);
      await loadUrls();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkForUpdates() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _updateChecker.checkAllActiveUrls();
      await loadUrls();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkUrlUpdate(String id) async {
    try {
      final urlItem = await _dbService.getUrlItem(id);
      if (urlItem == null) return;

      await _updateChecker.checkUrlForUpdate(urlItem);
      await loadUrls();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
