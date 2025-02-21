import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pulse_news/models/article.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = '67286b996b91454a92ed458e449b50bd';

  Future<List<Article>> getTopHeadlines({
    String category = 'general',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = '$_baseUrl/top-headlines?country=us&pageSize=$pageSize&page=$page'
          '${category != 'general' ? '&category=$category' : ''}'
          '&apiKey=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          final articlesJson = data['articles'] as List;

          // Use Set to store unique articles based on URL
          Set<String> seenUrls = {};
          List<Article> articles = [];

          // Process articles in parallel for efficiency
          await Future.wait(articlesJson.map((json) async {
            Article article = Article.fromJson(json);
            if (await _isValidImageUrl(article.imageUrl) &&
                article.url != null &&
                !seenUrls.contains(article.url)) {
              seenUrls.add(article.url!);
              articles.add(article);
            }
          }));

          print('Total articles fetched: ${articlesJson.length}');
          print('Unique articles with valid images: ${articles.length}');

          return articles;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch news');
        }
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      rethrow;
    }
  }

  Future<List<Article>> search(String query, {int page = 1}) async {
    try {
      final url = '$_baseUrl/everything?q=$query&pageSize=15&page=$page'
          '&apiKey=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          final articlesJson = data['articles'] as List;

          // Use Set to store unique articles based on URL
          Set<String> seenUrls = {};
          List<Article> articles = [];

          // Process articles in parallel for efficiency
          await Future.wait(articlesJson.map((json) async {
            Article article = Article.fromJson(json);
            if (await _isValidImageUrl(article.imageUrl) &&
                article.url != null &&
                !seenUrls.contains(article.url)) {
              seenUrls.add(article.url!);
              articles.add(article);
            }
          }));

          print('Total articles fetched: ${articlesJson.length}');
          print('Unique articles with valid images: ${articles.length}');

          return articles;
        } else {
          throw Exception(data['message'] ?? 'Failed to search news');
        }
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching news: $e');
      rethrow;
    }
  }

  Future<bool> _isValidImageUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) return false;

    try {
      final response = await http.head(Uri.parse(imageUrl));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}