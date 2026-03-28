import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Chat ID ────────────────────────────────────────────────────────────────
  /// Returns a deterministic, sorted chat ID for two UIDs so both users always
  /// resolve the same document regardless of who initiates the conversation.
  String getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // ── Send Message ───────────────────────────────────────────────────────────
  /// Sends a message to chats/{chatId}/messages.
  /// Also ensures the parent chat document exists with a participants list.
  Future<void> sendMessage(String chatId, String text) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null || text.trim().isEmpty) return;

    final chatRef = _firestore.collection('chats').doc(chatId);

    // Extract both UIDs from the deterministic chatId
    final participants = chatId.split('_');

    // Create/update the chat doc (SetOptions.merge so we don't overwrite existing)
    await chatRef.set({
      'participants': participants,
      'lastMessage': text.trim(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Add the message to the sub-collection
    await chatRef.collection('messages').add({
      'senderId': currentUid,
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ── Get Messages ──────────────────────────────────────────────────────────
  /// Returns a real-time stream of messages in a chat, ordered by timestamp.
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // ── Get Chat Rooms ────────────────────────────────────────────────────────
  /// Returns a real-time stream of all chats the current user participates in.
  Stream<QuerySnapshot> getChatRooms(String uid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  // ── Get All Users ─────────────────────────────────────────────────────────
  /// Returns a real-time stream of all registered users (excluding the current user).
  Stream<QuerySnapshot> getUsers() {
    return _firestore.collection('users').snapshots();
  }

  // ── Get Single User ───────────────────────────────────────────────────────
  Future<DocumentSnapshot> getUser(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }
}
