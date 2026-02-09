# PLAN DE IMPLEMENTACIÓN - SISTEMA ACADÉMICO FLUTTER
## Universidad de las Fuerzas Armadas - ESPE
**Proyecto:** Classroom Simplificado con Modo Offline  
**Tecnología:** Flutter + Firebase  
**Duración:** 8 semanas (2 meses)  
**Equipo:** Denise Rea y Julio Viche

---

## 📋 RESUMEN EJECUTIVO

### Estrategia de División del Trabajo
- **Denise:** Backend, Base de Datos SQLite, Sincronización Firebase y Autenticación
- **Julio:** Frontend UI/UX, Widgets, Navegación y Sensores

### Stack Tecnológico Flutter
```yaml
dependencies:
  # Estado
  flutter_riverpod: ^2.4.0  # o flutter_bloc: ^8.1.3
  
  # Base de datos local
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  firebase_messaging: ^14.7.0
  
  # Autenticación
  google_sign_in: ^6.1.5
  flutter_facebook_auth: ^6.0.3
  
  # Navegación
  go_router: ^12.1.3
  
  # UI/UX
  flutter_screenutil: ^5.9.0
  animate_do: ^3.1.2
  lottie: ^2.7.0
  cached_network_image: ^3.3.0
  
  # Notificaciones
  flutter_local_notifications: ^16.2.0
  
  # Archivos
  file_picker: ^6.1.1
  image_picker: ^1.0.4
  syncfusion_flutter_pdfviewer: ^23.2.4
  
  # Sensores
  light: ^3.0.0
  
  # Utilidades
  intl: ^0.18.1
  uuid: ^4.2.2
  connectivity_plus: ^5.0.2
```

### Metodología
- Sprints de 1 semana
- Reuniones diarias de sincronización (15 min)
- Integración continua cada 2-3 días
- Revisión de código cruzado
- Testing continuo

---

## 🗓️ CRONOGRAMA GENERAL

```
Semana 1: Configuración + Estructura Clean Architecture
Semana 2: Autenticación + BD SQLite
Semana 3: CRUD Materias y Tareas + UI Principal
Semana 4: Archivos (Fotos/PDFs) + Calendario
Semana 5: Sincronización Firebase + Offline First
Semana 6: Notificaciones + Sensores + Estadísticas
Semana 7: Pulido UI + Lecturas PDF + Testing
Semana 8: Manuales + Publicación Google Play
```

---

# SPRINT 1: CONFIGURACIÓN Y ESTRUCTURA (Semana 1)

## 🎯 Objetivos
- Configurar proyecto Flutter con Clean Architecture
- Establecer estructura de carpetas
- Configurar Firebase
- Crear base de navegación

## 👥 División de Tareas

### 📱 DENISE - Backend & Configuración (35 horas)

#### Día 1: Configuración Inicial del Proyecto
- [ ] Crear proyecto Flutter: `flutter create sistema_academico`
- [ ] Configurar Clean Architecture completa:
  ```
  lib/
  ├── core/
  │   ├── error/
  │   │   ├── exceptions.dart
  │   │   └── failures.dart
  │   ├── network/
  │   │   └── network_info.dart
  │   ├── usecases/
  │   │   └── usecase.dart
  │   └── utils/
  │       ├── constants.dart
  │       └── typedef.dart
  ├── data/
  │   ├── datasources/
  │   │   ├── local/
  │   │   └── remote/
  │   ├── models/
  │   └── repositories/
  ├── domain/
  │   ├── entities/
  │   ├── repositories/
  │   └── usecases/
  └── presentation/
      ├── providers/
      ├── widgets/
      │   ├── atoms/
      │   ├── molecules/
      │   └── organisms/
      └── pages/
  ```
- [ ] Configurar pubspec.yaml con todas las dependencias
- [ ] Configurar análisis estático (analysis_options.yaml)

#### Día 2-3: Base de Datos SQLite
- [ ] Crear database_helper.dart
- [ ] Implementar SQL Schema (12 tablas del modelo)
- [ ] Crear clase DatabaseService con singleton
- [ ] Implementar métodos de inicialización DB
- [ ] Crear entidades del dominio:
  ```dart
  // lib/domain/entities/
  - user_entity.dart
  - subject_entity.dart
  - task_entity.dart
  - attachment_entity.dart
  - grade_entity.dart
  - calendar_event_entity.dart
  - notification_entity.dart
  - reading_entity.dart
  ```
- [ ] Crear modelos de datos (Data layer):
  ```dart
  // lib/data/models/
  - user_model.dart (extends UserEntity)
  - subject_model.dart
  - task_model.dart
  // etc...
  ```
- [ ] Implementar mappers (toJson, fromJson, toEntity, fromEntity)
- [ ] Pruebas unitarias y de integración de base de datos (CRUD Tests)

#### Día 4: Configuración Firebase
- [ ] Crear proyecto en Firebase Console
- [ ] Configurar Firebase para Android:
  - Descargar google-services.json
  - Configurar build.gradle
  - Configurar AndroidManifest.xml
- [ ] Inicializar Firebase en main.dart
- [ ] Configurar Firebase Auth
- [ ] Configurar Cloud Firestore
- [ ] Configurar Firebase Storage
- [ ] Probar conexión Firebase

#### Día 5: Core Utilities
- [ ] Implementar NetworkInfo (verificar conectividad)
  ```dart
  abstract class NetworkInfo {
    Future<bool> get isConnected;
  }
  ```
