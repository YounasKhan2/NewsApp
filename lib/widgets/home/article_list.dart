import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pulse_news/models/article.dart';
import 'package:pulse_news/views/article/article_detail_screen.dart';
import 'package:pulse_news/services/bookmarks_service.dart';

class ArticleList extends StatefulWidget {
  final List<Article> articles;

  const ArticleList({
    Key? key,
    required this.articles,
  }) : super(key: key);

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  final BookmarksService _bookmarksService = BookmarksService();
  Set<String> _bookmarkedArticles = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await _bookmarksService.getBookmarkedArticles();
    setState(() {
      _bookmarkedArticles = bookmarks
          .where((article) => article.url != null)
          .map((article) => article.url!)
          .toSet();
    });
  }

  Future<void> _toggleBookmark(Article article) async {
    if (article.url == null) return;

    final isBookmarked = _bookmarkedArticles.contains(article.url);

    if (isBookmarked) {
      await _bookmarksService.removeBookmark(article);
      setState(() {
        _bookmarkedArticles.remove(article.url);
      });
    } else {
      await _bookmarksService.addBookmark(article);
      setState(() {
        _bookmarkedArticles.add(article.url!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (widget.articles.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No articles available',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.articles.length,
      itemBuilder: (context, index) {
        final article = widget.articles[index];
        final isBookmarked = article.url != null &&
            _bookmarkedArticles.contains(article.url);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          color: isDarkMode ? Colors.grey[850] : Colors.white,
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
              ).then((_) => _loadBookmarks());
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: article.imageUrl != null
                      ? CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: isDarkMode ? Colors.white54 : Colors.black38,
                      ),
                    ),
                  )
                      : Container(
                    height: 180,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: isDarkMode ? Colors.white54 : Colors.black38,
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source and time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              article.sourceName ?? 'News',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            article.timeAgo,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        article.title ?? 'No title',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Description
                      if (article.description != null)
                        Text(
                          article.description!,
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 16),

                      // Actions
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[200],
                            child: Text(
                              article.author?.isNotEmpty == true
                                  ? article.author![0].toUpperCase()
                                  : 'A',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              article.author ?? 'Unknown',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border_outlined,
                              color: isBookmarked
                                  ? Theme.of(context).primaryColor
                                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                            ),
                            onPressed: () => _toggleBookmark(article),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.share_outlined,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            onPressed: () {
                              // TODO: Implement share functionality
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}