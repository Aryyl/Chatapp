import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _messages = true;
  bool _calls = true;
  bool _mentions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
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
              'Alerts',
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
              'New Messages',
              style: GoogleFonts.newsreader(fontSize: 18),
            ),
            subtitle: Text(
              'Receive push notifications for new messages.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            value: _messages,
            onChanged: (bool value) {
              setState(() => _messages = value);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            title: Text(
              'Incoming Calls',
              style: GoogleFonts.newsreader(fontSize: 18),
            ),
            subtitle: Text(
              'Receive notifications when someone is calling you.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            value: _calls,
            onChanged: (bool value) {
              setState(() => _calls = value);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            title: Text(
              'Mentions',
              style: GoogleFonts.newsreader(fontSize: 18),
            ),
            subtitle: Text(
              'Receive alerts when your name is mentioned in groups.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            value: _mentions,
            onChanged: (bool value) {
              setState(() => _mentions = value);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