- [ ] Crear sistema de manejo de errores
  ```dart
  // Exceptions
  class ServerException implements Exception {}
  class CacheException implements Exception {}
  class NetworkException implements Exception {}
  
  // Failures
  abstract class Failure {}
  class ServerFailure extends Failure {}
  class CacheFailure extends Failure {}
  class NetworkFailure extends Failure {}
  ```
- [ ] Crear constants.dart (API URLs, keys, etc.)
- [ ] Crear utils de fecha/hora
- [ ] Configurar dependency injection (Riverpod providers)

### 🎨 JULIO - Frontend Base & Navegación (35 horas)

#### Día 1-2: Sistema de Diseño y Temas
- [ ] Crear AppTheme con tema claro y oscuro
  ```dart
  // lib/core/theme/
  - app_theme.dart
  - app_colors.dart
  - app_text_styles.dart
  - app_dimensions.dart
  ```
- [ ] Definir paleta de colores:
  ```dart
  // Colores principales
  - Primary: #2196F3
  - Secondary: #FF9800
  - Success: #4CAF50
  - Error: #F44336
  - Warning: #FFC107
  // + versiones dark mode
  ```
- [ ] Crear estilos de texto consistentes
- [ ] Configurar ThemeProvider/Notifier
  ```dart
  final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>
  ```
- [ ] Implementar persistencia de preferencia de tema (SharedPreferences)

#### Día 2-3: Atomic Design - Widgets Base
- [ ] Crear Atoms:
  ```dart
  // lib/presentation/widgets/atoms/
  - custom_button.dart
  - custom_text_field.dart
  - custom_icon_button.dart
  - loading_indicator.dart
  - custom_chip.dart
  - priority_badge.dart
  - status_badge.dart
  ```
- [ ] Crear Molecules:
  ```dart
  // lib/presentation/widgets/molecules/
  - subject_card.dart
  - task_card.dart
  - empty_state.dart
  - error_state.dart
  - search_bar.dart
  - filter_chip_list.dart
  ```
- [ ] Crear organisms básicos:
  ```dart
  - custom_app_bar.dart
  - bottom_nav_bar.dart
  - custom_drawer.dart
  ```

#### Día 4: Sistema de Navegación
- [ ] Configurar GoRouter:
  ```dart
  // lib/core/router/
  - app_router.dart
  - route_names.dart
  ```
- [ ] Definir rutas principales:
  ```dart
  /splash
  /onboarding
  /login
  /home
  /subjects
  /tasks
  /calendar
  /grades
  /profile
  /settings
  ```
- [ ] Implementar navegación con tabs (BottomNavigationBar)
- [ ] Configurar Drawer lateral con menú
- [ ] Implementar animaciones de transición de página

#### Día 5: Pantallas Iniciales
- [ ] Crear SplashScreen
  - Animación de logo con Lottie
  - Verificar autenticación
  - Navegar a onboarding o home
- [ ] Crear OnboardingScreen (PageView con 3 slides)
  - Introducción a la app
  - Características principales
  - Botón "Comenzar"
- [ ] Crear estructura de HomeScreen (sin datos aún)
- [ ] Implementar NavigationShell para tabs
- [ ] Pruebas de navegación

---

# SPRINT 2: AUTENTICACIÓN COMPLETA (Semana 2)

## 🎯 Objetivos
- Implementar autenticación con Google, Facebook y Firebase
- Crear flujo completo de login/registro
- Persistir sesión localmente

## 👥 División de Tareas

### 📱 DENISE - Lógica de Autenticación (35 horas)

#### Día 1: Data Sources - Autenticación
- [ ] Crear AuthLocalDataSource:
  ```dart
  abstract class AuthLocalDataSource {
    Future<UserModel?> getCachedUser();
    Future<void> cacheUser(UserModel user);
    Future<void> clearCache();
  }
  ```
  - Usar SharedPreferences o Hive
  - Guardar token, userId, email
- [ ] Crear AuthRemoteDataSource:
  ```dart
  abstract class AuthRemoteDataSource {
    Future<UserModel> signInWithGoogle();
    Future<UserModel> signInWithFacebook();
    Future<UserModel> signInWithEmailPassword(String email, String password);
    Future<UserModel> signUpWithEmailPassword(String email, String password);
    Future<void> signOut();
    Future<UserModel?> getCurrentUser();
  }
  ```
  - Integrar Firebase Auth
  - Manejar errores de autenticación

#### Día 2: Repository Implementation
- [ ] Implementar AuthRepositoryImpl:
  ```dart
  class AuthRepositoryImpl implements AuthRepository {
    final AuthRemoteDataSource remoteDataSource;
    final AuthLocalDataSource localDataSource;
    final NetworkInfo networkInfo;
    
    // Implementar todos los métodos
  }
  ```
- [ ] Implementar lógica offline-first
- [ ] Manejar excepciones y convertir a Failures
- [ ] Pruebas unitarias del repository

#### Día 3: Domain Layer - Use Cases
- [ ] Crear casos de uso:
  ```dart
  // lib/domain/usecases/auth/
  - login_with_google.dart
  - login_with_facebook.dart
  - login_with_email.dart
  - register_with_email.dart
  - logout.dart
  - get_current_user.dart
  - check_auth_status.dart
  ```
- [ ] Implementar validaciones de email/password
- [ ] Crear value objects (Email, Password)
- [ ] Pruebas unitarias de use cases

