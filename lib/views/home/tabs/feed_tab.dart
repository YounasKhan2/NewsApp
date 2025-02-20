// lib/views/home/tabs/feed_tab.dart
import 'package:flutter/material.dart';
import 'package:pulse_news/models/article.dart';
import 'package:pulse_news/services/news_service.dart';
import 'package:pulse_news/widgets/home/trending_slider.dart';
import 'package:pulse_news/widgets/home/category_chips.dart';
import 'package:pulse_news/widgets/home/article_list.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({Key? key}) : super(key: key);

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final NewsService _newsService = NewsService();
  bool _isLoading = true;
  String _selectedCategory = 'general';
  List<Article> _trendingArticles = [];
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load trending articles (we'll use general category for trending)
      final trendingArticles = await _newsService.getTopHeadlines();

      // Load category-specific articles if not general
      final categoryArticles = _selectedCategory == 'general'
          ? trendingArticles
          : await _newsService.getTopHeadlines(category: _selectedCategory);

      if (mounted) {
        setState(() {
          _trendingArticles = trendingArticles.take(5).toList();
          _articles = categoryArticles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading news: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar('Failed to load news. Please try again.');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pulse News',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadNews,
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Trending',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TrendingSlider(articles: _trendingArticles),

            Padding(
              padding: const EdgeInsets.all(16),
              child: CategoryChips(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category.toLowerCase();
                  });
                  _loadNews();
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == 'general'
                        ? 'Latest News'
                        : '${_selectedCategory[0].toUpperCase()}${_selectedCategory.substring(1)} News',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all articles
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),

            ArticleList(articles: _articles),
          ],
        ),
      ),
    );
  }
}