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

#### Día 2: Configuración Firebase
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

#### Día 3-4: Base de Datos SQLite
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
- [ ] Pruebas unitarias de base de datos

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

# SPRINT 4-8: [Resto del plan como se describió anteriormente]

**NOTA:** Los Sprints 4-8 siguen la estructura completa con:
- Sprint 4: Archivos y Calendario
- Sprint 5: Sincronización Offline-First
- Sprint 6: Notificaciones, Sensores y Calificaciones
- Sprint 7: Lecturas PDF y Pulido
- Sprint 8: Manuales y Publicación

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