#### Día 4: Guardar Usuario en SQLite
- [ ] Crear UserDao:
  ```dart
  abstract class UserDao {
    Future<void> insertUser(UserModel user);
    Future<UserModel?> getUser(String userId);
    Future<void> updateUser(UserModel user);
    Future<void> deleteUser(String userId);
  }
  ```
- [ ] Implementar queries SQL
- [ ] Sincronizar con Firestore
- [ ] Manejar actualización de perfil

#### Día 5: Providers y Estado
- [ ] Crear AuthNotifier (Riverpod) o AuthBloc:
  ```dart
  class AuthNotifier extends StateNotifier<AuthState> {
    final LoginWithGoogleUseCase loginWithGoogle;
    final LoginWithFacebookUseCase loginWithFacebook;
    // ...
  }
  
  enum AuthStatus { initial, authenticated, unauthenticated, loading }
  ```
- [ ] Implementar auto-login al abrir app
- [ ] Persistencia de sesión
- [ ] Pruebas de integración
### 🎨 JULIO - UI de Autenticación Funcional (35 horas)

#### Día 1-2: Pantallas de Autenticación
- [ ] Implementar LoginScreen completa:
  ```dart
  // lib/presentation/pages/auth/login_screen.dart
  - TextField para email
  - TextField para password
  - Botón "Iniciar Sesión"
  - GoogleSignInButton
  - FacebookSignInButton
  - Link a "Registrarse"
  - Link a "Olvidé mi contraseña"
  ```
- [ ] Implementar RegisterScreen:
  - Formulario de registro
  - Validaciones en tiempo real
  - Confirmación de contraseña
- [ ] Crear ForgotPasswordScreen
- [ ] Implementar validación de formularios

#### Día 3: Conectar UI con Providers
- [ ] Consumir AuthNotifier desde LoginScreen
- [ ] Mostrar estados de carga
- [ ] Mostrar errores con SnackBar/Dialog
- [ ] Navegación después de login exitoso
- [ ] Animaciones de botones y campos

#### Día 4: Widgets de Autenticación Reutilizables
- [ ] Crear GoogleSignInButton widget:
  ```dart
  - Logo de Google
  - Animación al presionar
  - Loading state
  ```
- [ ] Crear FacebookSignInButton widget
- [ ] Crear AuthTextField con validación
- [ ] Crear PasswordField con show/hide
- [ ] Logo animado de la aplicación

#### Día 5: Pantalla de Perfil Base
- [ ] Crear ProfileScreen estructura:
  - Avatar del usuario
  - Nombre y email
  - Botón editar perfil
  - Configuraciones
  - Botón cerrar sesión
- [ ] Implementar funcionalidad de logout
- [ ] Navegación fluida

---

# SPRINT 3: CRUD MATERIAS Y TAREAS (Semana 3)

## 🎯 Objetivos
- Implementar CRUD completo de Materias
- Implementar CRUD completo de Tareas
- Crear UI principal de la app

## 👥 División de Tareas

### 📱 DENISE - Backend Materias y Tareas (35 horas)

#### Día 1: Data Layer - Subjects
- [ ] Crear SubjectLocalDataSource:
  ```dart
  abstract class SubjectLocalDataSource {
    Future<List<SubjectModel>> getAllSubjects(String userId);
    Future<SubjectModel> getSubject(String subjectId);
    Future<void> insertSubject(SubjectModel subject);
    Future<void> updateSubject(SubjectModel subject);
    Future<void> deleteSubject(String subjectId);
    Future<void> archiveSubject(String subjectId);
  }
  ```
- [ ] Implementar queries SQL para materias
- [ ] Crear SubjectRemoteDataSource (Firestore)
- [ ] Implementar SubjectRepositoryImpl

#### Día 2: Domain Layer - Subjects
- [ ] Crear casos de uso:
  ```dart
  - GetAllSubjectsUseCase
  - GetSubjectByIdUseCase
  - CreateSubjectUseCase
  - UpdateSubjectUseCase
  - DeleteSubjectUseCase
  - ArchiveSubjectUseCase
  ```
- [ ] Implementar validaciones de negocio
- [ ] Pruebas unitarias

#### Día 3: Data Layer - Tasks
- [ ] Crear TaskLocalDataSource:
  ```dart
  abstract class TaskLocalDataSource {
    Future<List<TaskModel>> getAllTasks(String userId);
    Future<List<TaskModel>> getTasksBySubject(String subjectId);
    Future<List<TaskModel>> getPendingTasks(String userId);
    Future<TaskModel> getTask(String taskId);
    Future<void> insertTask(TaskModel task);
    Future<void> updateTask(TaskModel task);
    Future<void> deleteTask(String taskId);
    Future<void> markTaskAsCompleted(String taskId);
  }
  ```
- [ ] Implementar queries complejas (filtros, ordenamiento)
- [ ] Crear TaskRemoteDataSource (Firestore)
- [ ] Implementar TaskRepositoryImpl

#### Día 4: Domain Layer - Tasks
- [ ] Crear casos de uso:
  ```dart
  - GetAllTasksUseCase
  - GetTasksBySubjectUseCase
  - GetPendingTasksUseCase
  - GetOverdueTasksUseCase
  - CreateTaskUseCase
  - UpdateTaskUseCase
  - DeleteTaskUseCase
  - CompleteTaskUseCase
  - SetTaskPriorityUseCase
  ```
- [ ] Lógica para detectar tareas vencidas
- [ ] Pruebas unitarias

