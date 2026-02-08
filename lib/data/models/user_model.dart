import '/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.authProvider,
    required super.createdAt,
    required super.updatedAt,
    super.lastLogin,
    super.isActive,
    super.themePreference,
    super.syncStatus,
    super.lastSync,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      email: json['email'],
      displayName: json['display_name'],
      photoUrl: json['photo_url'],
      authProvider: json['auth_provider'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at']),
      lastLogin: json['last_login'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_login'])
          : null,
      isActive: json['is_active'] == 1,
      themePreference: json['theme_preference'] ?? 'system',
      syncStatus: json['sync_status'] ?? 'synced',
      lastSync: json['last_sync'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_sync'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'auth_provider': authProvider,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'last_login': lastLogin?.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
      'theme_preference': themePreference,
      'sync_status': syncStatus,
      'last_sync': lastSync?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      authProvider: entity.authProvider,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastLogin: entity.lastLogin,
      isActive: entity.isActive,
      themePreference: entity.themePreference,
      syncStatus: entity.syncStatus,
      lastSync: entity.lastSync,
    );
  }
}
