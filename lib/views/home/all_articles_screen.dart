// lib/views/home/all_articles_screen.dart
import 'package:flutter/material.dart';
import 'package:pulse_news/models/article.dart';
import 'package:pulse_news/services/news_service.dart';
import 'package:pulse_news/widgets/home/article_list.dart';
import 'dart:math' show min;

class AllArticlesScreen extends StatefulWidget {
  final String category;
  final String title;

  const AllArticlesScreen({
    Key? key,
    required this.category,
    required this.title,
  }) : super(key: key);

  @override
  State<AllArticlesScreen> createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> {
  final NewsService _newsService = NewsService();
  final ScrollController _scrollController = ScrollController();

  List<Article> _articles = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _articlesPerPage = 25; // Increased initial load
  bool _hasMoreArticles = true;

  @override
  void initState() {
    super.initState();
    _loadInitialArticles();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 && // Trigger earlier
        !_isLoadingMore &&
        _hasMoreArticles) {
      _loadMoreArticles();
    }
  }

  Future<void> _loadInitialArticles() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _articles.clear();
    });

    try {
      // Load first batch of 25 articles (might need multiple API calls)
      final firstBatch = await _loadBatch(1, 25);

      if (mounted) {
        setState(() {
          _articles = firstBatch;
          _isLoading = false;
          _hasMoreArticles = firstBatch.length >= _articlesPerPage;
        });
      }
    } catch (e) {
      print('Error loading initial articles: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar('Failed to load articles. Please try again.');
      }
    }
  }

  Future<List<Article>> _loadBatch(int page, int count) async {
    List<Article> articles = [];
    int remainingCount = count;
    int currentPage = page;

    while (remainingCount > 0) {
      final batch = await _newsService.getTopHeadlines(
        category: widget.category,
        page: currentPage,
        pageSize: min(remainingCount, 20), // API typically limits to 20 per request
      );

      if (batch.isEmpty) break; // No more articles available

      articles.addAll(batch);
      remainingCount -= batch.length;
      currentPage++;
    }

    return articles;
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoadingMore || !_hasMoreArticles) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final nextBatch = await _loadBatch(_currentPage, 20); // Load next 20 articles

      if (mounted) {
        setState(() {
          _articles.addAll(nextBatch);
          _isLoadingMore = false;
          _hasMoreArticles = nextBatch.length > 0;
        });
      }
    } catch (e) {
      print('Error loading more articles: $e');
      if (mounted) {
        setState(() {
          _currentPage--;
          _isLoadingMore = false;
        });
        _showErrorSnackbar('Failed to load more articles.');
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

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text(
            'Loading more articles...',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadInitialArticles,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _articles.length + (_hasMoreArticles ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _articles.length) {
              return _isLoadingMore
                  ? _buildLoadingIndicator()
                  : const SizedBox.shrink();
            }
            return ArticleList(articles: [_articles[index]]);
          },
        ),
      ),
    );
  }
}