# Guía Completa de Configuración de Facebook Login

**SÍ, es obligatorio crear una App en Meta para que funcione el inicio de sesión.**

Sigue estos pasos detallados para configurar todo desde cero:

## 1. Crear la App en Meta
1.  Ve a [developers.facebook.com](https://developers.facebook.com/) e inicia sesión con tu cuenta de Facebook.
2.  Haz clic en **Mis Apps** (My Apps) en la esquina superior derecha.
3.  Haz clic en el botón verde **Crear App** (Create App).
4.  Selecciona el caso de uso: **Permitir que las personas inicien sesión con su cuenta de Facebook**. Haz clic en Siguiente.
5.  Ingresa el **Nombre de la App** (ej: `Academic Task Manager`).
6.  Ingresa tu correo de contacto y haz clic en **Crear App**.

## 2. Configurar el Inicio de Sesión
1.  En el panel de la izquierda o en el "Dashboard", busca el producto **Inicio de sesión con Facebook** (Facebook Login) y haz clic en **Configurar** (Set Up).
2.  Selecciona **Android**.
3.  Descarga el SDK: **Omite este paso**, ya lo tenemos instalado en Flutter. Haz clic en Siguiente.
4.  Importar SDK: **Omite este paso**. Haz clic en Siguiente.
5.  **Información de la App (Package Name):**
    *   Nombre del paquete: `com.example.academic_task_manager` (o verifica en `android/app/build.gradle` bajo `applicationId`).
    *   Clase principal: `com.example.academic_task_manager.MainActivity` (tu paquete + `.MainActivity`).
    *   Haz clic en **Guardar**.
6.  **Key Hashes (Claves Hash):**
    *   Necesitarás generar un hash de tu clave de desarrollo. Ejecuta este comando en tu terminal (en la carpeta del proyecto):
    *   **Windows:**
        ```bash
        keytool -exportcert -alias androiddebugkey -keystore "C:\Users\TU_USUARIO\.android\debug.keystore" | openssl sha1 -binary | openssl base64
        ```
        *(Nota: La contraseña por defecto es `android`). Si no tienes `openssl`, usa Git Bash.*
    *   Copia el hash generado (termina en `=`) y pégalo en el campo "Key Hashes" en Facebook.
    *   Haz clic en **Guardar**.
7.  Habilita el "Inicio de sesión único" si lo deseas y haz clic en Siguiente.

## 3. Obtener Identificadores
1.  Ve a **Configuración > Básica** en el menú izquierdo de Meta.
2.  Copia el **Identificador de la app (App ID)**.
3.  Copia la **Clave secreta de la app (App Secret)**.
4.  Ve a **Configuración > Avanzada**.
5.  Busca la sección "Seguridad" y copia el **Token de cliente (Client Token)**.

## 4. Configurar el Proyecto Android (Strings.xml)
Abre el archivo `android/app/src/main/res/values/strings.xml` (ya creado) y reemplaza los textos con tus datos:

```xml
<string name="facebook_app_id">TU_APP_ID</string>
<string name="facebook_client_token">TU_CLIENT_TOKEN</string>
<string name="fb_login_protocol_scheme">fbTU_APP_ID</string>
```
*Nota: En `fb_login_protocol_scheme`, deja el prefijo `fb` seguido de tu App ID.*

## 5. Configurar en Firebase Console
1. Abre la [Consola de Firebase](https://console.firebase.google.com/).
2. Ve a **Authentication > Sign-in method**.
3. Haz clic en **Agregar nuevo proveedor** y selecciona **Facebook**.
4. Pega el **App ID** y el **App Secret** que obtuviste en el paso 3.
5. **IMPORTANTE:** Copia la URL que aparece abajo donde dice **URI de redireccionamiento de OAuth** (termina en `/__/auth/handler`).
6. Haz clic en **Guardar**.

## 6. Finalizar en Meta (URI de Redireccionamiento)
1. Vuelve a [Meta for Developers](https://developers.facebook.com/).
2. En el menú izquierdo, ve a **Inicio de sesión con Facebook > Configuración**.
3. En el campo **Validar URIs de redireccionamiento de OAuth**, pega la URL que copiaste de Firebase (paso 5).
4. Haz clic en **Guardar cambios**.
