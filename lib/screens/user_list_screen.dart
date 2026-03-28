import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    String ini = parts[0][0].toUpperCase();
    if (parts.length > 1 && parts[1].isNotEmpty) {
      ini += parts[1][0].toUpperCase();
    }
    return ini;
  }

  Color _avatarColor(String initials) {
    const colors = [
      Color(0xFFD4C5B2),
      Color(0xFFB2C5D4),
      Color(0xFFB2D4C5),
      Color(0xFFD4B2C5),
      Color(0xFFC5D4B2),
      Color(0xFFC5B2D4),
    ];
    final code = initials.codeUnitAt(0) +
        (initials.length > 1 ? initials.codeUnitAt(1) : 0);
    return colors[code % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final chatService = ChatService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'New Message',
          style: GoogleFonts.newsreader(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: GoogleFonts.newsreader(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Filter out the current user
          final users = snapshot.data!.docs
              .where((doc) => doc.id != currentUid)
              .toList();

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No other users yet',
                    style: GoogleFonts.newsreader(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Invite friends to join Murmur.',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: users.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 80,
              color: Colors.grey.withAlpha(30),
            ),
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final uid = users[index].id;
              final name = (data['name'] as String?) ?? 'Unknown';
              final email = (data['email'] as String?) ?? '';
              final initials = _initials(name);
              final bg = _avatarColor(initials);

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: GoogleFonts.newsreader(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D1D1F),
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: GoogleFonts.newsreader(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  email,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                onTap: () {
                  final chatId =
                      chatService.getChatId(currentUid!, uid);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chatId,
                        otherUserId: uid,
                        otherUserName: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
