import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email & password
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    DateTime? dateOfBirth,
  }) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      if (credential.user == null) return null;

      final user = UserModel(
        uid: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        dateOfBirth: dateOfBirth,
        joinDate: DateTime.now(),
        friendId: _generateFriendId(credential.user!.uid),
      );

      try {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set(user.toMap());
      } catch (firestoreError) {
        // If Firestore fails, delete the auth user
        await credential.user!.delete();
        throw Exception('Failed to create user profile: $firestoreError');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login with email & password
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) return null;

      return await getUserData(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update(user.toMap());
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Generate and send OTP for password reset
  Future<String> generateAndSendOTP(String email) async {
    try {
      // Check if user exists
      final userQuery = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('No account found with this email');
      }

      // Generate 6-digit OTP
      final otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
          .toString(); // Generates 6-digit OTP

      // Store OTP in Firestore with expiration (10 minutes)
      await _firestore.collection('password_reset_otps').doc(email.trim()).set({
        'otp': otp,
        'email': email.trim(),
        'createdAt': DateTime.now(),
        'expiresAt': DateTime.now().add(const Duration(minutes: 10)),
      });

      // In production, send email with OTP
      // For now, you can use Firebase Cloud Functions or EmailJS
      // For testing, print the OTP to console
      debugPrint('OTP for password reset: $otp');

      return otp;
    } catch (e) {
      throw Exception('Failed to generate OTP: ${e.toString()}');
    }
  }

  // Verify OTP
  Future<bool> verifyPasswordResetOTP(String email, String otp) async {
    try {
      final doc = await _firestore
          .collection('password_reset_otps')
          .doc(email.trim())
          .get();

      if (!doc.exists) {
        throw Exception('No OTP request found for this email');
      }

      final data = doc.data()!;
      final storedOTP = data['otp'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      // Check if OTP is expired
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('OTP has expired. Please request a new one');
      }

      // Verify OTP
      if (storedOTP != otp) {
        throw Exception('Invalid OTP. Please try again');
      }

      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update password after OTP verification
  Future<void> updatePasswordAfterReset({
    required String email,
    required String newPassword,
  }) async {
    try {
      // Find user by email
      final userQuery = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      // Store the password update request in Firestore
      // In a production app, this would be handled by a Firebase Cloud Function
      // that has admin privileges to update the password
      await _firestore
          .collection('password_reset_requests')
          .doc(email.trim())
          .set({
            'email': email.trim(),
            'newPassword': newPassword,
            'verified': true,
            'requestedAt': DateTime.now(),
            'completed': false,
          });

      // Send an email confirmation
      // Note: In production, send actual email via Firebase Cloud Function
      debugPrint('Password reset request stored for: $email');
      debugPrint('New password: $newPassword (for demo purposes only)');

      // For security: In a real app, you should:
      // 1. Call a Firebase Cloud Function that has admin credentials
      // 2. The function will verify the request and update the password
      // 3. Send confirmation email

      // For MVP/demo purposes, we're storing the request
      // A Cloud Function listener should pick this up and update the auth password

      // Cleanup: Delete the OTP record
      await _firestore
          .collection('password_reset_otps')
          .doc(email.trim())
          .delete();
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  // Generate a unique friend ID from UID
  String _generateFriendId(String uid) {
    return uid.substring(0, 8).toUpperCase();
  }

  // Handle Firebase Auth errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
