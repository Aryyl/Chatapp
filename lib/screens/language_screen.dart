import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Hindi',
    'Mandarin',
    'Japanese',
    'Korean',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Language',
          style: GoogleFonts.newsreader(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _languages.length,
        separatorBuilder: (context, index) => Divider(
          indent: 16,
          endIndent: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = language == _selectedLanguage;

          return ListTile(
            title: Text(
              language,
              style: GoogleFonts.newsreader(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : const SizedBox(),
            onTap: () {
              setState(() {
                _selectedLanguage = language;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('App language set to $language')),
              );
            },
          );
        },
      ),
    );
  }
}
