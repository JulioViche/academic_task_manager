import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String authProvider;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String themePreference;
  final String syncStatus;
  final DateTime? lastSync;

  const UserEntity({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.authProvider,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.isActive = true,
    this.themePreference = 'system',
    this.syncStatus = 'synced',
    this.lastSync,
  });

  @override
  List<Object?> get props => [
    userId,
    email,
    displayName,
    photoUrl,
    authProvider,
    createdAt,
    updatedAt,
    lastLogin,
    isActive,
    themePreference,
    syncStatus,
    lastSync,
  ];
}
