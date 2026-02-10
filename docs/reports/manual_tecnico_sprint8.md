# Manual Técnico - Academic Task Manager (Sprint 8)

## 1. Visión General del Sistema
Academic Task Manager es una aplicación móvil desarrollada en **Flutter** que implementa una arquitectura limpia (Clean Architecture) con un enfoque **Offline-First**. Utiliza **Firebase** como backend para autenticación y almacenamiento remoto, y **SQLite** para persistencia local.

## 2. Arquitectura del Proyecto
El proyecto sigue el patrón **Clean Architecture** dividido en capas:

### 2.1. Capa de Presentación (`lib/presentation`)
*   **Patrón de Estado**: Riverpod (StateNotifier).
*   **Widgets**: UI construida con Material Design 3.
*   **Navegación**: GoRouter para gestión de rutas declarativas y Deep Linking.

### 2.2. Capa de Dominio (`lib/domain`)
*   **Entidades**: Modelos de negocio puros (`Task`, `Subject`, `User`, `Attachment`).
*   **Repositorios (Interfaces)**: Definición de contratos para acceso a datos.
*   **Casos de Uso**: Lógica de negocio (opcional en este sprint, accediendo a repositorios desde Notifiers).

### 2.3. Capa de Datos (`lib/data`)
*   **Modelos**: DTOs que extienden entidades con métodos `toJson`/`fromJson`.
*   **Fuentes de Datos (Data Sources)**:
    *   *Local*: SQLite (`sqflite`) para almacenamiento offline.
    *   *Remota*: Firebase Firestore y Storage.
*   **Repositorios (Implementaciones)**: Orquestan la sincronización entre local y remoto.
    *   *Lógica Offline-First*: Leer siempre de local. Al escribir, guardar en local -> intentar subir a remoto -> marcar para sync pendiente si falla.

## 3. Tecnologías y Librerías Clave
*   **Framework**: Flutter 3.x (Dart 3.x).
*   **Gestión de Estado**: `flutter_riverpod`.
*   **Base de Datos Local**: `sqflite`.
*   **Backend**: Firebase (Auth, Firestore, Storage).
*   **Navegación**: `go_router`.
*   **Utilidades**: `uuid` (IDs únicos), `intl` (formateo fechas), `connectivity_plus` (estado red).
*   **Archivos**: `file_picker`, `open_file`, `syncfusion_flutter_pdfviewer`.

## 4. Configuración del Entorno de Desarrollo

### 4.1. Requisitos Previos
*   Flutter SDK instalado y configurado en PATH.
*   Android Studio o VS Code con extensiones de Flutter/Dart.
*   JDK 17 configurado (requerido por versiones recientes de Gradle).
*   Dispositivo Android o Emulador.

### 4.2. Instalación
1.  Clonar el repositorio.
2.  Ejecutar `flutter pub get` para instalar dependencias.
3.  Configurar archivos de Firebase (`google-services.json` en `android/app`).
4.  Crear archivo `.env` (si aplica) con claves de API.

### 4.3. Compilación
*   **Debug**: `flutter run`
*   **Release (APK)**: `flutter build apk --release`
*   **Generar Iconos**: `dart run flutter_launcher_icons`

## 5. Base de Datos y Esquema

### 5.1. SQLite (Local)
*   **Versión**: 3
*   **Tablas**:
    *   `users`: Perfil de usuario.
    *   `subjects`: Materias y colores.
    *   `tasks`: Tareas, prioridades, fechas.
    *   `attachments`: Rutas locales y URLs remotas de archivos.

### 5.2. Firestore (Remoto)
*   Colecciones raíz: `users`, `subjects`, `tasks`, `attachments`.
*   Campos clave en Snake Case (`task_id`, `user_id`) para compatibilidad con backend.
*   Reglas de seguridad: Lectura/Escritura solo permitida al propietario del documento (`request.auth.uid == resource.data.user_id`).

## 6. Proceso de Sincronización
1.  **Detección de Cambios**: Al crear/editar offline, el registro local se marca con `sync_status = 'pending'`.
2.  **Sincronización**: Un servicio en segundo plano (u on-demand) busca registros con estado 'pending'.
3.  **Resolución**: Sube los datos a Firestore. Si tiene éxito, actualiza local a `sync_status = 'synced'`.
4.  **Descarga**: Al iniciar, la app descarga cambios remotos más recientes y actualiza la BD local.

## 7. Despliegue
*   El APK generado se encuentra en `build/app/outputs/flutter-apk/app-release.apk`.
*   Asegurarse de firmar la aplicación con el keystore de producción antes de distribuir.
