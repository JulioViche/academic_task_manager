# Manual de Programación - Academic Task Manager (Sprint 8)

## 1. Estructura de Directorios
```
lib/
├── core/               # Utilidades, constantes, temas, router
│   ├── router/         # Configuración de GoRouter (AppRouter)
│   ├── theme/          # Tema claro/oscuro (AppTheme)
│   └── utils/          # Helpers (DateUtils, Validators)
├── data/               # Capa de Datos (Clean Arch)
│   ├── datasources/    # Fuentes de datos
│   │   ├── local/      # SQLite (DatabaseHelper, DAOs)
│   │   └── remote/     # Firestore servicios
│   ├── models/         # DTOs (Data Transfer Objects) con fromJson/toJson
│   └── repositories/   # Implementación de repositorios (lógica de sync)
├── domain/             # Capa de Dominio (Clean Arch)
│   ├── entities/       # Objetos de negocio inmutables (Task, Subject)
│   └── repositories/   # Interfaces abstractas de repositorios
├── presentation/       # Capa de UI
│   ├── pages/          # Pantallas completas (HomeScreen, TasksScreen)
│   ├── providers/      # StateNotifiers de Riverpod
│   └── widgets/        # Componentes reutilizables (Cards, Inputs)
└── main.dart           # Punto de entrada
```

## 2. Clases Principales y Responsabilidades

### 2.1. Gestión de Estado (Providers)
*   **`AuthNotifier`**: Gestiona el estado de sesión del usuario (`User?`). Escucha cambios en Firebase Auth.
*   **`TaskNotifier`**: Mantiene la lista de tareas en memoria, filtra por estado y llama al repositorio.
*   **`SubjectNotifier`**: Gestiona la lista de materias.
*   **`AttachmentNotifier`**: Maneja la subida y descarga de adjuntos, actualizando el progreso en la UI.

### 2.2. Base de Datos Local (`DatabaseHelper`)
*   Singleton que gestiona la conexión a SQLite.
*   Método `_onCreate`: Define el esquema inicial.
*   Método `_onUpgrade`: Maneja las migraciones (ej. v3 añadió columnas para adjuntos).

### 2.3. Modelos de Datos (`*Model.dart`)
Extienden las Entidades de dominio.
*   `toJson()`: Convierte a Snake Case para BD/API (`taskId` -> `task_id`).
*   `fromJson()`: Parsea Snake Case a Camel Case para uso en Dart.
*   **Importante**: Mantener consistencia en nombres de campos para evitar errores de consulta en Firestore.

## 3. Flujo de Datos (Ejemplo: Crear Tarea)
1.  **UI**: Usuario llena formulario en `TaskDetailScreen`.
2.  **Notifier**: `TaskNotifier.addTask(Task)` es llamado.
3.  **Repository**: `TaskRepositoryImpl.addTask()` recibe la entidad.
    *   Convierte a `TaskModel`.
    *   Llama a `TaskLocalDataSource.insertTask()` (guarda en SQLite).
    *   Verifica conexión (`NetworkInfo`).
    *   Si hay red: Llama a `TaskRemoteDataSource.uploadTask()` (Firebase).
    *   Si no hay red: Marca `sync_status = 'pending'`.
4.  **UI**: Notifier actualiza el estado local y la lista se repinta instantáneamente.

## 4. Convenciones de Código
*   **Nombres de Archivos**: `snake_case` (ej. `task_repository.dart`).
*   **Clases**: `PascalCase` (ej. `TaskRepository`).
*   **Variables/Métodos**: `camelCase` (ej. `getTasks`).
*   **Imports**: Usar rutas relativas controladas o absolutas de paquete.
*   **Linter**: Seguir reglas estándar de Flutter (`flutter_lints`).

## 5. Dependencias Clave (`pubspec.yaml`)
*   `firebase_core`, `_auth`, `_cloud_firestore`, `_storage`: Suite de Firebase.
*   `flutter_riverpod`: Inyección de dependencias y estado.
*   `go_router`: Navegación 2.0.
*   `sqflite`: base de datos SQL local.
*   `intl`: Internacionalización y formateo.
*   `table_calendar`: Widget de calendario complejo.

## 6. Depuración Común
*   **Errores de Tipo (Subtype)**: Verificar siempre los `fromJson` y asegurarse que los tipos de datos de Firestore (Timestamp vs String) se están convirtiendo correctamente.
*   **Provider no actualizado**: Verificar si se está "observando" (`ref.watch`) o solo "leyendo" (`ref.read`) en el método `build`.
*   **Context Async Gap**: Usar `if (!mounted) return;` después de `await` antes de usar `context`.
