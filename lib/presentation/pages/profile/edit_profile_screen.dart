import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: const Center(
        child: Text('Pantalla de Edición de Perfil (Próximamente)'),
      ),
    );
  }
}