#### Día 5: Providers y Estado
- [ ] Crear SubjectNotifier/SubjectBloc
- [ ] Crear TaskNotifier/TaskBloc
- [ ] Implementar filtros y búsqueda
- [ ] Estado de loading/error

### 🎨 JULIO - UI Materias y Tareas (35 horas)

#### Día 1-2: HomeScreen Principal
- [ ] Crear DashboardScreen con resumen
- [ ] Implementar BottomNavigationBar funcional
- [ ] Drawer lateral con opciones
- [ ] Quick actions

#### Día 2-3: Pantallas de Materias
- [ ] Crear SubjectsScreen (lista)
- [ ] Crear SubjectDetailScreen
- [ ] Crear AddEditSubjectScreen
- [ ] Color picker para materias

#### Día 3-4: Pantallas de Tareas
- [ ] Crear TasksScreen con tabs
- [ ] Crear TaskDetailScreen
- [ ] Crear AddEditTaskScreen
- [ ] Filtros y búsqueda

#### Día 4-5: Widgets Reutilizables
- [ ] SubjectCard
- [ ] TaskCard
- [ ] Animaciones hero
- [ ] Pull to refresh

---

# SPRINT 4: ARCHIVOS Y CALENDARIO (Semana 4)

## 🎯 Objetivos
- Integrar cámara para adjuntar fotos a tareas
- Permitir adjuntar archivos PDF
- Almacenar adjuntos en Firebase Storage y localmente
- Implementar UI de gestión de archivos adjuntos

## 👥 División de Tareas

### 📱 DENISE - Backend Archivos (35 horas)

#### Día 1: AttachmentLocalDataSource
- [ ] Crear AttachmentLocalDataSource:
  ```dart
  abstract class AttachmentLocalDataSource {
    Future<void> insertAttachment(AttachmentModel attachment);
    Future<List<AttachmentModel>> getAttachmentsByTask(String taskId);
    Future<List<AttachmentModel>> getAttachmentsBySubject(String subjectId);
    Future<void> deleteAttachment(String attachmentId);
    Future<List<AttachmentModel>> getPendingSyncAttachments();
  }
  ```
- [ ] Implementar queries SQL para tabla Attachments
- [ ] Manejo de rutas locales de archivos con `path_provider`

#### Día 2: Completar AttachmentRepositoryImpl
- [ ] Integrar AttachmentLocalDataSource al repositorio existente
- [ ] Implementar lógica offline-first para archivos:
  - Guardar archivo localmente primero
  - Subir a Firebase Storage si hay red
  - Marcar como `pending_sync` si no hay red
- [ ] Completar lógica de `deleteAttachment` (eliminar de Storage + Firestore + local)

#### Día 3: Servicio de Cámara y File Picker
- [ ] Crear FileService:
  ```dart
  class FileService {
    Future<File?> pickImage({required ImageSource source});
    Future<File?> pickPDF();
    Future<File> saveFileLocally(File file, String directory);
    Future<void> deleteLocalFile(String path);
    String getFileExtension(String path);
    String getMimeType(String path);
  }
  ```
- [ ] Integrar `image_picker` para cámara y galería
- [ ] Integrar `file_picker` para selección de PDFs
- [ ] Crear provider de FileService en Riverpod

#### Día 4: Evento Calendario - Backend
- [ ] Crear CalendarEventLocalDataSource:
  ```dart
  abstract class CalendarEventLocalDataSource {
    Future<List<CalendarEventModel>> getEventsByMonth(int year, int month);
    Future<void> insertEvent(CalendarEventModel event);
    Future<void> updateEvent(CalendarEventModel event);
    Future<void> deleteEvent(String eventId);
  }
  ```
- [ ] Implementar CalendarEventRepository
- [ ] Crear use cases: GetEvents, CreateEvent, UpdateEvent, DeleteEvent

#### Día 5: Integración y Pruebas
- [ ] Conectar calendario con eventos de tareas (fechas de entrega)
- [ ] Pruebas de subida/descarga de archivos
- [ ] Verificar persistencia local de adjuntos

### 🎨 JULIO - UI Archivos y Calendario (35 horas)

#### Día 1-2: UI de Adjuntos en Tareas
- [ ] Crear AttachmentListWidget:
  - Lista de archivos adjuntos con icono según tipo (📷 foto, 📄 PDF)
  - Botón para eliminar adjunto
  - Indicador de estado de sync (sincronizado/pendiente)
- [ ] Crear AttachmentPickerBottomSheet:
  ```dart
  // Opciones: Tomar foto, Elegir de galería, Seleccionar PDF
  ```
- [ ] Integrar picker en TaskDetailScreen y AddEditTaskScreen
- [ ] Previsualización de imagen adjunta (thumbnail)

#### Día 3: Visor de Imágenes
- [ ] Crear ImageViewerScreen:
  - Imagen a pantalla completa
  - Zoom con pinch
  - Botón compartir/eliminar
- [ ] Integrar navegación desde AttachmentListWidget

#### Día 4: Mejoras al Calendario
- [ ] Agregar FAB para crear evento rápido desde CalendarScreen
- [ ] Crear formulario de evento:
  - Título, descripción, fecha/hora, color
  - Asociar a materia (opcional)
- [ ] Indicador visual de cantidad de tareas por día (dots de colores)

#### Día 5: Pulido UI de archivos
- [ ] Animaciones al agregar/eliminar adjuntos
- [ ] Estados de carga durante upload
- [ ] Barra de progreso de subida
- [ ] Confirmar eliminación con dialog

