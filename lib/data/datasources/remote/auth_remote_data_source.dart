import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../../core/error/exceptions.dart';

/// Remote data source for authentication using Firebase Auth
abstract class AuthRemoteDataSource {
  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign in with Facebook
  Future<UserModel> signInWithFacebook();

  /// Sign in with email and password
  Future<UserModel> signInWithEmailPassword(String email, String password);

  /// Register with email and password
  Future<UserModel> signUpWithEmailPassword(
    String email,
    String password,
    String? displayName,
  );

  /// Sign out
  Future<void> signOut();

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FacebookAuth facebookAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.facebookAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      if (userCredential.user == null) {
        throw AuthException('Google sign in failed - no user returned');
      }

      final userModel = _userFromFirebase(userCredential.user!, 'google');

      // Save/Update in Firestore
      await _saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google sign in failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      // Trigger the Facebook Sign In flow
      final LoginResult result = await facebookAuth.login();

      if (result.status != LoginStatus.success) {
        throw AuthException('Facebook sign in was cancelled or failed');
      }

      if (result.accessToken == null) {
        throw AuthException('Facebook sign in failed - no access token');
      }

      // Create a credential from the access token
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      final userModel = _userFromFirebase(userCredential.user!, 'facebook');

      // Save/Update in Firestore
      await _saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Facebook sign in failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Facebook sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw AuthException('Sign in failed - no user returned');
      }

      final userModel = _userFromFirebase(userCredential.user!, 'firebase');

      // Update last login in Firestore
      await _saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw AuthException('Registration failed - no user returned');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      final currentUser = firebaseAuth.currentUser ?? userCredential.user!;
      final userModel = _userFromFirebase(currentUser, 'firebase');

      // Save to Firestore
      await _saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        firebaseAuth.signOut(),
        facebookAuth.logOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    // Determine auth provider
    String provider = 'firebase';
    if (user.providerData.isNotEmpty) {
      final providerId = user.providerData.first.providerId;
      if (providerId.contains('google')) {
        provider = 'google';
      } else if (providerId.contains('facebook')) {
        provider = 'facebook';
      }
    }

    return _userFromFirebase(user, provider);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(
        'Failed to send password reset email: ${e.toString()}',
      );
    }
  }

  /// Convert Firebase User to UserModel
  UserModel _userFromFirebase(User firebaseUser, String authProvider) {
    final now = DateTime.now();
    return UserModel(
      userId: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      authProvider: authProvider,
      createdAt: firebaseUser.metadata.creationTime ?? now,
      updatedAt: now,
      lastLogin: now,
      isActive: true,
      themePreference: 'system',
      syncStatus: 'synced',
    );
  }

  /// Get user-friendly error message from Firebase error code
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      default:
        return 'Authentication failed. Please try again';
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      final userDoc = firestore.collection('users').doc(user.userId);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Create new user document
        await userDoc.set(user.toJson());
      } else {
        // Update existing user (e.g. last login)
        await userDoc.update({
          'last_login': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw AuthException('Failed to save user profile: ${e.toString()}');
    }
  }
}
