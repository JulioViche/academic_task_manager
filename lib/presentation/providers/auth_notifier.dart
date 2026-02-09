import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/network_info.dart';
import '../../data/datasources/local/auth_local_data_source.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/user_dao.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login_with_google.dart';
import '../../domain/usecases/auth/login_with_facebook.dart';
import '../../domain/usecases/auth/login_with_email.dart';
import '../../domain/usecases/auth/register_with_email.dart';
import '../../domain/usecases/auth/logout.dart';
import '../../domain/usecases/auth/get_current_user.dart';

import 'auth_state.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

/// Provider for DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// Provider for AuthLocalDataSource
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

/// Provider for AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
    facebookAuth: FacebookAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

/// Provider for UserDao
final userDaoProvider = Provider<UserDao>((ref) {
  return UserDaoImpl(databaseHelper: ref.watch(databaseHelperProvider));
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    userDao: ref.watch(userDaoProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

/// Use case providers
final loginWithGoogleProvider = Provider<LoginWithGoogle>((ref) {
  return LoginWithGoogle(ref.watch(authRepositoryProvider));
});

final loginWithFacebookProvider = Provider<LoginWithFacebook>((ref) {
  return LoginWithFacebook(ref.watch(authRepositoryProvider));
});

final loginWithEmailProvider = Provider<LoginWithEmail>((ref) {
  return LoginWithEmail(ref.watch(authRepositoryProvider));
});

final registerWithEmailProvider = Provider<RegisterWithEmail>((ref) {
  return RegisterWithEmail(ref.watch(authRepositoryProvider));
});

final logoutProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});

/// AuthNotifier StateNotifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginWithGoogle loginWithGoogle;
  final LoginWithFacebook loginWithFacebook;
  final LoginWithEmail loginWithEmail;
  final RegisterWithEmail registerWithEmail;
  final Logout logout;
  final GetCurrentUser getCurrentUser;

  AuthNotifier({
    required this.loginWithGoogle,
    required this.loginWithFacebook,
    required this.loginWithEmail,
    required this.registerWithEmail,
    required this.logout,
    required this.getCurrentUser,
  }) : super(AuthState.initial());

  /// Check current authentication status
  Future<void> checkAuthStatus() async {
    state = AuthState.loading();

    final result = await getCurrentUser();
    result.fold((failure) => state = AuthState.unauthenticated(), (user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    });
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = AuthState.loading();

    final result = await loginWithGoogle();
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Sign in with Facebook
  Future<void> signInWithFacebook() async {
    state = AuthState.loading();

    final result = await loginWithFacebook();
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Sign in with email and password
  Future<void> signInWithEmailPassword(String email, String password) async {
    state = AuthState.loading();

    final result = await loginWithEmail(email, password);
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Register with email and password
  Future<void> registerWithEmailPassword(
    String email,
    String password,
    String? displayName,
  ) async {
    state = AuthState.loading();

    final result = await registerWithEmail(email, password, displayName);
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Sign out
  Future<void> signOut() async {
    state = AuthState.loading();

    final result = await logout();
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = AuthState.unauthenticated(),
    );
  }

  /// Clear error state
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }
}

/// Provider for AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    loginWithGoogle: ref.watch(loginWithGoogleProvider),
    loginWithFacebook: ref.watch(loginWithFacebookProvider),
    loginWithEmail: ref.watch(loginWithEmailProvider),
    registerWithEmail: ref.watch(registerWithEmailProvider),
    logout: ref.watch(logoutProvider),
    getCurrentUser: ref.watch(getCurrentUserProvider),
  );
});
