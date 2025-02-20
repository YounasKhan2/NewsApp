// lib/views/home/tabs/categories_tab.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pulse_news/models/article.dart';
import 'package:pulse_news/services/news_service.dart';
import 'package:pulse_news/views/article/article_detail_screen.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({Key? key}) : super(key: key);

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Business',
      'apiName': 'business',
      'icon': Icons.business,
      'color': Colors.blue,
      'imageUrl': 'https://picsum.photos/id/1/400/200',
    },
    {
      'name': 'Technology',
      'apiName': 'technology',
      'icon': Icons.computer,
      'color': Colors.purple,
      'imageUrl': 'https://picsum.photos/id/2/400/200',
    },
    {
      'name': 'Sports',
      'apiName': 'sports',
      'icon': Icons.sports_football,
      'color': Colors.green,
      'imageUrl': 'https://picsum.photos/id/3/400/200',
    },
    {
      'name': 'Entertainment',
      'apiName': 'entertainment',
      'icon': Icons.movie,
      'color': Colors.red,
      'imageUrl': 'https://picsum.photos/id/4/400/200',
    },
    {
      'name': 'Health',
      'apiName': 'health',
      'icon': Icons.health_and_safety,
      'color': Colors.pink,
      'imageUrl': 'https://picsum.photos/id/5/400/200',
    },
    {
      'name': 'Science',
      'apiName': 'science',
      'icon': Icons.science,
      'color': Colors.teal,
      'imageUrl': 'https://picsum.photos/id/6/400/200',
    },
    {
      'name': 'General',
      'apiName': 'general',
      'icon': Icons.public,
      'color': Colors.amber,
      'imageUrl': 'https://picsum.photos/id/7/400/200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryArticlesScreen(
                    categoryName: category['name'],
                    apiName: category['apiName'],
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: category['imageUrl'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: category['color'].withOpacity(0.3),
                        child: Icon(
                          category['icon'],
                          size: 50,
                          color: category['color'],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            category['icon'],
                            color: Colors.white,
                            size: 32,
                          ),
                          const Spacer(),
                          Text(
                            category['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// CategoryArticlesScreen - shown when a category is selected
class CategoryArticlesScreen extends StatefulWidget {
  final String categoryName;
  final String apiName;

  const CategoryArticlesScreen({
    Key? key,
    required this.categoryName,
    required this.apiName,
  }) : super(key: key);

  @override
  State<CategoryArticlesScreen> createState() => _CategoryArticlesScreenState();
}

class _CategoryArticlesScreenState extends State<CategoryArticlesScreen> {
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
        category: widget.apiName,
        page: _currentPage,
      );

      setState(() {
        _articles = articles;
        _isLoading = false;
        _hasMorePages = articles.length == 10; // If we got 10 articles, assume there are more
      });
    } catch (e) {
      print('Error loading category articles: $e');
      setState(() {
        _isLoading = false;
      });

      _showErrorSnackbar('Failed to load articles. Please try again.');
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
        category: widget.apiName,
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
        title: Text(
          widget.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _articles.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No articles found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try another category or check back later',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadArticles,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
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

            final article = _articles[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailScreen(article: article),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.imageUrl != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: article.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey.shade300,
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                article.sourceName ?? 'Unknown Source',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                article.timeAgo,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.title ?? 'No title',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (article.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              article.description!,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}