// lib/views/profile/about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final String _appVersion = '1.0.0';
  final String _buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App Logo and Name
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.article_rounded,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pulse News',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version $_appVersion (Build $_buildNumber)',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // App Description
          const Text(
            'Pulse News brings you the latest headlines, breaking news updates, and in-depth coverage from around the world. Stay informed with personalized news feed, save articles for later, and customize your reading experience.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Developer Info
          const ListTile(
            title: Text('Developed by'),
            subtitle: Text('Pulse News Team'),
            leading: Icon(Icons.code),
          ),

          const Divider(),

          // Data Source
          const ListTile(
            title: Text('Powered by'),
            subtitle: Text('News API'),
            leading: Icon(Icons.source),
          ),

          const Divider(),

          // Privacy Policy
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening privacy policy...'),
                ),
              );
            },
          ),

          const Divider(),

          // Terms of Service
          ListTile(
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening terms of service...'),
                ),
              );
            },
          ),

          const Divider(),

          // Open Source Licenses
          ListTile(
            title: const Text('Open Source Licenses'),
            leading: const Icon(Icons.menu_book),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Pulse News',
                applicationVersion: _appVersion,
              );
            },
          ),

          const SizedBox(height: 48),

          // Copyright
          Text(
            '© ${DateTime.now().year} Pulse News. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}