import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

/// Local data source for authentication using SharedPreferences
abstract class AuthLocalDataSource {
  /// Get cached user from local storage
  Future<UserModel?> getCachedUser();

  /// Cache user to local storage
  Future<void> cacheUser(UserModel user);

  /// Clear cached user (for logout)
  Future<void> clearCache();

  /// Check if user is cached
  Future<bool> isUserCached();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'CACHED_USER';
  static const String _tokenKey = 'AUTH_TOKEN';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(_userKey);
    if (jsonString != null) {
      try {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      } catch (e) {
        // If parsing fails, clear invalid cache
        await clearCache();
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final jsonString = json.encode(user.toJson());
    await sharedPreferences.setString(_userKey, jsonString);
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_userKey);
    await sharedPreferences.remove(_tokenKey);
  }

  @override
  Future<bool> isUserCached() async {
    return sharedPreferences.containsKey(_userKey);
  }
}
