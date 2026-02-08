class AppDatabaseSchema {
  static const String createUsersTable = '''
    CREATE TABLE users (
        user_id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        display_name TEXT,
        photo_url TEXT,
        auth_provider TEXT NOT NULL CHECK(auth_provider IN ('google', 'facebook', 'firebase', 'mongodb')),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_login INTEGER,
        is_active INTEGER DEFAULT 1,
        theme_preference TEXT DEFAULT 'system' CHECK(theme_preference IN ('light', 'dark', 'system')),
        sync_status TEXT DEFAULT 'synced' CHECK(sync_status IN ('synced', 'pending', 'conflict')),
        last_sync INTEGER,
        device_id TEXT
    );
  ''';

  static const String createSubjectsTable = '''
    CREATE TABLE subjects (
        subject_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        subject_name TEXT NOT NULL,
        subject_code TEXT,
        description TEXT,
        color TEXT,
        semester TEXT,
        professor_name TEXT,
        schedule TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_archived INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced',
        last_sync INTEGER,
        server_id TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    );
  ''';

  static const String createTasksTable = '''
    CREATE TABLE tasks (
        task_id TEXT PRIMARY KEY,
        subject_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date INTEGER,
        priority TEXT DEFAULT 'medium' CHECK(priority IN ('low', 'medium', 'high', 'urgent')),
        status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'in_progress', 'completed', 'overdue')),
        grade REAL,
        max_grade REAL DEFAULT 10.0,
        weight REAL DEFAULT 1.0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        completed_at INTEGER,
        sync_status TEXT DEFAULT 'synced',
        last_sync INTEGER,
        server_id TEXT,
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    );
  ''';

  static const String createAttachmentsTable = '''
    CREATE TABLE attachments (
        attachment_id TEXT PRIMARY KEY,
        task_id TEXT,
        subject_id TEXT,
        user_id TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_type TEXT NOT NULL CHECK(file_type IN ('pdf', 'image', 'document', 'other')),
        file_path TEXT NOT NULL,
        file_size INTEGER,
        cloud_url TEXT,
        mime_type TEXT,
        thumbnail_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'synced',
        last_sync INTEGER,
        upload_progress INTEGER DEFAULT 0,
        server_id TEXT,
        FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    );
  ''';

  static const String createGradesTable = '''
    CREATE TABLE grades (
        grade_id TEXT PRIMARY KEY,
        subject_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        grade_type TEXT NOT NULL CHECK(grade_type IN ('exam', 'homework', 'project', 'participation', 'quiz', 'other')),
        grade_name TEXT NOT NULL,
        score REAL NOT NULL,
        max_score REAL NOT NULL,
        percentage REAL,
        weight REAL DEFAULT 1.0,
        date INTEGER NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'synced',
        last_sync INTEGER,
        server_id TEXT,
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    );
  ''';

  static const String createCalendarEventsTable = '''
    CREATE TABLE calendar_events (
        event_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        subject_id TEXT,
        task_id TEXT,
        event_type TEXT NOT NULL CHECK(event_type IN ('class', 'exam', 'deadline', 'reminder', 'custom')),
        title TEXT NOT NULL,
        description TEXT,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        location TEXT,
        is_all_day INTEGER DEFAULT 0,
        color TEXT,
        recurrence_rule TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'synced',
        last_sync INTEGER,
        server_id TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE SET NULL,
        FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE
    );
  ''';

  static const String createNotificationsTable = '''
    CREATE TABLE notifications (
        notification_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        task_id TEXT,
        event_id TEXT,
        notification_type TEXT NOT NULL CHECK(notification_type IN ('local', 'push', 'scheduled')),
        title TEXT NOT NULL,
        body TEXT,
        scheduled_time INTEGER,
        sent_at INTEGER,
        is_read INTEGER DEFAULT 0,
        is_sent INTEGER DEFAULT 0,
        priority TEXT DEFAULT 'default' CHECK(priority IN ('min', 'low', 'default', 'high', 'max')),
        action_type TEXT,
        action_data TEXT,
        created_at INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'synced',
        server_id TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
        FOREIGN KEY (event_id) REFERENCES calendar_events(event_id) ON DELETE CASCADE
    );
  ''';

  static const String createReadingsTable = '''
    CREATE TABLE readings (
        reading_id TEXT PRIMARY KEY,
        subject_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        file_path TEXT,
        cloud_url TEXT,
        file_size INTEGER,
        total_pages INTEGER,
        current_page INTEGER DEFAULT 0,
        reading_progress REAL DEFAULT 0.0,
        is_completed INTEGER DEFAULT 0,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_read INTEGER,
        sync_status TEXT DEFAULT 'synced',
        last_sync INTEGER,
        server_id TEXT,
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    );
  ''';

  static const String createSubjectStatisticsTable = '''
    CREATE TABLE subject_statistics (
        stat_id TEXT PRIMARY KEY,
        subject_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        total_tasks INTEGER DEFAULT 0,
        completed_tasks INTEGER DEFAULT 0,
        pending_tasks INTEGER DEFAULT 0,
        overdue_tasks INTEGER DEFAULT 0,
        average_grade REAL DEFAULT 0.0,
        total_grades INTEGER DEFAULT 0,
        attendance_percentage REAL DEFAULT 0.0,
        study_hours REAL DEFAULT 0.0,
        last_calculated INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'synced',
        last_sync INTEGER,
        server_id TEXT,
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        UNIQUE(subject_id, user_id)
    );
  ''';

  static const String createSyncHistoryTable = '''
    CREATE TABLE sync_history (
        sync_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        sync_type TEXT NOT NULL CHECK(sync_type IN ('full', 'partial', 'upload', 'download')),
        entity_type TEXT,
        entity_id TEXT,
        operation TEXT CHECK(operation IN ('create', 'update', 'delete')),
        status TEXT NOT NULL CHECK(status IN ('pending', 'in_progress', 'completed', 'failed', 'conflict')),
        started_at INTEGER NOT NULL,
        completed_at INTEGER,
        error_message TEXT,
        retry_count INTEGER DEFAULT 0,
        local_data TEXT,
        server_data TEXT,
        conflict_resolution TEXT CHECK(conflict_resolution IN ('local_wins', 'server_wins', 'merged', 'manual')),
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    );
  ''';

  static const String createAppSettingsTable = '''
    CREATE TABLE app_settings (
        setting_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        setting_key TEXT NOT NULL,
        setting_value TEXT NOT NULL,
        data_type TEXT DEFAULT 'string' CHECK(data_type IN ('string', 'boolean', 'integer', 'float', 'json')),
        updated_at INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'synced',
        last_sync INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        UNIQUE(user_id, setting_key)
    );
  ''';

  static const String createImageCacheTable = '''
    CREATE TABLE image_cache (
        cache_id TEXT PRIMARY KEY,
        url TEXT NOT NULL UNIQUE,
        local_path TEXT NOT NULL,
        file_size INTEGER,
        mime_type TEXT,
        last_accessed INTEGER NOT NULL,
        expiry_date INTEGER,
        created_at INTEGER NOT NULL
    );
  ''';

  // Indices
  static const List<String> createIndices = [
    'CREATE INDEX idx_users_email ON users(email)',
    'CREATE INDEX idx_users_sync_status ON users(sync_status)',
    'CREATE INDEX idx_subjects_user ON subjects(user_id)',
    'CREATE INDEX idx_subjects_sync ON subjects(sync_status)',
    'CREATE INDEX idx_subjects_archived ON subjects(is_archived)',
    'CREATE INDEX idx_tasks_subject ON tasks(subject_id)',
    'CREATE INDEX idx_tasks_user ON tasks(user_id)',
    'CREATE INDEX idx_tasks_status ON tasks(status)',
    'CREATE INDEX idx_tasks_due_date ON tasks(due_date)',
    'CREATE INDEX idx_tasks_sync ON tasks(sync_status)',
    'CREATE INDEX idx_attachments_subject ON attachments(subject_id)',
    'CREATE INDEX idx_grades_subject ON grades(subject_id)',
    'CREATE INDEX idx_events_start_date ON calendar_events(start_date)',
  ];

  // Triggers
  static const List<String> createTriggers = [
    '''
    CREATE TRIGGER update_users_timestamp 
    AFTER UPDATE ON users
    BEGIN
        UPDATE users SET updated_at = strftime('%s', 'now') WHERE user_id = NEW.user_id;
    END;
    ''',
    '''
    CREATE TRIGGER update_subjects_timestamp 
    AFTER UPDATE ON subjects
    BEGIN
        UPDATE subjects SET updated_at = strftime('%s', 'now') WHERE subject_id = NEW.subject_id;
    END;
    ''',
    '''
    CREATE TRIGGER update_tasks_timestamp 
    AFTER UPDATE ON tasks
    BEGIN
        UPDATE tasks SET updated_at = strftime('%s', 'now') WHERE task_id = NEW.task_id;
    END;
    ''',
  ];
}
