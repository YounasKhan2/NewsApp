// lib/views/profile/appearance_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({Key? key}) : super(key: key);

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String _selectedTheme = 'system';

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('theme_mode') ?? 'system';
    });
  }

  Future<void> _setThemePreference(String theme) async {
    setState(() => _selectedTheme = theme);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', theme);

    // Recreate main app to apply theme change immediately
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Theme updated. Restart app to see all changes.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              icon: Icons.brightness_auto,
              title: 'System default',
              subtitle: 'Follow system theme',
              value: 'system',
            ),
            _buildThemeOption(
              icon: Icons.light_mode,
              title: 'Light',
              subtitle: 'Light color theme',
              value: 'light',
            ),
            _buildThemeOption(
              icon: Icons.dark_mode,
              title: 'Dark',
              subtitle: 'Dark color theme',
              value: 'dark',
            ),

            const SizedBox(height: 32),
            const Text(
              'Current theme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkMode ? Colors.amber : Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isDarkMode ? 'Dark theme active' : 'Light theme active',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedTheme == value;

    return RadioListTile<String>(
      value: value,
      groupValue: _selectedTheme,
      onChanged: (newValue) {
        if (newValue != null) {
          _setThemePreference(newValue);
        }
      },
      title: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
      secondary: isSelected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
    );
  }
}