---

# SPRINT 5: SINCRONIZACIÓN OFFLINE-FIRST (Semana 5)

## 🎯 Objetivos
- Implementar cola de sincronización para operaciones pendientes
- Sincronización bidireccional con Firestore
- Listener de conectividad que dispare sync automática
- Resolución de conflictos (último guardado prevalece)

## 👥 División de Tareas

### 📱 DENISE - Backend Sincronización (35 horas)

#### Día 1: Cola de Sincronización
- [ ] Crear SyncQueueLocalDataSource:
  ```dart
  abstract class SyncQueueLocalDataSource {
    Future<void> addToQueue(SyncOperation operation);
    Future<List<SyncOperation>> getPendingOperations();
    Future<void> markAsCompleted(String operationId);
    Future<void> markAsFailed(String operationId, String error);
    Future<void> clearCompleted();
  }

  class SyncOperation {
    final String id;
    final String tableName;    // 'subjects', 'tasks', 'attachments'
    final String recordId;
    final String operationType; // 'create', 'update', 'delete'
    final String jsonData;
    final DateTime createdAt;
    final String status;       // 'pending', 'in_progress', 'completed', 'failed'
    final int retryCount;
  }
  ```
- [ ] Implementar tabla `sync_queue` en SQLite
- [ ] Guardar operaciones fallidas automáticamente

#### Día 2: SyncService
- [ ] Crear SyncService:
  ```dart
  class SyncService {
    Future<void> syncAll();
    Future<void> syncSubjects();
    Future<void> syncTasks();
    Future<void> syncAttachments();
    Future<void> processQueue();
    Stream<SyncStatus> get syncStatusStream;
  }
  ```
- [ ] Implementar procesamiento de cola (FIFO)
- [ ] Manejo de reintentos (máximo 3 intentos)
- [ ] Logging de historial de sincronización en tabla `sync_history`

#### Día 3: Sincronización Bidireccional
- [ ] Implementar pull desde Firestore:
  ```dart
  // Comparar timestamps locales vs remotos
  // Si remoto es más reciente → actualizar local
  // Si local es más reciente → push a remoto
  ```
- [ ] Resolución de conflictos: `last_write_wins`
  - Comparar `updated_at` de registro local vs remoto
  - El más reciente prevalece
- [ ] Merge de datos sin pérdida

#### Día 4: Listener de Conectividad
- [ ] Crear ConnectivityListener:
  ```dart
  class ConnectivityListener {
    void startListening();
    void stopListening();
    // Cuando la red vuelve → disparar syncService.processQueue()
  }
  ```
- [ ] Integrar con `connectivity_plus` usando `onConnectivityChanged` stream
- [ ] Inicializar en main.dart al arrancar la app
- [ ] Actualizar `sync_status` en cada registro

#### Día 5: Actualizar Repositorios
- [ ] Modificar SubjectRepositoryImpl:
  - Si falla el remoto → agregar a SyncQueue
- [ ] Modificar TaskRepositoryImpl:
  - Si falla el remoto → agregar a SyncQueue
- [ ] Modificar AttachmentRepositoryImpl:
  - Si falla el upload → guardar localmente con status `pending_sync`
  - Agregar a SyncQueue
- [ ] Pruebas: desconectar red, crear datos, reconectar, verificar sync

### 🎨 JULIO - UI de Sincronización (35 horas)

#### Día 1-2: Indicadores de Estado de Sync
- [ ] Crear SyncStatusBadge widget:
  ```dart
  // Ícono según estado: ✅ synced, 🔄 syncing, ⏳ pending, ❌ failed
  ```
- [ ] Mostrar en SubjectCard y TaskCard
- [ ] Banner de "Sin conexión" en la parte superior de la app
- [ ] Animación de sincronización en progreso

#### Día 3: Pantalla de Historial de Sync
- [ ] Crear SyncHistoryScreen:
  - Lista de operaciones de sync con timestamp
  - Estado de cada operación
  - Botón "Sincronizar ahora"
- [ ] Agregar acceso desde Settings o Drawer

#### Día 4-5: Pull-to-Refresh y Mejoras
- [ ] Implementar pull-to-refresh en:
  - SubjectsScreen
  - TasksScreen
  - HomeScreen
- [ ] Mostrar último timestamp de sincronización
- [ ] Snackbar cuando sync se completa exitosamente
- [ ] Dialog de confirmación para sync manual

---

# SPRINT 6: NOTIFICACIONES, SENSORES Y CALIFICACIONES (Semana 6)

## 🎯 Objetivos
- Implementar notificaciones locales para recordatorios
- Implementar push notifications con Firebase Cloud Messaging
- Integrar sensor de luz para cambio automático de tema
- Implementar CRUD de calificaciones y estadísticas

## 👥 División de Tareas

### 📱 DENISE - Backend Notificaciones y Calificaciones (35 horas)

#### Día 1: Notificaciones Locales
- [ ] Descomentar `flutter_local_notifications` en pubspec.yaml
- [ ] Crear NotificationService:
  ```dart
  class NotificationService {
    Future<void> initialize();
    Future<void> showNotification({
      required String title,
      required String body,
      String? payload,
    });
    Future<void> scheduleNotification({
      required String title,
      required String body,
      required DateTime scheduledDate,
      String? payload,
    });
    Future<void> cancelNotification(int id);
    Future<void> cancelAllNotifications();
  }
  ```
