import 'package:flutter/material.dart';
import 'package:pulse_news/views/home/tabs/feed_tab.dart';
import 'package:pulse_news/views/home/tabs/categories_tab.dart';
import 'package:pulse_news/views/home/tabs/bookmarks_tab.dart';
import 'package:pulse_news/views/home/tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedTab(),
    const CategoriesTab(),
    const BookmarksTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 400),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.category_outlined,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            selectedIcon: Icon(
              Icons.category,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bookmark_outline,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            selectedIcon: Icon(
              Icons.bookmark,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            selectedIcon: Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<bool> onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
    return true;
  }
}