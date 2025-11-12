import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class ThumbnailService {
  /// Captures a thumbnail screenshot of the given URL
  /// Returns the file path if successful, null otherwise
  Future<String?> captureThumbnail(String url) async {
    try {
      // Try to get Open Graph image first
      final ogImageUrl = await _getOpenGraphImage(url);
      if (ogImageUrl != null) {
        return await _downloadImage(ogImageUrl);
      }

      // Fallback: capture screenshot using WebView
      // Note: This requires a proper implementation with WebView
      // For now, return null as it requires platform-specific implementation
      return null;
    } catch (e) {
      // Best effort - don't throw error
      return null;
    }
  }

  Future<String?> _getOpenGraphImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return null;
      }

      final document = html_parser.parse(response.body);

      // Try og:image
      final ogImage = document.querySelector('meta[property="og:image"]');
      if (ogImage != null) {
        final content = ogImage.attributes['content'];
        if (content != null && content.isNotEmpty) {
          return _resolveUrl(url, content);
        }
      }

      // Try twitter:image
      final twitterImage = document.querySelector('meta[name="twitter:image"]');
      if (twitterImage != null) {
        final content = twitterImage.attributes['content'];
        if (content != null && content.isNotEmpty) {
          return _resolveUrl(url, content);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  String _resolveUrl(String baseUrl, String relativeUrl) {
    if (relativeUrl.startsWith('http://') ||
        relativeUrl.startsWith('https://')) {
      return relativeUrl;
    }

    final uri = Uri.parse(baseUrl);
    if (relativeUrl.startsWith('/')) {
      return '${uri.scheme}://${uri.host}$relativeUrl';
    }

    return '${uri.scheme}://${uri.host}/${uri.pathSegments.join('/')}/$relativeUrl';
  }

  Future<String?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final thumbnailDir = Directory(path.join(dir.path, 'thumbnails'));
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageUrl)}';
      final filePath = path.join(thumbnailDir.path, fileName);
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteThumbnail(String? thumbnailPath) async {
    if (thumbnailPath == null || thumbnailPath.isEmpty) return;

    try {
      final file = File(thumbnailPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors
    }
  }
}
