import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated {
    final user = _auth.currentUser;
    final isAuth = user != null;
    print("isAuthenticated check: $isAuth");
    return isAuth;
  }

  // Stream of authentication state changes
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Anonymous sign in
  Future<UserCredential> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      // Create anonymous user document in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': 'Anonymous User',
        'email': '',
        'isAnonymous': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return credential;
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
  }

  // Convert anonymous account to permanent
  Future<UserCredential> convertAnonymousAccount(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Check if current user is anonymous
      final currentUser = _auth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        throw Exception('No anonymous user signed in');
      }

      // Create email credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Link anonymous account with email credential
      final userCredential = await currentUser.linkWithCredential(credential);

      // Update user profile
      await userCredential.user!.updateDisplayName(name);

      // Update Firestore document
      await _firestore.collection('users').doc(currentUser.uid).update({
        'name': name,
        'email': email,
        'isAnonymous': false,
      });

      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Error converting anonymous account: $e');
      rethrow;
    }
  }

  // Create new account
  Future<UserCredential> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update display name
      await credential.user!.updateDisplayName(name);

      return credential;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Notify listeners immediately so UI can update
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      // Re-authenticate user before updating email
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email in Firebase Auth
      await user.updateEmail(newEmail);

      // Update email in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
      });

      notifyListeners();
    } catch (e) {
      print('Error updating email: $e');
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      // Re-authenticate user before updating password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      // Re-authenticate user before deletion
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore first
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_firestore.collection('users').doc(user.uid));

      // Delete all tasks for this user
      final taskSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('tasks')
              .get();

      for (var doc in taskSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Finally delete the user account
      await user.delete();

      notifyListeners();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}
