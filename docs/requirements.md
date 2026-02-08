# UNIVERSIDAD DE LAS FUERZAS ARMADAS – ESPE

**Materia:** Desarrollo de Aplicaciones Móviles  
**Documento:** Proyectos Finales del Semestre  
**Duración aproximada del Proyecto:** 2 meses  
**Integrantes:** Denise Rea y Julio Viche  
**Entrega obligatoria:** Publicación en Google Play + Manuales + Presentación Final

---

## 1. Requerimientos Generales

En el proyecto, sin excepción, debe incluir:

### 1.1 Arquitectura, Diseño y Calidad

- Clean Architecture completa (data, domain, presentation).
- Atomic Design aplicado a toda la interfaz.
- Manejo profesional de estado: Riverpod, Bloc o Provider estructurado.
- Temas claro/oscuro opcionales.
- Animaciones básicas en navegación y carga.

### 1.2 Funcionamiento Offline / Online

La aplicación debe:

- Funcionar completamente si no hay internet.
- Usar almacenamiento local: Room o SQLite.
- Implementar un sistema de sincronización con la nube al volver la conexión.
- Guardar datos críticos localmente (caché + persistencia).

### 1.3 Autenticación

La app debe incluir:

1. Autenticación con Google

2. Autenticación con Facebook

3. Autenticación con FIREBASE o MONGODB

### 1.4 Sincronización con la Nube

Se debe guardar los datos en Firebase

Debe permitir:

- Subir datos locales cuando regrese el internet.
- Resolver conflictos básicos (último guardado prevalece).

### 1.5 Notificaciones

- **Locales:** recordatorios, tareas, alertas.
- **Push:** enviadas desde Firebase Cloud Messaging.

### 1.6 Módulos Visuales Obligatorios

La aplicación debe incluir:

- Listas dinámicas
- Grids
- Menús (inferior, lateral o ambos)
- Pantallas detalladas (detail view)
- Búsquedas
- Filtros

### 1.7 Sensores y funcionalidades del dispositivo

El proyecto debe usar:

- Cámara (subir imágenes)
- Sensor de luz (cambio automático de tema claro/oscuro)

### 1.8 Manuales Requeridos

Se debe entregar los siguientes documentos:

1. Manual de Usuario (PDF)
2. Manual de Usuario dentro de la App (pantalla dedicada)
3. Manual de Desarrollo (arquitectura, decisiones técnicas, diseños para Google Play)
4. Manual de Programación (código explicado, diagramas, casos de uso)
5. Código fuente de la app y de los diseños gráficos.

Debe incluir:

- Diagramas de arquitectura
- Diagrama entidad-relación
- Historial de sincronización
- Estructura de paquetes
- Capturas de pantalla

### 1.9 Publicación Obligatoria

La aplicación debe ser publicada en:

**Google Play Store** (Producción o Beta cerrada)

- Con política de privacidad
- Con capturas, descripción, íconos e imágenes necesarias

---

## Proyecto 7: Sistema Académico con Tareas, Archivos, Notas y Lecturas

### Resumen

Una app tipo Classroom simplificada, pero con modo offline.

### Características mínimas

- CRUD de tareas
- Adjuntar fotos y PDFs
- Calendario académico
- Almacenamiento interno
- Sincronización cuando vuelva internet
- Lector PDF integrado
- Notificaciones: próximas entregas
- Estadísticas por materia