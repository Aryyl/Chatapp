import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/theme_provider.dart';

class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appearance',
          style: GoogleFonts.newsreader(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Theme',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          _buildThemeRadio(
            'System Default',
            'Matches your device setting',
            ThemeMode.system,
          ),
          _buildThemeRadio(
            'Light',
            'Elegant off-white and charcoal',
            ThemeMode.light,
          ),
          _buildThemeRadio('Dark', 'Deep charcoal backdrops', ThemeMode.dark),
        ],
      ),
    );
  }

  Widget _buildThemeRadio(String title, String subtitle, ThemeMode mode) {
    final currentTheme = ref.watch(themeProvider);

    return RadioListTile<ThemeMode>(
      title: Text(title, style: GoogleFonts.newsreader(fontSize: 18)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      value: mode,
      groupValue: currentTheme,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: (ThemeMode? selectedMode) {
        if (selectedMode != null) {
          ref.read(themeProvider.notifier).setThemeMode(selectedMode);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title theme applied'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }
}
