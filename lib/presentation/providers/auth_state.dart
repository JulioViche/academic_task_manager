import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Authentication status enumeration
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// State class for authentication
class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState(
        status: AuthStatus.initial,
        isLoading: false,
      );

  /// Loading state
  factory AuthState.loading() => const AuthState(
        status: AuthStatus.loading,
        isLoading: true,
      );

  /// Authenticated state with user
  factory AuthState.authenticated(UserEntity user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );

  /// Unauthenticated state
  factory AuthState.unauthenticated() => const AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );

  /// Error state with message
  factory AuthState.error(String message) => AuthState(
        status: AuthStatus.error,
        errorMessage: message,
        isLoading: false,
      );

  /// Copy with method for immutable state updates
  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  @override
  List<Object?> get props => [status, user, errorMessage, isLoading];
}
