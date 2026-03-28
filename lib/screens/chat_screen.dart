import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _chatService.sendMessage(widget.chatId, text);
    _scrollToBottom();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
            ? 12
            : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final a = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $a';
  }

  bool _isSameMinute(Message a, Message b) =>
      a.timestamp.year == b.timestamp.year &&
      a.timestamp.month == b.timestamp.month &&
      a.timestamp.day == b.timestamp.day &&
      a.timestamp.hour == b.timestamp.hour &&
      a.timestamp.minute == b.timestamp.minute &&
      a.isMine == b.isMine;

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    String ini = parts[0][0].toUpperCase();
    if (parts.length > 1 && parts[1].isNotEmpty) {
      ini += parts[1][0].toUpperCase();
    }
    return ini;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            _buildAvatar(widget.otherUserName),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: GoogleFonts.newsreader(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.chatId),
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
                          size: 52,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Say hello 👋',
                          style: GoogleFonts.newsreader(
                            fontSize: 18,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                final messages = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ts = data['timestamp'] as Timestamp?;
                  return Message(
                    text: (data['text'] as String?) ?? '',
                    senderId: (data['senderId'] as String?) ?? '',
                    isMine: data['senderId'] == _currentUid,
                    timestamp: ts?.toDate() ?? DateTime.now(),
                  );
                }).toList();

                // Auto-scroll when new messages come in
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isLast = index == messages.length - 1;
                    final isLastInGroup = isLast ||
                        !_isSameMinute(msg, messages[index + 1]);
                    return _buildBubble(msg, isLastInGroup);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildAvatar(String name) {
    const colors = [
      Color(0xFFD4C5B2),
      Color(0xFFB2C5D4),
      Color(0xFFB2D4C5),
      Color(0xFFD4B2C5),
      Color(0xFFC5D4B2),
    ];
    final ini = _initials(name);
    final code = ini.codeUnitAt(0) + (ini.length > 1 ? ini.codeUnitAt(1) : 0);
    final bg = colors[code % colors.length];

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        ini,
        style: GoogleFonts.newsreader(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1D1D1F),
        ),
      ),
    );
  }

  Widget _buildBubble(Message msg, bool showTimestamp) {
    final isMine = msg.isMine;

    return Padding(
      padding: EdgeInsets.only(
        bottom: showTimestamp ? 16 : 3,
        left: isMine ? 48 : 0,
        right: isMine ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMine
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMine ? 20 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 20),
              ),
              border: isMine
                  ? null
                  : Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(25)),
              boxShadow: isMine
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.newsreader(
                fontSize: 17,
                height: 1.45,
                letterSpacing: 0.2,
                color: isMine
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (showTimestamp)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 4, right: 4),
              child: Text(
                _formatTime(msg.timestamp),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(20)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.grey.shade500),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark
                    ? Theme.of(context).colorScheme.surface
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(40),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: GoogleFonts.newsreader(
                          color: Colors.grey.shade400,
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                      ),
                      style: GoogleFonts.newsreader(fontSize: 17, height: 1.4),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4, bottom: 4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded),
                      onPressed: _sendMessage,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(36, 36),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic_none_outlined, color: Colors.grey.shade500),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
