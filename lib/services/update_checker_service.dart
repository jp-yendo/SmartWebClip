import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:webfeed/webfeed.dart';
import '../models/url_item.dart';
import 'database_service.dart';

class UpdateCheckerService {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<void> checkAllActiveUrls() async {
    final urls = await _dbService.getAllUrlItems();
    final activeUrls = urls.where((url) => url.isActive).toList();

    for (final urlItem in activeUrls) {
      await checkUrlForUpdate(urlItem);
    }
  }

  Future<bool> checkUrlForUpdate(UrlItem urlItem) async {
    try {
      bool hasUpdate = false;

      switch (urlItem.checkType) {
        case CheckType.rss:
          hasUpdate = await _checkRssFeed(urlItem);
          break;
        case CheckType.htmlStandard:
          hasUpdate = await _checkHtmlStandard(urlItem);
          break;
        case CheckType.htmlCustom:
          hasUpdate = await _checkHtmlCustom(urlItem);
          break;
      }

      // Update last_checked_at
      final updatedItem = urlItem.copyWith(
        lastCheckedAt: DateTime.now(),
        errorCount: 0,
        lastErrorMessage: null,
      );

      await _dbService.updateUrlItem(updatedItem);
      return hasUpdate;
    } catch (e) {
      // Handle error
      final updatedItem = urlItem.copyWith(
        lastCheckedAt: DateTime.now(),
        errorCount: urlItem.errorCount + 1,
        lastErrorMessage: e.toString(),
      );
      await _dbService.updateUrlItem(updatedItem);
      return false;
    }
  }

  Future<bool> _checkRssFeed(UrlItem urlItem) async {
    final response = await http.get(Uri.parse(urlItem.url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch RSS feed: ${response.statusCode}');
    }

    final feed = RssFeed.parse(response.body);
    if (feed.items == null || feed.items!.isEmpty) {
      return false;
    }

    // Get the latest item info
    final latestItem = feed.items!.first;
    final latestContent = jsonEncode({
      'title': latestItem.title ?? '',
      'pubDate': latestItem.pubDate?.toIso8601String() ?? '',
      'guid': latestItem.guid ?? '',
      'link': latestItem.link ?? '',
    });

    final currentHash = _generateHash(latestContent);

    if (urlItem.lastContentHash == null ||
        urlItem.lastContentHash != currentHash) {
      // Update detected
      final updatedItem = urlItem.copyWith(
        lastContentHash: currentHash,
        lastUpdatedAt: DateTime.now(),
      );
      await _dbService.updateUrlItem(updatedItem);
      return true;
    }

    return false;
  }

  Future<bool> _checkHtmlStandard(UrlItem urlItem) async {
    final response = await http.get(Uri.parse(urlItem.url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch HTML: ${response.statusCode}');
    }

    final document = html_parser.parse(response.body);
    final bodyContent = document.body?.text ?? '';
    final currentHash = _generateHash(bodyContent);

    if (urlItem.lastContentHash == null ||
        urlItem.lastContentHash != currentHash) {
      // Update detected
      final updatedItem = urlItem.copyWith(
        lastContentHash: currentHash,
        lastUpdatedAt: DateTime.now(),
      );
      await _dbService.updateUrlItem(updatedItem);
      return true;
    }

    return false;
  }

  Future<bool> _checkHtmlCustom(UrlItem urlItem) async {
    if (urlItem.htmlSelector == null || urlItem.htmlSelector!.isEmpty) {
      throw Exception('HTML selector is required for custom check');
    }

    final response = await http.get(Uri.parse(urlItem.url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch HTML: ${response.statusCode}');
    }

    final document = html_parser.parse(response.body);
    final selectors = urlItem.htmlSelector!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Extract current contents for each selector
    final currentContents = <String>[];
    for (final selector in selectors) {
      final elements = document.querySelectorAll(selector);
      final content = elements.map((e) => e.text).join(' ');
      currentContents.add(content);
    }

    final currentHash = jsonEncode(currentContents);

    // Compare with previous contents
    List<String> previousContents = [];
    if (urlItem.lastContentHash != null && urlItem.lastContentHash!.isNotEmpty) {
      try {
        previousContents =
            List<String>.from(jsonDecode(urlItem.lastContentHash!));
      } catch (e) {
        // If parsing fails, treat as no previous data
        previousContents = [];
      }
    }

    bool hasUpdate = false;

    if (previousContents.isEmpty) {
      // First time check
      hasUpdate = currentContents.isNotEmpty;
    } else {
      // Check based on condition
      final condition =
          urlItem.htmlCustomCondition ?? HtmlCustomCondition.or;

      if (condition == HtmlCustomCondition.or) {
        // OR: At least one selector has changed
        for (int i = 0; i < currentContents.length && i < previousContents.length; i++) {
          if (currentContents[i] != previousContents[i]) {
            hasUpdate = true;
            break;
          }
        }
      } else {
        // AND: All selectors have changed
        hasUpdate = true;
        for (int i = 0; i < currentContents.length && i < previousContents.length; i++) {
          if (currentContents[i] == previousContents[i]) {
            hasUpdate = false;
            break;
          }
        }
      }
    }

    if (hasUpdate) {
      final updatedItem = urlItem.copyWith(
        lastContentHash: currentHash,
        lastUpdatedAt: DateTime.now(),
      );
      await _dbService.updateUrlItem(updatedItem);
      return true;
    }

    // Always update the hash to track current state
    final updatedItem = urlItem.copyWith(
      lastContentHash: currentHash,
    );
    await _dbService.updateUrlItem(updatedItem);

    return false;
  }

  String _generateHash(String content) {
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
