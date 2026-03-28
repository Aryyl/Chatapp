class Message {
  final String text;
  final String senderId;
  final bool isMine;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.senderId,
    required this.isMine,
    required this.timestamp,
  });
}
