import 'package:sqflite/sqflite.dart';
import '../../models/user_model.dart';
import 'database_helper.dart';

/// Data Access Object for User operations in SQLite
abstract class UserDao {
  Future<void> insertOrUpdateUser(UserModel user);
  Future<UserModel?> getUser(String odId);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
}

class UserDaoImpl implements UserDao {
  final DatabaseHelper databaseHelper;

  UserDaoImpl({required this.databaseHelper});

  @override
  Future<void> insertOrUpdateUser(UserModel user) async {
    final db = await databaseHelper.database;
    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final db = await databaseHelper.database;
    await db.update(
      'users',
      user.toJson(),
      where: 'user_id = ?',
      whereArgs: [user.userId],
    );
  }

  @override
  Future<void> deleteUser(String userId) async {
    final db = await databaseHelper.database;
    await db.delete(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
