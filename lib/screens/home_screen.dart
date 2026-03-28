import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'appearance_screen.dart';
import 'chat_screen.dart';
import 'edit_profile_screen.dart';
import 'language_screen.dart';
import 'notifications_screen.dart';
import 'privacy_screen.dart';
import 'user_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [_ChatsTab(), _CallsTab(), _ProfileTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_outlined),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ChatsTab extends StatelessWidget {
  const _ChatsTab();

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

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      final h = dt.hour > 12
          ? dt.hour - 12
          : dt.hour == 0
              ? 12
              : dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final a = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $a';
    }
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final chatService = ChatService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.newsreader(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserListScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.edit_outlined),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getChatRooms(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: GoogleFonts.newsreader(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap ✏️ to start a conversation.',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final chatDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.only(top: 8),
            itemCount: chatDocs.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 84,
              color: Colors.grey.withAlpha(30),
            ),
            itemBuilder: (context, index) {
              final data = chatDocs[index].data() as Map<String, dynamic>;
              final chatId = chatDocs[index].id;
              final participants =
                  List<String>.from(data['participants'] ?? []);
              final otherUid = participants.firstWhere(
                (uid) => uid != currentUid,
                orElse: () => '',
              );
              final lastMessage = (data['lastMessage'] as String?) ?? '';
              final lastMessageAt = data['lastMessageAt'] as Timestamp?;

              return FutureBuilder<DocumentSnapshot>(
                future: chatService.getUser(otherUid),
                builder: (context, userSnap) {
                  String name = 'Loading...';
                  String initials = '?';
                  Color bg = const Color(0xFFD4C5B2);

                  if (userSnap.hasData && userSnap.data!.exists) {
                    final userData =
                        userSnap.data!.data() as Map<String, dynamic>;
                    name = (userData['name'] as String?) ?? 'Unknown';
                    initials = _initials(name);
                    bg = _avatarColor(initials);
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 52,
                      height: 52,
                      decoration:
                          BoxDecoration(color: bg, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: GoogleFonts.newsreader(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1D1D1F),
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: GoogleFonts.newsreader(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.55),
                      ),
                    ),
                    trailing: Text(
                      _formatTimestamp(lastMessageAt),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId,
                            otherUserId: otherUid,
                            otherUserName: name,
                          ),
                        ),
                      );
                    },
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

class _CallsTab extends StatelessWidget {
  const _CallsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calls',
          style: GoogleFonts.newsreader(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No recent calls',
              style: GoogleFonts.newsreader(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your call history will appear here.',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    // Get real user data
    final user = AuthService().currentUser;
    final String displayName = user?.displayName ?? 'User';
    final String email = user?.email ?? 'No email';

    // Create initials from display name
    String initials = 'U';
    if (displayName.isNotEmpty) {
      final List<String> parts = displayName.trim().split(' ');
      if (parts.isNotEmpty) {
        initials = parts[0][0].toUpperCase();
        if (parts.length > 1 && parts[1].isNotEmpty) {
          initials += parts[1][0].toUpperCase();
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.newsreader(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                _Avatar(initials: initials, size: 88),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: GoogleFonts.newsreader(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSettingsSection(context, 'Account', [
            _buildSettingsTile(
              context,
              Icons.person_outline,
              'Edit Profile',
              () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                // If the screen returns true, the name was updated. Force a rebuild of this tab.
                if (result == true) {
                  // We do this by triggering a setState in the parent HomeScreen,
                  // or by just rebuilding this tab.
                  (context as Element).markNeedsBuild();
                }
              },
            ),
            _buildSettingsTile(
              context,
              Icons.notifications_outlined,
              'Notifications',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(context, Icons.lock_outline, 'Privacy', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            }),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(context, 'Preferences', [
            _buildSettingsTile(
              context,
              Icons.dark_mode_outlined,
              'Appearance',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppearanceScreen()),
                );
              },
            ),
            _buildSettingsTile(
              context,
              Icons.language_outlined,
              'Language',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguageScreen()),
                );
              },
            ),
          ]),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await AuthService().logout();
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 22,
      ),
      title: Text(title, style: GoogleFonts.newsreader(fontSize: 17)),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;

  const _Avatar({required this.initials, required this.size});

  // Generate a subtle, elegant colour from the initials
  Color _colorFromInitials() {
    const colors = [
      Color(0xFFD4C5B2),
      Color(0xFFB2C5D4),
      Color(0xFFB2D4C5),
      Color(0xFFD4B2C5),
      Color(0xFFC5D4B2),
      Color(0xFFC5B2D4),
    ];
    final code =
        initials.codeUnitAt(0) +
        (initials.length > 1 ? initials.codeUnitAt(1) : 0);
    return colors[code % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bg = _colorFromInitials();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.newsreader(
          fontSize: size * 0.33,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1D1D1F),
        ),
      ),
    );
  }
}
