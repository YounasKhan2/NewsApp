// lib/models/category.dart
class Category {
  final String name;
  final String apiName;
  final String iconPath;

  const Category({
    required this.name,
    required this.apiName,
    required this.iconPath,
  });

  static List<Category> getCategories() {
    return [
      const Category(
        name: 'General',
        apiName: 'general',
        iconPath: 'assets/icons/general.png',
      ),
      const Category(
        name: 'Business',
        apiName: 'business',
        iconPath: 'assets/icons/business.png',
      ),
      const Category(
        name: 'Technology',
        apiName: 'technology',
        iconPath: 'assets/icons/technology.png',
      ),
      const Category(
        name: 'Sports',
        apiName: 'sports',
        iconPath: 'assets/icons/sports.png',
      ),
      const Category(
        name: 'Entertainment',
        apiName: 'entertainment',
        iconPath: 'assets/icons/entertainment.png',
      ),
      const Category(
        name: 'Health',
        apiName: 'health',
        iconPath: 'assets/icons/health.png',
      ),
      const Category(
        name: 'Science',
        apiName: 'science',
        iconPath: 'assets/icons/science.png',
      ),
    ];
  }
}