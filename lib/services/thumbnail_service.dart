import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class ThumbnailService {
  /// Captures a thumbnail screenshot of the given URL
  /// Strategy:
  /// 1. Try to get Open Graph image (fast, good quality)
  /// 2. Try to get favicon (fallback)
  /// 3. Return null if both fail (best effort)
  ///
  /// Returns the file path if successful, null otherwise
  Future<String?> captureThumbnail(String url) async {
    try {
      // Strategy 1: Try Open Graph image first
      final ogImageUrl = await _getOpenGraphImage(url);
      if (ogImageUrl != null) {
        final imagePath = await _downloadImage(ogImageUrl);
        if (imagePath != null) {
          return imagePath;
        }
      }

      // Strategy 2: Try favicon as fallback
      final faviconUrl = await _getFaviconUrl(url);
      if (faviconUrl != null) {
        final imagePath = await _downloadImage(faviconUrl);
        if (imagePath != null) {
          return imagePath;
        }
      }

      // Strategy 3: Could implement WebView screenshot here if needed
      // For now, return null (best effort approach)
      return null;
    } catch (e) {
      // Best effort - don't throw error
      return null;
    }
  }

  /// Get Open Graph image URL from the webpage
  Future<String?> _getOpenGraphImage(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

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

      // Try twitter:image:src
      final twitterImageSrc = document.querySelector('meta[name="twitter:image:src"]');
      if (twitterImageSrc != null) {
        final content = twitterImageSrc.attributes['content'];
        if (content != null && content.isNotEmpty) {
          return _resolveUrl(url, content);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get favicon URL from the webpage
  Future<String?> _getFaviconUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final baseUrl = '${uri.scheme}://${uri.host}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        // Fallback to default favicon location
        return '$baseUrl/favicon.ico';
      }

      final document = html_parser.parse(response.body);

      // Try link rel="icon"
      final iconLink = document.querySelector('link[rel*="icon"]');
      if (iconLink != null) {
        final href = iconLink.attributes['href'];
        if (href != null && href.isNotEmpty) {
          return _resolveUrl(url, href);
        }
      }

      // Fallback to default favicon location
      return '$baseUrl/favicon.ico';
    } catch (e) {
      // Try default favicon location as last resort
      try {
        final uri = Uri.parse(url);
        return '${uri.scheme}://${uri.host}/favicon.ico';
      } catch (e) {
        return null;
      }
    }
  }

  /// Resolve relative URL to absolute URL
  String _resolveUrl(String baseUrl, String relativeUrl) {
    // Already absolute URL
    if (relativeUrl.startsWith('http://') ||
        relativeUrl.startsWith('https://')) {
      return relativeUrl;
    }

    try {
      final uri = Uri.parse(baseUrl);

      // Protocol-relative URL (//example.com/image.jpg)
      if (relativeUrl.startsWith('//')) {
        return '${uri.scheme}:$relativeUrl';
      }

      // Absolute path (/path/to/image.jpg)
      if (relativeUrl.startsWith('/')) {
        return '${uri.scheme}://${uri.host}$relativeUrl';
      }

      // Relative path (path/to/image.jpg or ../path/to/image.jpg)
      final basePath = uri.path.endsWith('/')
          ? uri.path
          : uri.path.substring(0, uri.path.lastIndexOf('/') + 1);

      return '${uri.scheme}://${uri.host}$basePath$relativeUrl';
    } catch (e) {
      // If parsing fails, return the relative URL as-is
      return relativeUrl;
    }
  }

  /// Download image from URL and save to local storage
  Future<String?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return null;
      }

      // Check if response is actually an image
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.startsWith('image/')) {
        return null;
      }

      // Check file size (limit to 10MB)
      if (response.bodyBytes.length > 10 * 1024 * 1024) {
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final thumbnailDir = Directory(path.join(dir.path, 'thumbnails'));
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _getExtensionFromContentType(contentType);
      final fileName = 'thumb_$timestamp$extension';
      final filePath = path.join(thumbnailDir.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Get file extension from content type
  String _getExtensionFromContentType(String contentType) {
    if (contentType.contains('jpeg') || contentType.contains('jpg')) {
      return '.jpg';
    } else if (contentType.contains('png')) {
      return '.png';
    } else if (contentType.contains('gif')) {
      return '.gif';
    } else if (contentType.contains('webp')) {
      return '.webp';
    } else if (contentType.contains('svg')) {
      return '.svg';
    }
    return '.jpg'; // Default
  }

  /// Delete thumbnail file
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

  /// Optional: Capture screenshot using WebView (for manual/on-demand use)
  /// This requires a UI context and is more resource-intensive
  /// Currently not implemented as it requires HeadlessInAppWebView
  /// which has platform-specific limitations
  Future<String?> captureWebViewScreenshot(String url) async {
    // This would require:
    // 1. Creating a HeadlessInAppWebView
    // 2. Loading the URL
    // 3. Taking a screenshot
    // 4. Saving the image
    //
    // Implementation complexity varies by platform
    // Consider implementing this as an optional premium feature
    return null;
  }
}
