# Known Errors and Solutions

This document tracks common errors encountered during development and their solutions.

## Windows: Building with plugins requires symlink support

### Error Message
```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings. Run
  start ms-settings:developers
to open settings.
```

### Context
This error occurs on Windows when running `flutter pub get` or `flutter run` if the project uses Flutter plugins that rely on symbolic links (symlinks). Windows restricts symlink creation by default for standard users.

### Solution
Enable **Developer Mode** in Windows Settings to allow symlink creation without elevated privileges.

1.  Open the **Start Menu**.
2.  Type **"Developer settings"** (or run `start ms-settings:developers` in Command Prompt/PowerShell).
3.  Toggle the **"Developer Mode"** switch to **On**.
4.  Confirm the security prompt.
5.  Re-run `flutter pub get`.

Alternatively, run your terminal (CMD/PowerShell) as **Administrator**, but enabling Developer Mode is the recommended long-term fix.

## Android: Device still authorizing (ADB)

### Error Message
```
Error 1 retrieving device properties for [DEVICE_ID]:
adb.exe: device still authorizing
```

### Context
This occurs when an Android device is connected via USB but has not yet authorized the computer for debugging. A popup on the device screen is waiting for approval.

### Solution
1.  Unlock your Android device screen.
2.  Look for a prompt **"Allow USB debugging?"**.
3.  Check **"Always allow from this computer"** (optional but recommended).
4.  Tap **"Allow"** or **"OK"**.
5.  Run `flutter devices` again to confirm the device is authorized.

## Build: Namespace not specified (Gradle/AGP 8+)

### Error Message
```
A problem occurred configuring project ':light'.
> Could not create an instance of type com.android.build.api.variant.impl.LibraryVariantBuilderImpl.
   > Namespace not specified. Specify a namespace in the module's build file...
```

### Context
This error happens when using older Flutter plugins (like `light`) with newer Android Gradle Plugin (AGP) versions (8.0+). Newer AGP requires a `namespace` to be declared in the library's `build.gradle`, but older plugins haven't updated this.

### Solution
The `light` package seems unmaintained.
**Option 1 (Recommended):** Temporarily remove the dependency if not immediately critical.
**Option 2:** Use a maintained fork or alternative package.
**Option 3:** Manually edit the cached file (temporary, not recommended).

**Workaround:**
1. Open `pubspec.yaml`.
2. Comment out `light: ^3.0.0`.
3. Run `flutter pub get`.
4. Run `flutter run`.

## Build: Core Library Desugaring Required

### Error Message
```
Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app.
```

### Context
`flutter_local_notifications` (v10+) uses Java 8 features that require "desugaring" on older Android versions.

### Solution
Enable `coreLibraryDesugaring` in `android/app/build.gradle.kts`:

1.  In `android { compileOptions { ... } }`, add:
    ```kotlin
    isCoreLibraryDesugaringEnabled = true
    ```
2.  Add the dependency:
    ```kotlin
    dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    }
    ```
