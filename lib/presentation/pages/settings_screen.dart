import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_notifier.dart';

import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../providers/app_info_provider.dart';
import '../providers/sprint6_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final packageInfoAsync = ref.watch(packageInfoProvider);
    final storageAsync = ref.watch(storageUsageProvider);

    // Listen for logout state changes to redirect
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        context.go('/login');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'General'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Apariencia'),
            subtitle: const Text('Tema del sistema'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showThemeDialog(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Idioma'),
            subtitle: const Text('Español'),
            trailing: const Icon(Icons.chevron_right),
          ),

          const Divider(),

          // ─── Notifications Section ─────────────────────────
          const _SectionHeader(title: 'Notificaciones'),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Ver notificaciones'),
            subtitle: const Text('Historial de alertas y recordatorios'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.notification_add_outlined),
            title: const Text('Probar notificación'),
            subtitle: const Text('Enviar una notificación de prueba ahora'),
            trailing: const Icon(Icons.send),
            onTap: () => _sendTestNotification(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Notificaciones programadas'),
            subtitle: const Text('Ver recordatorios pendientes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPendingNotifications(context, ref),
          ),
          ListTile(
            leading: Icon(
              Icons.notifications_off_outlined,
              color: Colors.red.shade400,
            ),
            title: Text(
              'Cancelar todas',
              style: TextStyle(color: Colors.red.shade400),
            ),
            subtitle: const Text('Eliminar todos los recordatorios'),
            onTap: () => _cancelAllNotifications(context, ref),
          ),

          const Divider(),

          const _SectionHeader(title: 'Datos y Almacenamiento'),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Almacenamiento Local'),
            subtitle: storageAsync.when(
              data: (size) => Text(size),
              loading: () => const Text('Calculando...'),
              error: (_, s) => const Text('Desconocido'),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  // Clear image cache
                  PaintingBinding.instance.imageCache.clear();
                  PaintingBinding.instance.imageCache.clearLiveImages();

                  // Optional: Clear temporary files if we had a PathProvider service here

                  messenger.showSnackBar(
                    const SnackBar(content: Text('Caché de imágenes limpiada')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error al limpiar caché: $e')),
                  );
                }
              },
            ),
          ),

          const Divider(),

          const _SectionHeader(title: 'Acerca de'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versión'),
            subtitle: packageInfoAsync.when(
              data: (info) =>
                  Text('${info.version} (Build ${info.buildNumber})'),
              loading: () => const Text('Cargando...'),
              error: (_, s) => const Text('Desconocido'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de Privacidad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/privacy-policy');
            },
          ),

          const Divider(),
          const _SectionHeader(title: 'Cuenta'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: authState.isLoading
                ? null
                : () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification(BuildContext context, WidgetRef ref) async {
    final notifService = ref.read(notificationServiceProvider);

    await notifService.showNotification(
      id: 99999,
      title: '🔔 Notificación de prueba',
      body: 'Las notificaciones están funcionando correctamente',
      payload: 'test',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notificación de prueba enviada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPendingNotifications(BuildContext context, WidgetRef ref) async {
    final notifService = ref.read(notificationServiceProvider);
    final pending = await notifService.getPendingNotifications();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.schedule, size: 24),
            const SizedBox(width: 8),
            Text('Recordatorios (${pending.length})'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: pending.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No hay recordatorios programados.\n'
                        'Se crearán automáticamente al agregar\n'
                        'tareas con fecha de entrega.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: pending.length,
                  itemBuilder: (_, i) {
                    final n = pending[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.alarm, size: 20),
                      title: Text(
                        n.title ?? 'Sin título',
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        n.body ?? '',
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _cancelAllNotifications(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar todos los recordatorios?'),
        content: const Text(
          'Se eliminarán todas las notificaciones programadas. '
          'Se volverán a crear al agregar o editar tareas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar todas'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifService = ref.read(notificationServiceProvider);
      await notifService.cancelAllNotifications();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos los recordatorios cancelados'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Sistema'),
              value: ThemeMode.system,
              // ignore: deprecated_member_use
              groupValue: currentTheme,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Claro'),
              value: ThemeMode.light,
              // ignore: deprecated_member_use
              groupValue: currentTheme,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Oscuro'),
              value: ThemeMode.dark,
              // ignore: deprecated_member_use
              groupValue: currentTheme,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
