import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_news/models/article.dart';

class BookmarksService {
  static const String _bookmarksKey = 'bookmarked_articles';

  Future<List<Article>> getBookmarkedArticles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];

      return bookmarksJson
          .map((json) => Article.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting bookmarks: $e');
      return [];
    }
  }

  Future<void> addBookmark(Article article) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];

      // Check if article is already bookmarked
      if (article.url != null && !bookmarksJson.any((json) {
        final decoded = jsonDecode(json);
        return decoded['url'] == article.url;
      })) {
        bookmarksJson.add(jsonEncode(article.toJson()));
        await prefs.setStringList(_bookmarksKey, bookmarksJson);
      }
    } catch (e) {
      print('Error adding bookmark: $e');
    }
  }

  Future<void> removeBookmark(Article article) async {
    try {
      if (article.url == null) return;

      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];

      final updatedBookmarks = bookmarksJson.where((json) {
        final decoded = jsonDecode(json);
        return decoded['url'] != article.url;
      }).toList();

      await prefs.setStringList(_bookmarksKey, updatedBookmarks);
    } catch (e) {
      print('Error removing bookmark: $e');
    }
  }

  Future<void> clearAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarksKey);
    } catch (e) {
      print('Error clearing bookmarks: $e');
    }
  }
}