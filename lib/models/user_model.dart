// lib/models/article.dart
class Article {
  final String? title;
  final String? description;
  final String? content;
  final String? url;
  final String? imageUrl;
  final String? sourceName;
  final DateTime? publishedAt;
  final String? author;

  Article({
    this.title,
    this.description,
    this.content,
    this.url,
    this.imageUrl,
    this.sourceName,
    this.publishedAt,
    this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      description: json['description'],
      content: json['content'],
      url: json['url'],
      imageUrl: json['urlToImage'],
      sourceName: json['source']?['name'],
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      author: json['author'],
    );
  }

  String get timeAgo {
    if (publishedAt == null) return '';

    final difference = DateTime.now().difference(publishedAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}