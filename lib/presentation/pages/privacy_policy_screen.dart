import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Política de Privacidad y Manejo de Datos',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: 10 de Febrero de 2026',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Introducción',
              'Academic Task Manager respeta su privacidad y está comprometido a proteger sus datos personales. Esta política de privacidad le informará sobre cómo cuidamos sus datos personales cuando utiliza nuestra aplicación móvil y le informará sobre sus derechos de privacidad.',
            ),
            _buildSection(
              context,
              '2. Datos que Recopilamos',
              'Podemos recopilar, usar, almacenar y transferir diferentes tipos de datos personales sobre usted:\n\n'
                  '• Datos de Identidad: Nombre para mostrar, Foto de perfil (opcional).\n'
                  '• Datos de Contacto: Dirección de correo electrónico (utilizada únicamente para autenticación y recuperación de cuenta).\n'
                  '• Datos de Contenido: Tareas académicas, nombres de materias, notas, horarios y archivos adjuntos que usted suba voluntariamente.\n'
                  '• Datos Técnicos: Dirección IP, tipo de dispositivo, versión del sistema operativo (para diagnóstico de errores).',
            ),
            _buildSection(
              context,
              '3. Cómo Usamos sus Datos',
              'Solo utilizaremos sus datos personales cuando la ley lo permita. Principalmente, usamos sus datos para:\n\n'
                  '• Registrarlo como nuevo usuario.\n'
                  '• Proporcionar la funcionalidad principal de gestión de tareas y materias.\n'
                  '• Sincronizar su información entre sus diferentes dispositivos a través de la nube.\n'
                  '• Gestionar nuestra relación con usted (notificaciones de tareas vencidas).',
            ),
            _buildSection(
              context,
              '4. Almacenamiento de Datos',
              '• Local: Sus datos se almacenan en su propio dispositivo utilizando una base de datos SQLite segura.\n'
                  '• Nube: Utilizamos Google Firebase como proveedor de servicios en la nube.\n'
                  '    • Firestore: Para almacenar datos estructurados (tareas, materias).\n'
                  '    • Firebase Storage: Para almacenar archivos adjuntos (PDFs, imágenes).\n'
                  '    • Autenticación: Gestionada por Firebase Auth.',
            ),
            _buildSection(
              context,
              '5. Seguridad de los Datos',
              'Hemos implementado medidas de seguridad apropiadas para evitar que sus datos personales se pierdan accidentalmente, se utilicen o se acceda a ellos de forma no autorizada. El acceso a sus datos en la nube está restringido mediante Reglas de Seguridad estrictas que aseguran que solo usted (el usuario autenticado) pueda leer o escribir su propia información.',
            ),
            _buildSection(
              context,
              '6. Eliminación de Datos',
              'Usted tiene derecho a solicitar la eliminación de su cuenta y todos los datos asociados en cualquier momento. Puede hacerlo desde la opción "Eliminar Cuenta" dentro de la configuración de la aplicación o contactando a nuestro soporte. Al eliminar su cuenta, todos sus registros en nuestros servidores de Firebase se borrarán permanentemente.',
            ),
            _buildSection(
              context,
              '7. Cambios en la Política de Privacidad',
              'Es posible que actualicemos nuestra Política de Privacidad de vez en cuando. Le notificaremos de cualquier cambio publicando la nueva Política de Privacidad en esta página.',
            ),
            _buildSection(
              context,
              '8. Contacto',
              'Si tiene alguna pregunta sobre esta política de privacidad, por favor contáctenos a través de la sección de Ayuda en la aplicación.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '© 2026 TwoDevLab',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
