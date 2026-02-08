# Database Model

```sql
-- ============================================
-- BASE DE DATOS: SISTEMA ACADÉMICO
-- Universidad de las Fuerzas Armadas - ESPE
-- Proyecto: Classroom Simplificado con Offline
-- ============================================

-- ============================================
-- 1. TABLA DE USUARIOS
-- ============================================
CREATE TABLE users (
    user_id TEXT PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    display_name TEXT,
    photo_url TEXT,
    auth_provider TEXT NOT NULL CHECK(auth_provider IN ('google', 'facebook', 'firebase', 'mongodb')),
    created_at INTEGER NOT NULL, -- timestamp
    updated_at INTEGER NOT NULL,
    last_login INTEGER,
    is_active INTEGER DEFAULT 1,
    theme_preference TEXT DEFAULT 'system' CHECK(theme_preference IN ('light', 'dark', 'system')),
    -- Sincronización
    sync_status TEXT DEFAULT 'synced' CHECK(sync_status IN ('synced', 'pending', 'conflict')),
    last_sync INTEGER,
    device_id TEXT
);

-- ============================================
-- 2. TABLA DE MATERIAS/CURSOS
-- ============================================
CREATE TABLE subjects (
    subject_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    subject_name TEXT NOT NULL,
    subject_code TEXT,
    description TEXT,
    color TEXT, -- Color para identificación visual
    semester TEXT,
    professor_name TEXT,
    schedule TEXT, -- JSON: días y horarios
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    is_archived INTEGER DEFAULT 0,
    -- Sincronización
    sync_status TEXT DEFAULT 'synced',
    last_sync INTEGER,
    server_id TEXT, -- ID en Firebase/MongoDB
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 3. TABLA DE TAREAS
-- ============================================
CREATE TABLE tasks (
    task_id TEXT PRIMARY KEY,
    subject_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    due_date INTEGER, -- timestamp
    priority TEXT DEFAULT 'medium' CHECK(priority IN ('low', 'medium', 'high', 'urgent')),
    status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'in_progress', 'completed', 'overdue')),
    grade REAL, -- Calificación obtenida
    max_grade REAL DEFAULT 10.0,
    weight REAL DEFAULT 1.0, -- Peso de la tarea para el promedio
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    completed_at INTEGER,
    -- Sincronización
    sync_status TEXT DEFAULT 'synced',
    last_sync INTEGER,
    server_id TEXT,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 4. TABLA DE ARCHIVOS ADJUNTOS
-- ============================================
CREATE TABLE attachments (
    attachment_id TEXT PRIMARY KEY,
    task_id TEXT,
    subject_id TEXT, -- Puede estar asociado directamente a materia
    user_id TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL CHECK(file_type IN ('pdf', 'image', 'document', 'other')),
    file_path TEXT NOT NULL, -- Ruta local
    file_size INTEGER, -- Tamaño en bytes
    cloud_url TEXT, -- URL en Firebase Storage
    mime_type TEXT,
    thumbnail_path TEXT, -- Para imágenes
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    -- Sincronización
    sync_status TEXT DEFAULT 'synced',
    last_sync INTEGER,
    upload_progress INTEGER DEFAULT 0, -- 0-100
    server_id TEXT,
    FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 5. TABLA DE NOTAS/CALIFICACIONES
-- ============================================
CREATE TABLE grades (
    grade_id TEXT PRIMARY KEY,
    subject_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    grade_type TEXT NOT NULL CHECK(grade_type IN ('exam', 'homework', 'project', 'participation', 'quiz', 'other')),
    grade_name TEXT NOT NULL,
    score REAL NOT NULL,
    max_score REAL NOT NULL,
    percentage REAL, -- Calculado: (score/max_score) * 100
    weight REAL DEFAULT 1.0,
    date INTEGER NOT NULL,
    notes TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    -- Sincronización
    sync_status TEXT DEFAULT 'synced',
    last_sync INTEGER,
    server_id TEXT,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 6. TABLA DE EVENTOS DEL CALENDARIO
-- ============================================
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
    recurrence_rule TEXT, -- JSON para eventos recurrentes
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    -- Sincronización
    sync_status TEXT DEFAULT 'synced',
    last_sync INTEGER,
    server_id TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE SET NULL,
    FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE
);

-- ============================================
-- 7. TABLA DE NOTIFICACIONES
-- ============================================
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
    action_type TEXT, -- Para acciones específicas
    action_data TEXT, -- JSON con datos adicionales
    created_at INTEGER NOT NULL,
    -- Sincronización
    sync_status TEXT DEFAULT 'synced',
    server_id TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES calendar_events(event_id) ON DELETE CASCADE
);

-- ============================================
-- 8. TABLA DE LECTURAS/RECURSOS
-- ============================================
CREATE TABLE readings (
    reading_id TEXT PRIMARY KEY,
    subject_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    file_path TEXT, -- PDF local
    cloud_url TEXT,
    file_size INTEGER,
    total_pages INTEGER,
    current_page INTEGER DEFAULT 0,
    reading_progress REAL DEFAULT 0.0, -- Porcentaje 0-100
    is_completed INTEGER DEFAULT 0,
    notes TEXT, -- Notas del usuario sobre la lectura
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    last_read INTEGER,
    -- Sincronización
    sync_status TEXT DEFAULT 'synced',
    last_sync INTEGER,
    server_id TEXT,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 9. TABLA DE ESTADÍSTICAS POR MATERIA
-- ============================================
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
    study_hours REAL DEFAULT 0.0, -- Tiempo total de estudio
    last_calculated INTEGER NOT NULL,
    -- Sincronización
    sync_status TEXT DEFAULT 'synced',
    last_sync INTEGER,
    server_id TEXT,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE(subject_id, user_id)
);

-- ============================================
-- 10. TABLA DE HISTORIAL DE SINCRONIZACIÓN
-- ============================================
CREATE TABLE sync_history (
    sync_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    sync_type TEXT NOT NULL CHECK(sync_type IN ('full', 'partial', 'upload', 'download')),
    entity_type TEXT, -- users, tasks, subjects, etc.
    entity_id TEXT,
    operation TEXT CHECK(operation IN ('create', 'update', 'delete')),
    status TEXT NOT NULL CHECK(status IN ('pending', 'in_progress', 'completed', 'failed', 'conflict')),
    started_at INTEGER NOT NULL,
    completed_at INTEGER,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    local_data TEXT, -- JSON del dato local
    server_data TEXT, -- JSON del dato del servidor
    conflict_resolution TEXT CHECK(conflict_resolution IN ('local_wins', 'server_wins', 'merged', 'manual')),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 11. TABLA DE CONFIGURACIÓN DE LA APP
-- ============================================
CREATE TABLE app_settings (
    setting_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    setting_key TEXT NOT NULL,
    setting_value TEXT NOT NULL,
    data_type TEXT DEFAULT 'string' CHECK(data_type IN ('string', 'boolean', 'integer', 'float', 'json')),
    updated_at INTEGER NOT NULL,
    -- Sincronización
    sync_status TEXT DEFAULT 'synced',
    last_sync INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE(user_id, setting_key)
);

-- ============================================
-- 12. TABLA DE CACHÉ DE IMÁGENES
-- ============================================
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

-- ============================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ============================================

-- Índices para usuarios
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_sync_status ON users(sync_status);

-- Índices para materias
CREATE INDEX idx_subjects_user ON subjects(user_id);
CREATE INDEX idx_subjects_sync ON subjects(sync_status);
CREATE INDEX idx_subjects_archived ON subjects(is_archived);

-- Índices para tareas
CREATE INDEX idx_tasks_subject ON tasks(subject_id);
CREATE INDEX idx_tasks_user ON tasks(user_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_sync ON tasks(sync_status);

-- Índices para archivos
CREATE INDEX idx_attachments_task ON attachments(task_id);
CREATE INDEX idx_attachments_subject ON attachments(subject_id);
CREATE INDEX idx_attachments_user ON attachments(user_id);
CREATE INDEX idx_attachments_sync ON attachments(sync_status);

-- Índices para calificaciones
CREATE INDEX idx_grades_subject ON grades(subject_id);
CREATE INDEX idx_grades_user ON grades(user_id);
CREATE INDEX idx_grades_date ON grades(date);
CREATE INDEX idx_grades_sync ON grades(sync_status);

-- Índices para calendario
CREATE INDEX idx_events_user ON calendar_events(user_id);
CREATE INDEX idx_events_subject ON calendar_events(subject_id);
CREATE INDEX idx_events_date ON calendar_events(start_date);
CREATE INDEX idx_events_type ON calendar_events(event_type);
CREATE INDEX idx_events_sync ON calendar_events(sync_status);

-- Índices para notificaciones
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_task ON notifications(task_id);
CREATE INDEX idx_notifications_scheduled ON notifications(scheduled_time);
CREATE INDEX idx_notifications_read ON notifications(is_read);

-- Índices para lecturas
CREATE INDEX idx_readings_subject ON readings(subject_id);
CREATE INDEX idx_readings_user ON readings(user_id);
CREATE INDEX idx_readings_sync ON readings(sync_status);

-- Índices para sincronización
CREATE INDEX idx_sync_history_user ON sync_history(user_id);
CREATE INDEX idx_sync_history_status ON sync_history(status);
CREATE INDEX idx_sync_history_entity ON sync_history(entity_type, entity_id);

-- ============================================
-- TRIGGERS PARA AUDITORÍA Y AUTOMATIZACIÓN
-- ============================================

-- Trigger para actualizar updated_at automáticamente en users
CREATE TRIGGER update_users_timestamp 
AFTER UPDATE ON users
BEGIN
    UPDATE users SET updated_at = strftime('%s', 'now') WHERE user_id = NEW.user_id;
END;

-- Trigger para actualizar updated_at en subjects
CREATE TRIGGER update_subjects_timestamp 
AFTER UPDATE ON subjects
BEGIN
    UPDATE subjects SET updated_at = strftime('%s', 'now') WHERE subject_id = NEW.subject_id;
END;

-- Trigger para actualizar updated_at en tasks
CREATE TRIGGER update_tasks_timestamp 
AFTER UPDATE ON tasks
BEGIN
    UPDATE tasks SET updated_at = strftime('%s', 'now') WHERE task_id = NEW.task_id;
END;

-- Trigger para marcar tareas como vencidas
CREATE TRIGGER check_task_overdue
AFTER UPDATE ON tasks
WHEN NEW.due_date < strftime('%s', 'now') AND NEW.status != 'completed'
BEGIN
    UPDATE tasks SET status = 'overdue' WHERE task_id = NEW.task_id;
END;

-- Trigger para actualizar estadísticas cuando se completa una tarea
CREATE TRIGGER update_stats_on_task_complete
AFTER UPDATE ON tasks
WHEN NEW.status = 'completed' AND OLD.status != 'completed'
BEGIN
    UPDATE subject_statistics 
    SET completed_tasks = completed_tasks + 1,
        pending_tasks = pending_tasks - 1,
        last_calculated = strftime('%s', 'now')
    WHERE subject_id = NEW.subject_id AND user_id = NEW.user_id;
END;

-- Trigger para crear entrada en historial de sincronización
CREATE TRIGGER log_sync_on_update
AFTER UPDATE ON tasks
WHEN NEW.sync_status = 'pending'
BEGIN
    INSERT INTO sync_history (
        sync_id, user_id, sync_type, entity_type, entity_id, 
        operation, status, started_at
    ) VALUES (
        hex(randomblob(16)), NEW.user_id, 'partial', 'tasks', 
        NEW.task_id, 'update', 'pending', strftime('%s', 'now')
    );
END;

-- ============================================
-- VISTAS ÚTILES
-- ============================================

-- Vista de tareas pendientes con información de materia
CREATE VIEW v_pending_tasks AS
SELECT 
    t.task_id,
    t.title,
    t.description,
    t.due_date,
    t.priority,
    t.status,
    s.subject_name,
    s.subject_code,
    s.color,
    t.user_id,
    (t.due_date - strftime('%s', 'now')) as time_remaining
FROM tasks t
INNER JOIN subjects s ON t.subject_id = s.subject_id
WHERE t.status IN ('pending', 'in_progress', 'overdue')
ORDER BY t.due_date ASC;

-- Vista de estadísticas generales del usuario
CREATE VIEW v_user_statistics AS
SELECT 
    u.user_id,
    u.display_name,
    COUNT(DISTINCT s.subject_id) as total_subjects,
    COUNT(DISTINCT t.task_id) as total_tasks,
    SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
    SUM(CASE WHEN t.status = 'pending' THEN 1 ELSE 0 END) as pending_tasks,
    SUM(CASE WHEN t.status = 'overdue' THEN 1 ELSE 0 END) as overdue_tasks,
    AVG(g.percentage) as overall_average
FROM users u
LEFT JOIN subjects s ON u.user_id = s.user_id
LEFT JOIN tasks t ON s.subject_id = t.subject_id
LEFT JOIN grades g ON s.subject_id = g.subject_id
GROUP BY u.user_id;

-- Vista de próximos eventos
CREATE VIEW v_upcoming_events AS
SELECT 
    e.event_id,
    e.title,
    e.description,
    e.start_date,
    e.end_date,
    e.event_type,
    s.subject_name,
    e.user_id
FROM calendar_events e
LEFT JOIN subjects s ON e.subject_id = s.subject_id
WHERE e.start_date >= strftime('%s', 'now')
ORDER BY e.start_date ASC;

-- Vista de tareas por sincronizar
CREATE VIEW v_pending_sync AS
SELECT 
    'tasks' as entity_type,
    task_id as entity_id,
    sync_status,
    last_sync,
    user_id
FROM tasks
WHERE sync_status = 'pending'
UNION ALL
SELECT 
    'subjects',
    subject_id,
    sync_status,
    last_sync,
    user_id
FROM subjects
WHERE sync_status = 'pending'
UNION ALL
SELECT 
    'grades',
    grade_id,
    sync_status,
    last_sync,
    user_id
FROM grades
WHERE sync_status = 'pending';
```