- [ ] Configurar canales de notificación para Android
- [ ] Programar recordatorios automáticos:
  - 24 horas antes de la entrega
  - 1 hora antes de la entrega
  - Al momento de vencimiento

#### Día 2: Push Notifications (FCM)
- [ ] Configurar Firebase Cloud Messaging:
  ```dart
  class FCMService {
    Future<void> initialize();
    Future<String?> getToken();
    void onMessage(RemoteMessage message);
    void onMessageOpenedApp(RemoteMessage message);
    Future<void> subscribeToTopic(String topic);
  }
  ```
- [ ] Guardar FCM token en Firestore (colección `user_tokens`)
- [ ] Manejo de notificaciones en foreground y background
- [ ] Navegación a pantalla específica al tocar notificación

#### Día 3: Calificaciones - Data Layer
- [ ] Crear GradeLocalDataSource:
  ```dart
  abstract class GradeLocalDataSource {
    Future<List<GradeModel>> getGradesBySubject(String subjectId);
    Future<void> insertGrade(GradeModel grade);
    Future<void> updateGrade(GradeModel grade);
    Future<void> deleteGrade(String gradeId);
    Future<double> getAverageBySubject(String subjectId);
  }
  ```
- [ ] Implementar GradeRepositoryImpl
- [ ] Crear use cases: GetGrades, AddGrade, UpdateGrade, DeleteGrade, GetAverage

#### Día 4: Estadísticas
- [ ] Crear StatisticsService:
  ```dart
  class StatisticsService {
    Future<Map<String, double>> getAveragesBySubject(String userId);
    Future<int> getCompletedTasksCount(String userId);
    Future<int> getPendingTasksCount(String userId);
    Future<int> getOverdueTasksCount(String userId);
    Future<double> getCompletionRate(String userId);
    Future<Map<String, int>> getTasksPerSubject(String userId);
  }
  ```
- [ ] Implementar queries SQL con agregaciones
- [ ] Crear providers de Riverpod para estadísticas

#### Día 5: Notificaciones - Data Layer
- [ ] Crear NotificationLocalDataSource:
  ```dart
  abstract class NotificationLocalDataSource {
    Future<List<NotificationModel>> getAllNotifications(String userId);
    Future<void> insertNotification(NotificationModel notification);
    Future<void> markAsRead(String notificationId);
    Future<void> deleteNotification(String notificationId);
    Future<int> getUnreadCount(String userId);
  }
  ```
- [ ] Almacenar historial de notificaciones en SQLite
- [ ] Provider para badge de notificaciones no leídas

### 🎨 JULIO - UI Notificaciones, Sensor y Calificaciones (35 horas)

#### Día 1: Sensor de Luz
- [ ] Agregar dependencia `light` o `environment_sensors` en pubspec.yaml
- [ ] Crear LightSensorService:
  ```dart
  class LightSensorService {
    Stream<double> get luxStream;
    void startListening();
    void stopListening();
    // Si lux < 50 → tema oscuro
    // Si lux > 200 → tema claro
  }
  ```
- [ ] Crear LightSensorNotifier con Riverpod
- [ ] Integrar con ThemeMode en MyApp:
  ```dart
  // themeMode cambia automáticamente según lectura del sensor
  ```
- [ ] Opción en Settings para activar/desactivar cambio automático

#### Día 2: Pantalla de Calificaciones
- [ ] Implementar GradesScreen funcional:
  - Lista de materias con promedio
  - Expandir para ver notas individuales
  - Color según rendimiento (verde > 7, amarillo 5-7, rojo < 5)
- [ ] Crear AddGradeDialog:
  - Nombre de la evaluación
  - Nota obtenida / nota máxima
  - Peso/porcentaje (opcional)
  - Fecha de la evaluación

#### Día 3: Pantalla de Estadísticas
- [ ] Crear StatisticsScreen/Widget para HomeScreen:
  - Gráfico circular: tareas completadas vs pendientes
  - Barras de progreso por materia
  - Promedio general
  - Tareas vencidas
- [ ] Usar widgets nativos (Container + CustomPaint) o package de charts

#### Día 4: NotificationsScreen Funcional
- [ ] Implementar NotificationsScreen con lista real:
  - Agrupar por fecha (Hoy, Ayer, Esta semana)
  - Icono según tipo (tarea, recordatorio, sync)
  - Marcar como leída al tocar
  - Swipe para eliminar
- [ ] Badge de notificaciones en AppBar de HomeScreen

#### Día 5: HomeScreen con datos reales
- [ ] Conectar HomeScreen con providers reales:
  - Tareas pendientes del provider de tareas
  - Materias activas del provider de materias
  - Estadísticas del StatisticsService
- [ ] Resumen dinámico: "Hoy tienes X tareas pendientes"
- [ ] Widget de próximas entregas (próximos 7 días)

---

# SPRINT 7: LECTURAS PDF, BÚSQUEDA Y PULIDO (Semana 7)

## 🎯 Objetivos
- Implementar lector PDF integrado
- Búsqueda avanzada transversal
- Pantalla de Settings funcional
- Pulido general de UI/UX
- Testing

## 👥 División de Tareas

### 📱 DENISE - Backend Lecturas y Búsqueda (35 horas)

#### Día 1: Lecturas PDF - Data Layer
- [ ] Crear ReadingLocalDataSource:
  ```dart
  abstract class ReadingLocalDataSource {
    Future<List<ReadingModel>> getReadingsBySubject(String subjectId);
    Future<void> insertReading(ReadingModel reading);
    Future<void> updateReading(ReadingModel reading);
    Future<void> deleteReading(String readingId);
    Future<void> updateProgress(String readingId, int currentPage);
  }
  ```
