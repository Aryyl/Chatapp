class Contact {
  final String id;
  final String name;
  final String email;
  final String avatarInitials;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int unreadCount;

  const Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarInitials,
    required this.lastMessage,
    required this.time,
    this.isOnline = false,
    this.unreadCount = 0,
  });
}
