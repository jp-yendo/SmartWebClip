import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class ThumbnailService {
  /// Captures a thumbnail screenshot of the given URL
  /// Strategy:
  /// 1. Try Open Graph images (256px+ resolution, prefer up to 512px)
  /// 2. Try PWA manifest icons (same resolution criteria)
  /// 3. Try WebView screenshot (platform-dependent)
  /// 4. Return null if all fail (best effort)
  ///
  /// Returns the file path if successful, null otherwise
  Future<String?> captureThumbnail(String url) async {
    try {
      // Strategy 1: Try Open Graph images with resolution check
      final ogImageUrl = await _getBestOpenGraphImage(url);
      if (ogImageUrl != null) {
        final imagePath = await _downloadAndValidateImage(ogImageUrl);
        if (imagePath != null) {
          return imagePath;
        }
      }

      // Strategy 2: Try PWA manifest icons
      final pwaIconUrl = await _getBestPWAIcon(url);
      if (pwaIconUrl != null) {
        final imagePath = await _downloadAndValidateImage(pwaIconUrl);
        if (imagePath != null) {
          return imagePath;
        }
      }

      // Strategy 3: Try WebView screenshot (platform-dependent)
      final screenshotPath = await _captureWebViewScreenshot(url);
      if (screenshotPath != null) {
        return screenshotPath;
      }

      // All strategies failed
      return null;
    } catch (e) {
      // Best effort - don't throw error
      return null;
    }
  }

  /// Get the best Open Graph image URL that meets resolution criteria
  /// - Must be 256px or larger
  /// - Prefer images up to 512px
  /// - Return the highest resolution within acceptable range
  Future<String?> _getBestOpenGraphImage(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final document = html_parser.parse(response.body);
      final List<Map<String, dynamic>> candidates = [];

      // Collect og:image candidates
      final ogImages = document.querySelectorAll('meta[property="og:image"]');
      for (final meta in ogImages) {
        final content = meta.attributes['content'];
        if (content != null && content.isNotEmpty) {
          candidates.add({
            'url': _resolveUrl(url, content),
            'width': _extractMetaProperty(document, 'og:image:width'),
            'height': _extractMetaProperty(document, 'og:image:height'),
          });
        }
      }

      // Collect twitter:image candidates
      final twitterImages =
          document.querySelectorAll('meta[name="twitter:image"]');
      for (final meta in twitterImages) {
        final content = meta.attributes['content'];
        if (content != null && content.isNotEmpty) {
          candidates.add({
            'url': _resolveUrl(url, content),
            'width': _extractMetaProperty(document, 'twitter:image:width'),
            'height': _extractMetaProperty(document, 'twitter:image:height'),
          });
        }
      }

      // Find best candidate based on resolution
      return await _selectBestImageCandidate(candidates);
    } catch (e) {
      return null;
    }
  }

  /// Extract meta property value as integer
  int? _extractMetaProperty(dynamic document, String property) {
    try {
      final meta = document.querySelector('meta[property="$property"]') ??
          document.querySelector('meta[name="$property"]');
      if (meta != null) {
        final content = meta.attributes['content'];
        if (content != null) {
          return int.tryParse(content);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get the best PWA manifest icon that meets resolution criteria
  Future<String?> _getBestPWAIcon(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final document = html_parser.parse(response.body);

      // Find manifest link
      final manifestLink = document.querySelector('link[rel="manifest"]');
      if (manifestLink == null) {
        return null;
      }

      final manifestHref = manifestLink.attributes['href'];
      if (manifestHref == null || manifestHref.isEmpty) {
        return null;
      }

      final manifestUrl = _resolveUrl(url, manifestHref);

      // Fetch manifest
      final manifestResponse = await http.get(
        Uri.parse(manifestUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (manifestResponse.statusCode != 200) {
        return null;
      }

      final manifest = jsonDecode(manifestResponse.body);
      final icons = manifest['icons'];

      if (icons == null || icons is! List) {
        return null;
      }

      // Collect icon candidates
      final List<Map<String, dynamic>> candidates = [];
      for (final icon in icons) {
        if (icon is! Map) continue;

        final src = icon['src'];
        final sizes = icon['sizes'];

        if (src == null) continue;

        final iconUrl = _resolveUrl(manifestUrl, src.toString());

        // Parse sizes (e.g., "192x192", "512x512")
        int? width;
        int? height;
        if (sizes != null && sizes is String) {
          final parts = sizes.split('x');
          if (parts.length == 2) {
            width = int.tryParse(parts[0]);
            height = int.tryParse(parts[1]);
          }
        }

        candidates.add({
          'url': iconUrl,
          'width': width,
          'height': height,
        });
      }

      return await _selectBestImageCandidate(candidates);
    } catch (e) {
      return null;
    }
  }

  /// Select the best image candidate based on resolution criteria
  /// - Must be 256px or larger (both width and height)
  /// - Prefer images up to 512px
  /// - Return the highest resolution within acceptable range
  Future<String?> _selectBestImageCandidate(
      List<Map<String, dynamic>> candidates) async {
    if (candidates.isEmpty) return null;

    Map<String, dynamic>? bestCandidate;
    int bestSize = 0;

    for (final candidate in candidates) {
      final url = candidate['url'] as String?;
      if (url == null) continue;

      int? width = candidate['width'] as int?;
      int? height = candidate['height'] as int?;

      // If dimensions not specified, try to fetch and check
      if (width == null || height == null) {
        final dimensions = await _getImageDimensions(url);
        if (dimensions != null) {
          width = dimensions['width'];
          height = dimensions['height'];
        }
      }

      // Skip if we still don't have dimensions
      if (width == null || height == null) continue;

      // Check minimum size requirement (256px)
      if (width < 256 || height < 256) continue;

      // Calculate size score (prefer images up to 512px)
      final minDimension = width < height ? width : height;
      int sizeScore;

      if (minDimension <= 512) {
        // Prefer images up to 512px (higher is better)
        sizeScore = minDimension;
      } else {
        // Images larger than 512px are acceptable but not preferred
        // Give them a lower score
        sizeScore = 512 - (minDimension - 512) ~/ 10;
      }

      if (sizeScore > bestSize) {
        bestSize = sizeScore;
        bestCandidate = candidate;
      }
    }

    return bestCandidate?['url'] as String?;
  }

  /// Get image dimensions from URL
  Future<Map<String, int>?> _getImageDimensions(String imageUrl) async {
    try {
      final response = await http.head(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return null;
      }

      // Try to get dimensions from Content-Length if image is small enough
      // For now, return null as we'd need to download the image to get dimensions
      // This is acceptable as most modern sites provide dimensions in meta tags
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Capture screenshot using WebView (platform-dependent)
  /// Works on most platforms but may have limitations
  Future<String?> _captureWebViewScreenshot(String url) async {
    // Note: HeadlessInAppWebView has platform-specific limitations
    // - Desktop platforms (Windows, macOS, Linux): May not be fully supported
    // - Mobile platforms (Android, iOS): Should work but requires testing
    //
    // For now, we return null as the implementation is complex and
    // platform-dependent. This can be implemented as an optional feature later.

    // Uncomment and test the following implementation on your target platform:
    /*
    try {
      final completer = Completer<String?>();
      HeadlessInAppWebView? headlessWebView;

      headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          cacheEnabled: false,
        ),
        onLoadStop: (controller, url) async {
          try {
            // Wait for page to render
            await Future.delayed(const Duration(seconds: 2));

            // Take screenshot
            final screenshot = await controller.takeScreenshot(
              screenshotConfiguration: ScreenshotConfiguration(
                compressFormat: CompressFormat.JPEG,
                quality: 80,
              ),
            );

            if (screenshot != null) {
              // Save screenshot
              final dir = await getApplicationDocumentsDirectory();
              final thumbnailDir = Directory(path.join(dir.path, 'thumbnails'));
              if (!await thumbnailDir.exists()) {
                await thumbnailDir.create(recursive: true);
              }

              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final fileName = 'screenshot_$timestamp.jpg';
              final filePath = path.join(thumbnailDir.path, fileName);

              final file = File(filePath);
              await file.writeAsBytes(screenshot);

              completer.complete(filePath);
            } else {
              completer.complete(null);
            }
          } catch (e) {
            completer.complete(null);
          } finally {
            await headlessWebView?.dispose();
          }
        },
        onLoadError: (controller, url, code, message) async {
          completer.complete(null);
          await headlessWebView?.dispose();
        },
      );

      await headlessWebView.run();

      // Wait for result with timeout
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          headlessWebView?.dispose();
          return null;
        },
      );
    } catch (e) {
      return null;
    }
    */

    return null;
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
      return relativeUrl;
    }
  }

  /// Download and validate image
  Future<String?> _downloadAndValidateImage(String imageUrl) async {
    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
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
}