- [ ] Implementar ReadingRepositoryImpl
- [ ] Crear use cases: GetReadings, AddReading, UpdateProgress

#### Día 2: Búsqueda Global
- [ ] Crear SearchService:
  ```dart
  class SearchService {
    Future<SearchResults> search(String query, {
      bool searchSubjects = true,
      bool searchTasks = true,
      bool searchReadings = true,
    });
  }

  class SearchResults {
    final List<Subject> subjects;
    final List<Task> tasks;
    final List<Reading> readings;
  }
  ```
- [ ] Implementar queries SQL con LIKE y FTS (Full Text Search)
- [ ] Crear provider de búsqueda con debounce

#### Día 3: Settings - Persistencia
- [ ] Crear SettingsService:
  ```dart
  class SettingsService {
    Future<void> setThemeMode(String mode); // 'system', 'light', 'dark'
    Future<String> getThemeMode();
    Future<void> setAutoThemeBySensor(bool enabled);
    Future<bool> getAutoThemeBySensor();
    Future<void> setNotificationsEnabled(bool enabled);
    Future<bool> getNotificationsEnabled();
    Future<void> setReminderHoursBefore(int hours);
    Future<int> getReminderHoursBefore();
    Future<void> setLanguage(String locale);
    Future<String> getLanguage();
  }
  ```
- [ ] Usar SharedPreferences y tabla `app_settings` en SQLite
- [ ] Crear SettingsNotifier con Riverpod

#### Día 4-5: Testing
- [ ] Tests unitarios de repositories:
  - SubjectRepositoryImpl
  - TaskRepositoryImpl
  - AuthRepositoryImpl
- [ ] Tests unitarios de use cases
- [ ] Tests de integración de DatabaseHelper
- [ ] Tests de modelos (toJson, fromJson, fromEntity)
- [ ] Al menos 20 tests en total

### 🎨 JULIO - UI Lecturas, Búsqueda y Pulido (35 horas)

#### Día 1: Lector PDF
- [ ] Crear PDFReaderScreen usando `syncfusion_flutter_pdfviewer`:
  ```dart
  // lib/presentation/pages/pdf/pdf_reader_screen.dart
  - Abrir PDF desde archivo local o URL
  - Navegación por páginas
  - Zoom
  - Guardar progreso de lectura
  ```
- [ ] Crear ReadingsScreen:
  - Lista de lecturas agrupadas por materia
  - Barra de progreso por lectura
  - Botón para agregar nueva lectura (file_picker)

#### Día 2: Búsqueda Avanzada
- [ ] Crear SearchScreen:
  - Barra de búsqueda con debounce (300ms)
  - Resultados agrupados por categoría (Materias, Tareas, Lecturas)
  - Filtros rápidos (chips)
  - Navegación a detalle al tocar resultado
- [ ] Integrar búsqueda en AppBar global (ícono de lupa)

#### Día 3: Settings Funcional
- [ ] Implementar SettingsScreen completo:
  - Toggle tema: Sistema / Claro / Oscuro
  - Toggle sensor de luz automático
  - Toggle notificaciones
  - Horas de anticipación para recordatorios
  - Información de la cuenta
  - "Acerca de" con versión de la app
  - Botón "Cerrar sesión"
  - Botón "Sincronizar ahora"
  - Almacenamiento usado (local)

#### Día 4-5: Pulido General
- [ ] Revisar y mejorar animaciones en:
  - Transiciones entre pantallas (Hero animations)
  - Aparición de cards (FadeIn, SlideIn con animate_do)
  - Loading states con shimmer/skeleton
- [ ] Lottie animations en SplashScreen
- [ ] Responsive: verificar en distintos tamaños de pantalla
- [ ] Accesibilidad: labels, contraste, tamaños mínimos de tap
- [ ] Manejo de errores visuales (SnackBars, dialogs)
- [ ] Empty states consistentes en todas las pantallas

---

# SPRINT 8: MANUALES Y PUBLICACIÓN (Semana 8)

## 🎯 Objetivos
- Crear manuales requeridos (usuario, desarrollo, programación)
- Implementar manual in-app (HelpScreen)
- Preparar assets y publicar en Google Play
- Presentación final

## 👥 División de Tareas

### 📱 DENISE - Manuales Técnicos y Publicación (35 horas)

#### Día 1: Manual de Desarrollo
- [ ] Crear documento con:
  - Arquitectura del sistema (Clean Architecture)
  - Diagrama de capas (data → domain → presentation)
  - Diagrama entidad-relación de la BD
  - Stack tecnológico utilizado
  - Decisiones técnicas y justificación
  - Estructura de paquetes/carpetas
  - Flujo de autenticación
  - Estrategia de sincronización

#### Día 2: Manual de Programación
- [ ] Crear documento con:
  - Explicación del código por módulos
  - Diagramas de clases principales
  - Diagramas de casos de uso
  - Patrones de diseño utilizados (Repository, UseCase, Observer)
  - Guía para agregar nuevas funcionalidades
  - Convenciones de código

#### Día 3: Política de Privacidad y Legal
- [ ] Redactar política de privacidad:
  - Datos recolectados (email, nombre, datos académicos)
  - Uso de Firebase y Google/Facebook Auth
  - Almacenamiento de datos
  - Derechos del usuario
