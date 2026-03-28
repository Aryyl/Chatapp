import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  /// Save (or update) user data in Firestore so they are discoverable.
  Future<void> _saveUserToFirestore(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName ?? '',
      'email': user.email ?? '',
    }, SetOptions(merge: true));
  }

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _saveUserToFirestore(credential.user!);
      }
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signup(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set display name first so it's available when saving to Firestore
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      final freshUser = _auth.currentUser;

      if (freshUser != null) {
        await _firestore.collection('users').doc(freshUser.uid).set({
          'uid': freshUser.uid,
          'name': name,
          'email': email,
        }, SetOptions(merge: true));
      }

      return freshUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
