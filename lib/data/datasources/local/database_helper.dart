import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'schema.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Increment this when schema changes
  static const int _dbVersion = 2;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'academic_task_manager.db');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Create Tables
    await db.execute(AppDatabaseSchema.createUsersTable);
    await db.execute(AppDatabaseSchema.createSubjectsTable);
    await db.execute(AppDatabaseSchema.createTasksTable);
    await db.execute(AppDatabaseSchema.createAttachmentsTable);
    await db.execute(AppDatabaseSchema.createGradesTable);
    await db.execute(AppDatabaseSchema.createCalendarEventsTable);
    await db.execute(AppDatabaseSchema.createNotificationsTable);
    await db.execute(AppDatabaseSchema.createReadingsTable);
    await db.execute(AppDatabaseSchema.createSubjectStatisticsTable);
    await db.execute(AppDatabaseSchema.createSyncHistoryTable);
    await db.execute(AppDatabaseSchema.createAppSettingsTable);
    await db.execute(AppDatabaseSchema.createSyncQueueTable);
    await db.execute(AppDatabaseSchema.createImageCacheTable);

    // Create Indices
    for (String indexSql in AppDatabaseSchema.createIndices) {
      await db.execute(indexSql);
    }

    // Create Triggers
    for (String triggerSql in AppDatabaseSchema.createTriggers) {
      await db.execute(triggerSql);
    }
  }

  /// Handle database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log('DatabaseHelper: Upgrading from v$oldVersion to v$newVersion');

    if (oldVersion < 2) {
      // v2: Add sync_queue table
      await db.execute(AppDatabaseSchema.createSyncQueueTable);
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sync_queue_status ON sync_queue(status)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sync_queue_table ON sync_queue(table_name)',
      );
      log('DatabaseHelper: Migration to v2 completed (sync_queue table added)');
    }
  }

  // Helper method to close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
