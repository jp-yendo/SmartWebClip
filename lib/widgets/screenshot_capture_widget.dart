import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webview_universal_plus/webview_universal_plus.dart';

/// Widget that captures a screenshot of a web page
/// Shows a loading mask while the page loads
class ScreenshotCaptureWidget extends StatefulWidget {
  final String url;
  final Function(ui.Image?) onCaptureComplete;

  const ScreenshotCaptureWidget({
    super.key,
    required this.url,
    required this.onCaptureComplete,
  });

  @override
  State<ScreenshotCaptureWidget> createState() =>
      _ScreenshotCaptureWidgetState();
}

class _ScreenshotCaptureWidgetState extends State<ScreenshotCaptureWidget> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Wait a bit for rendering to complete
            Future.delayed(const Duration(milliseconds: 500), () {
              _captureScreenshot();
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
            widget.onCaptureComplete(null);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _captureScreenshot() async {
    try {
      final RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // Capture the widget as an image
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      widget.onCaptureComplete(image);
    } catch (e) {
      widget.onCaptureComplete(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // WebView wrapped in RepaintBoundary for screenshot
              RepaintBoundary(
                key: _repaintBoundaryKey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: WebViewWidget(
                    controller: _webViewController,
                  ),
                ),
              ),

              // Loading mask overlay
              if (_isLoading)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'スクリーンショットを取得しています...',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),

              // Error state
              if (_hasError && !_isLoading)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'ページの読み込みに失敗しました',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
