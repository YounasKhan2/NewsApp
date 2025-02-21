import 'package:flutter/material.dart';
import 'package:pulse_news/models/article.dart';
import 'package:pulse_news/services/news_service.dart';
import 'package:pulse_news/widgets/home/trending_slider.dart';
import 'package:pulse_news/widgets/home/category_chips.dart';
import 'package:pulse_news/widgets/home/article_list.dart';
import 'package:pulse_news/views/home/all_articles_screen.dart';

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
      final trendingArticles = await _newsService.getTopHeadlines();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pulse News',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // TODO: Navigate to search screen
            },
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Trending',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  // In lib/views/home/tabs/feed_tab.dart, update the TextButton:
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllArticlesScreen(
                            category: _selectedCategory,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
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