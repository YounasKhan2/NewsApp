// lib/views/article/article_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pulse_news/models/article.dart';
import 'package:pulse_news/services/bookmarks_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final BookmarksService _bookmarksService = BookmarksService();
  bool _isBookmarked = false;
  bool _isLoading = true;
  double _textScaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    if (widget.article.url == null) return;

    final bookmarks = await _bookmarksService.getBookmarkedArticles();
    final isBookmarked = bookmarks.any((article) =>
    article.url == widget.article.url);

    setState(() {
      _isBookmarked = isBookmarked;
      _isLoading = false;
    });
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _isLoading = true;
    });

    if (_isBookmarked) {
      await _bookmarksService.removeBookmark(widget.article);
    } else {
      await _bookmarksService.addBookmark(widget.article);
    }

    setState(() {
      _isBookmarked = !_isBookmarked;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked
            ? 'Article saved to bookmarks'
            : 'Article removed from bookmarks'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareArticle() {
    if (widget.article.url != null) {
      Share.share(
        'Check out this article: ${widget.article.title}\n${widget.article.url}',
        subject: widget.article.title,
      );
    }
  }

  void _openArticleUrl() async {
    if (widget.article.url != null) {
      final Uri uri = Uri.parse(widget.article.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    }
  }

  void _increaseTextSize() {
    setState(() {
      _textScaleFactor += 0.1;
    });
  }

  void _decreaseTextSize() {
    setState(() {
      _textScaleFactor -= 0.1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.sourceName ?? 'Article',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined,
              color: _isBookmarked ? Theme.of(context).primaryColor : null,
            ),
            onPressed: _isLoading ? null : _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareArticle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feature Image
            if (widget.article.imageUrl != null)
              CachedNetworkImage(
                imageUrl: widget.article.imageUrl!,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 240,
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 240,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              )
            else
              Container(
                height: 240,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, size: 50),
              ),

            // Article Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.article.title ?? 'No title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          widget.article.author?.isNotEmpty == true
                              ? widget.article.author![0].toUpperCase()
                              : 'A',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.article.author ?? 'Unknown Author',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.article.publishedAt != null
                                  ? _formatDate(widget.article.publishedAt!)
                                  : 'Unknown date',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (widget.article.description != null)
                    Text(
                      widget.article.description!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Content
                  if (widget.article.content != null)
                    Html(
                      data: _formatContent(widget.article.content!),
                      style: {
                        "body": Style(
                          fontSize: FontSize(16 * _textScaleFactor),
                          lineHeight: LineHeight(1.6),
                        ),
                        "a": Style(
                          color: Theme.of(context).primaryColor,
                          textDecoration: TextDecoration.none,
                        ),
                      },
                      onLinkTap: (String? url, Map<String, String> attributes, element) async {
                        if (url != null) {
                          final Uri uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.inAppWebView);
                          }
                        }
                      },
                    )
                  else
                    const Text(
                      'No content available',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Source link
                  if (widget.article.url != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Source:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _openArticleUrl,
                          child: Text(
                            widget.article.url!,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 60), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: _isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_border_outlined,
                label: _isBookmarked ? 'Saved' : 'Save',
                color: _isBookmarked ? Theme.of(context).primaryColor : null,
                onTap: _toggleBookmark,
              ),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: _shareArticle,
              ),
              _buildActionButton(
                icon: Icons.text_increase,
                label: 'Text Size',
                onTap: _increaseTextSize,
              ),
              _buildActionButton(
                icon: Icons.text_decrease,
                label: 'Text Size',
                onTap: _decreaseTextSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
  }

  String _formatContent(String content) {
    // Remove truncation markers that sometimes come from News API
    final cleanContent = content.replaceAll(RegExp(r'\[\+\d+ chars\]$'), '');

    // Wrap in paragraph tags if needed
    if (!cleanContent.trim().startsWith('<')) {
      return '<p>${cleanContent.trim()}</p>';
    }

    return cleanContent;
  }
}