- [ ] Hospedar en una URL pública (Firebase Hosting o GitHub Pages)
- [ ] Configurar enlace en Google Play Console

#### Día 4: Preparar Build de Producción
- [ ] Generar keystore para firma de la app:
  ```bash
  keytool -genkey -v -keystore academic-task-manager.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias academic_task_manager
  ```
- [ ] Configurar `key.properties` y `build.gradle` para release
- [ ] Generar APK/AAB de release:
  ```bash
  flutter build appbundle --release
  ```
- [ ] Probar app en modo release en dispositivo real

#### Día 5: Publicación Google Play
- [ ] Crear ficha en Google Play Console:
  - Título, descripción corta y larga
  - Categoría: Educación
  - Clasificación de contenido
- [ ] Subir capturas de pantalla (al menos 4)
- [ ] Subir APK/AAB
- [ ] Enviar a revisión (Producción o Beta cerrada)

### 🎨 JULIO - Manual de Usuario e In-App (35 horas)

#### Día 1-2: Manual de Usuario (PDF)
- [ ] Crear documento con:
  - Instalación y primer inicio
  - Registro e inicio de sesión
  - Gestión de materias (crear, editar, archivar, eliminar)
  - Gestión de tareas (crear, editar, completar, eliminar)
  - Adjuntar archivos y fotos
  - Calendario académico
  - Calificaciones y estadísticas
  - Lecturas PDF
  - Notificaciones y recordatorios
  - Configuración de la app
  - Sincronización y uso offline
  - Capturas de pantalla de cada funcionalidad

#### Día 3: Manual In-App (HelpScreen)
- [ ] Implementar HelpScreen completo:
  - Secciones expandibles (ExpansionTile)
  - Tutorial paso a paso con capturas
  - FAQ (Preguntas frecuentes)
  - Enlace a soporte / contacto
  - Primera vez: mostrar tutorial guiado (tooltips o overlay)
- [ ] Crear OnboardingTutorial para nuevos usuarios:
  ```dart
  // ShowcaseWidget o Tooltip personalizado
  // Paso 1: "Aquí puedes ver tus materias"
  // Paso 2: "Toca + para crear una tarea"
  // Paso 3: "Desliza para ver el calendario"
  ```

#### Día 4: Assets de Google Play
- [ ] Crear ícono de la app (512x512):
  - Versión adaptativa para Android
- [ ] Crear Feature Graphic (1024x500)
- [ ] Tomar capturas de pantalla en diferentes pantallas:
  - HomeScreen
  - Materias
  - Tareas
  - Calendario
  - Calificaciones
  - Modo oscuro
- [ ] Redactar descripción atractiva para la tienda

#### Día 5: Presentación Final
- [ ] Preparar presentación con:
  - Demo en vivo de la app
  - Arquitectura y decisiones técnicas
  - Funcionalidades principales
  - Modo offline y sincronización
  - Sensor de luz
  - Estadísticas
  - Lecciones aprendidas
- [ ] Ensayo de presentación

---

# 📊 CHECKLIST GENERAL DE PROGRESO

## Semana 1: Configuración ✓
- [ ] Proyecto Flutter creado
- [ ] Firebase configurado
- [ ] Base de datos SQLite
- [ ] Navegación básica
- [ ] Temas claro/oscuro

## Semana 2: Autenticación ✓
- [ ] Login con Google
- [ ] Login con Facebook
- [ ] Login con Email/Password
- [ ] Persistencia de sesión
- [ ] UI de autenticación completa

## Semana 3: CRUD Principal ✓
- [ ] Materias (CRUD completo)
- [ ] Tareas (CRUD completo)
- [ ] UI principal funcional
- [ ] Navegación entre pantallas

## Semana 4: Archivos y Calendario ✓
- [ ] Integración de cámara
- [ ] Adjuntar PDFs
- [ ] Calendario académico
- [ ] Firebase Storage

## Semana 5: Sincronización ✓
- [ ] Funcionamiento offline
- [ ] Sincronización bidireccional
- [ ] Resolución de conflictos
- [ ] Queue de sincronización

## Semana 6: Notificaciones y Extras ✓
- [ ] Notificaciones locales
- [ ] Push notifications (FCM)
- [ ] Sensor de luz
- [ ] Calificaciones
- [ ] Estadísticas

## Semana 7: Pulido ✓
- [ ] Lecturas PDF
- [ ] Búsqueda avanzada
- [ ] Filtros
- [ ] Optimizaciones
- [ ] Testing integral

## Semana 8: Publicación ✓
- [ ] Manuales completos
- [ ] Assets de Google Play
- [ ] Política de privacidad
- [ ] App publicada
- [ ] Presentación final

---

# 🎯 TIPS FINALES

## Para Denise (Backend)
- Documenta tus funciones con comentarios
- Crea pruebas unitarias desde el inicio
- Mantén los nombres de variables descriptivos
- Maneja todos los casos de error
- Usa try-catch en todas las operaciones asíncronas

## Para Julio (Frontend)
- Mantén los widgets pequeños y reutilizables
- Usa const constructors cuando sea posible
- Implementa loading states en todas las operaciones
- Prueba en diferentes tamaños de pantalla
- Sigue las guías de Material Design

## Para Ambos
- Commitea código funcional frecuentemente
- Comunica cambios que afecten al otro
- Prueba en dispositivos reales
- Mantén el código limpio y organizado
- ¡Pide ayuda cuando la necesites!

---

**¡ÉXITO EN SU PROYECTO! 🚀📱**

