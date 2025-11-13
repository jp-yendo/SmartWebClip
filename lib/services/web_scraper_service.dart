import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class WebScraperService {
  /// Fetches the title from a URL
  Future<String> fetchTitle(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch URL: ${response.statusCode}');
      }

      final document = html_parser.parse(response.body);

      // Try og:title first
      final ogTitle = document.querySelector('meta[property="og:title"]');
      if (ogTitle != null) {
        final content = ogTitle.attributes['content'];
        if (content != null && content.isNotEmpty) {
          return content;
        }
      }

      // Try twitter:title
      final twitterTitle = document.querySelector('meta[name="twitter:title"]');
      if (twitterTitle != null) {
        final content = twitterTitle.attributes['content'];
        if (content != null && content.isNotEmpty) {
          return content;
        }
      }

      // Fallback to <title> tag
      final titleElement = document.querySelector('title');
      if (titleElement != null) {
        return titleElement.text.trim();
      }

      // Last resort: use URL as title
      return url;
    } catch (e) {
      return url;
    }
  }

  /// Validates if a URL is accessible
  Future<bool> validateUrl(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https')))) {
        return false;
      }

      final response = await http.head(Uri.parse(url));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      return false;
    }
  }
}
