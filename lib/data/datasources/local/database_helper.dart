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
  static const int _dbVersion = 3;

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

    if (oldVersion < 3) {
      // v3: Add cloud_url and server_id to attachments if missing
      // We use try-catch block for each column to avoid error if it already exists (unlikely but safe)
      // SQLite doesn't support IF NOT EXISTS for ADD COLUMN in standard syntax universally but usually safe to run.
      // Better approach: check prune, but for simplicity we assume missing.
      try {
        await db.execute('ALTER TABLE attachments ADD COLUMN cloud_url TEXT');
      } catch (e) {
        log('DatabaseHelper: cloud_url might already exist: $e');
      }
      try {
        await db.execute('ALTER TABLE attachments ADD COLUMN server_id TEXT');
      } catch (e) {
        log('DatabaseHelper: server_id might already exist: $e');
      }
      try {
        await db.execute(
          'ALTER TABLE attachments ADD COLUMN upload_progress INTEGER DEFAULT 0',
        );
      } catch (e) {
        log('DatabaseHelper: upload_progress might already exist: $e');
      }
      try {
        await db.execute(
          "ALTER TABLE attachments ADD COLUMN sync_status TEXT DEFAULT 'synced'",
        );
      } catch (e) {
        log('DatabaseHelper: sync_status might already exist: $e');
      }
      try {
        await db.execute(
          'ALTER TABLE attachments ADD COLUMN last_sync INTEGER',
        );
      } catch (e) {
        log('DatabaseHelper: last_sync might already exist: $e');
      }
      try {
        await db.execute('ALTER TABLE attachments ADD COLUMN mime_type TEXT');
      } catch (e) {
        log('DatabaseHelper: mime_type might already exist: $e');
      }
      try {
        await db.execute(
          'ALTER TABLE attachments ADD COLUMN thumbnail_path TEXT',
        );
      } catch (e) {
        log('DatabaseHelper: thumbnail_path might already exist: $e');
      }
      log(
        'DatabaseHelper: Migration to v3 completed (attachments columns added)',
      );
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
