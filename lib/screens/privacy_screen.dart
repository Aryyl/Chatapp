import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _readReceipts = true;
  bool _lastSeen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy',
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
              'Activity',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SwitchListTile(
            title: Text(
              'Read Receipts',
              style: GoogleFonts.newsreader(fontSize: 18),
            ),
            subtitle: Text(
              'Let others know when you\'ve read their messages.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            value: _readReceipts,
            onChanged: (bool value) {
              setState(() {
                _readReceipts = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            title: Text(
              'Last Seen',
              style: GoogleFonts.newsreader(fontSize: 18),
            ),
            subtitle: Text(
              'Show when you were last active.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            value: _lastSeen,
            onChanged: (bool value) {
              setState(() {
                _lastSeen = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Contacts',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Blocked Users',
              style: GoogleFonts.newsreader(fontSize: 18),
            ),
            subtitle: Text(
              'Manage your blocked contacts.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No blocked users.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
