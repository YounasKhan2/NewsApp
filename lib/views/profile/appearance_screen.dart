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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Theme updated. Restart app to see all changes.'),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final containerColor = isDarkMode ? Colors.grey[900] : Colors.grey[200];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              icon: Icons.brightness_auto,
              title: 'System default',
              subtitle: 'Follow system theme',
              value: 'system',
              isDarkMode: isDarkMode,
            ),
            _buildThemeOption(
              icon: Icons.light_mode,
              title: 'Light',
              subtitle: 'Light color theme',
              value: 'light',
              isDarkMode: isDarkMode,
            ),
            _buildThemeOption(
              icon: Icons.dark_mode,
              title: 'Dark',
              subtitle: 'Dark color theme',
              value: 'dark',
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 32),
            Text(
              'Current theme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkMode ? Colors.amber : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isDarkMode ? 'Dark theme active' : 'Light theme active',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: textColor,
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
    required bool isDarkMode,
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
          Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black87),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
      activeColor: Theme.of(context).primaryColor,
      secondary: isSelected
          ? Icon(Icons.check, color: isDarkMode ? Colors.amber : Colors.blue)
          : null,
    );
  }
}
