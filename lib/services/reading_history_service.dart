// lib/services/reading_history_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_news/models/article.dart';
//--------------------
class ReadingHistoryService {
  static const String _historyKey = 'reading_history';
  static const int _maxHistoryItems = 50; // Limit to prevent excessive storage use

  Future<List<Article>> getReadingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      return historyJson
          .map((json) => Article.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting reading history: $e');
      return [];
    }
  }

  Future<void> addToHistory(Article article) async {
    try {
      if (article.url == null) return; // Skip articles without URL

      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      // Remove article if it already exists in history (to avoid duplicates)
      final updatedHistory = historyJson.where((json) {
        final decoded = jsonDecode(json);
        return decoded['url'] != article.url;
      }).toList();

      // Add article to the beginning of the list (most recent first)
      updatedHistory.insert(0, jsonEncode(article.toJson()));

      // Limit the history size
      if (updatedHistory.length > _maxHistoryItems) {
        updatedHistory.removeRange(_maxHistoryItems, updatedHistory.length);
      }

      await prefs.setStringList(_historyKey, updatedHistory);
    } catch (e) {
      print('Error adding to reading history: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing reading history: $e');
    }
  }

  Future<int> getHistoryCount() async {
    final history = await getReadingHistory();
    return history.length;
  }
}