// lib/views/home/all_articles_screen.dart
import 'package:flutter/material.dart';
import 'package:pulse_news/models/article.dart';
import 'package:pulse_news/services/news_service.dart';
import 'package:pulse_news/widgets/home/article_list.dart';

class AllArticlesScreen extends StatefulWidget {
  final String category;

  const AllArticlesScreen({
    Key? key,
    required this.category,
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
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMorePages) {
        _loadMoreArticles();
      }
    }
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final articles = await _newsService.getTopHeadlines(
        category: widget.category,
        page: _currentPage,
      );

      setState(() {
        _articles = articles;
        _isLoading = false;
        _hasMorePages = articles.length == 10; // If we got 10 articles, assume there are more
      });
    } catch (e) {
      print('Error loading articles: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load articles. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final moreArticles = await _newsService.getTopHeadlines(
        category: widget.category,
        page: _currentPage,
      );

      setState(() {
        if (moreArticles.isEmpty) {
          _hasMorePages = false;
        } else {
          _articles.addAll(moreArticles);
          _hasMorePages = moreArticles.length == 10;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      print('Error loading more articles: $e');
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == 'general'
              ? 'All News'
              : '${widget.category[0].toUpperCase()}${widget.category.substring(1)} News',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadArticles,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _articles.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return ArticleList(articles: [_articles[index]]);
          },
        ),
      ),
    );
  }
}