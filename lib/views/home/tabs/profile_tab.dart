// lib/views/home/tabs/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:pulse_news/services/auth_service.dart';
import 'package:pulse_news/services/bookmarks_service.dart';
import 'package:pulse_news/views/auth/login_screen.dart';
import 'package:pulse_news/views/profile/about_screen.dart';
import 'package:pulse_news/views/profile/appearance_screen.dart';
import 'package:pulse_news/views/profile/edit_profile_screen.dart';
import 'package:pulse_news/views/profile/help_support_screen.dart';
//-------------------
import 'package:pulse_news/services/reading_history_service.dart';
import 'package:pulse_news/views/profile/reading_history_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthService _authService = AuthService();
  final BookmarksService _bookmarksService = BookmarksService();
  bool _isLoading = false;
  int _savedArticlesCount = 0;
  //----------------------------
  final ReadingHistoryService _readingHistoryService = ReadingHistoryService();
  int _readingHistoryCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedArticlesCount();
    //----------------------------
    _loadReadingHistoryCount();
  }

  Future<void> _loadSavedArticlesCount() async {
    final savedArticles = await _bookmarksService.getBookmarkedArticles();
    setState(() {
      _savedArticlesCount = savedArticles.length;
    });
  }
//-----------------------------
  Future<void> _loadReadingHistoryCount() async {
    final count = await _readingHistoryService.getHistoryCount();
    setState(() {
      _readingHistoryCount = count;
    });
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await _authService.signOut();

                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    }
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to sign out. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Sign Out'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppearanceScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme
                        .of(context)
                        .primaryColor
                        .withOpacity(0.2),
                    child: Text(
                      user?.email?.isNotEmpty == true
                          ? user!.email![0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.userMetadata?['full_name'] as String? ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Stats Section
            const Text(
              'Your Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.bookmark,
                    _savedArticlesCount.toString(),
                    'Saved Articles',
                  ),
                ),
                const SizedBox(width: 16),
                //-----------------------------
                // In ProfileTab
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReadingHistoryScreen(),
                        ),
                      ).then((_) => _loadReadingHistoryCount());
                    },
                    child: _buildStatCard(
                      context,
                      Icons.history,
                      _readingHistoryCount.toString(),
                      'Reading History',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Account Section
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAccountOption(
              context,
              Icons.person_outline,
              'Edit Profile',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                ).then((updated) {
                  if (updated == true) {
                    setState(() {}); // Refresh profile data
                  }
                });
              },
            ),
            _buildDivider(),
            _buildAccountOption(
              context,
              Icons.notifications_outlined,
              'Notification Settings',
                  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Notifications will be implemented in a future update'),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildAccountOption(
              context,
              Icons.color_lens_outlined,
              'Appearance',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppearanceScreen(),
                  ),
                ).then((_) =>
                    setState(() {})); // Refresh to apply theme changes
              },
            ),
            _buildDivider(),
            _buildAccountOption(
              context,
              Icons.help_outline,
              'Help & Support',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildAccountOption(
              context,
              Icons.info_outline,
              'About',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildAccountOption(
              context,
              Icons.exit_to_app,
              'Sign Out',
              _signOut,
              isDestructive: true,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String count,
      String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme
                .of(context)
                .primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme
                  .of(context)
                  .brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOption(BuildContext context,
      IconData icon,
      String label,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    final isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Colors.red
            : isDarkMode ? Colors.grey[300] : Colors.grey[700],
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive
              ? Colors.red
              : isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme
          .of(context)
          .brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[200],
    );
  }
}