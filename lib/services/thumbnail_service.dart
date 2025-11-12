import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:image/image.dart' as img;

class ThumbnailService {
  /// Captures a thumbnail screenshot of the given URL
  /// Strategy:
  /// 1. Try Open Graph images (no size restriction)
  /// 2. Try PWA manifest icons (256-512px range, resize if >512px)
  /// 3. Try WebView screenshot (platform-dependent)
  /// 4. Return null if all fail (best effort)
  ///
  /// Returns the file path if successful, null otherwise
  Future<String?> captureThumbnail(String url) async {
    try {
      // Strategy 1: Try Open Graph images (no size check)
      final ogImageUrl = await _getOpenGraphImage(url);
      if (ogImageUrl != null) {
        final imagePath = await _downloadAndValidateImage(ogImageUrl);
        if (imagePath != null) {
          return imagePath;
        }
      }

      // Strategy 2: Try PWA manifest icons (with size filtering and resize)
      final pwaResult = await _getBestPWAIcon(url);
      if (pwaResult != null) {
        final imagePath = await _downloadAndValidateImage(
          pwaResult['url']!,
          needsResize: pwaResult['resize'] == true,
        );
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

  /// Get Open Graph image URL (no size restriction)
  /// Simply returns the first available OG image
  Future<String?> _getOpenGraphImage(String url) async {
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
      final twitterImageSrc =
          document.querySelector('meta[name="twitter:image:src"]');
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

  /// Get the best PWA manifest icon that meets resolution criteria
  /// Returns a map with 'url' and 'resize' flag
  /// - Prefers icons between 256-512px
  /// - If only >512px available, returns with resize flag
  /// - Returns null if no suitable icons (<256px are skipped)
  Future<Map<String, dynamic>?> _getBestPWAIcon(String url) async {
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

      return _selectBestPWAIcon(candidates);
    } catch (e) {
      return null;
    }
  }

  /// Select the best PWA icon based on size criteria
  /// - Prefer 256-512px range (no resize needed)
  /// - If none in range, select best >512px (needs resize)
  /// - Skip <256px (too small)
  Map<String, dynamic>? _selectBestPWAIcon(
      List<Map<String, dynamic>> candidates) {
    if (candidates.isEmpty) return null;

    Map<String, dynamic>? bestInRange;
    Map<String, dynamic>? bestLarge;
    int bestInRangeSize = 0;
    int bestLargeSize = 0;

    for (final candidate in candidates) {
      final url = candidate['url'] as String?;
      if (url == null) continue;

      final width = candidate['width'] as int?;
      final height = candidate['height'] as int?;

      // Skip if dimensions not available
      if (width == null || height == null) continue;

      final minDimension = width < height ? width : height;

      // Skip if too small
      if (minDimension < 256) continue;

      if (minDimension <= 512) {
        // In optimal range (256-512px)
        if (minDimension > bestInRangeSize) {
          bestInRangeSize = minDimension;
          bestInRange = {
            'url': url,
            'resize': false,
          };
        }
      } else {
        // Larger than 512px (will need resize)
        if (minDimension > bestLargeSize) {
          bestLargeSize = minDimension;
          bestLarge = {
            'url': url,
            'resize': true,
          };
        }
      }
    }

    // Prefer icons in optimal range
    return bestInRange ?? bestLarge;
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
  /// If needsResize is true, resize to max 512px on longest side
  Future<String?> _downloadAndValidateImage(
    String imageUrl, {
    bool needsResize = false,
  }) async {
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

      Uint8List imageBytes = response.bodyBytes;

      // Resize if needed
      if (needsResize) {
        imageBytes = await _resizeImage(imageBytes);
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
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Resize image so longest side is max 512px
  Future<Uint8List> _resizeImage(Uint8List imageBytes) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Check if resize is needed
      final maxDimension = image.width > image.height ? image.width : image.height;
      if (maxDimension <= 512) return imageBytes;

      // Calculate new dimensions
      int newWidth;
      int newHeight;

      if (image.width > image.height) {
        // Width is longer
        newWidth = 512;
        newHeight = (image.height * 512 / image.width).round();
      } else {
        // Height is longer
        newHeight = 512;
        newWidth = (image.width * 512 / image.height).round();
      }

      // Resize
      final resized = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Encode as JPEG
      return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
    } catch (e) {
      // If resize fails, return original
      return imageBytes;
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
