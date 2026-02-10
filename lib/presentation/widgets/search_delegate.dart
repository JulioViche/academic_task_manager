import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/search_providers.dart';

class CustomSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  CustomSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchAsyncValue = ref.watch(searchResultsProvider(query));

    return searchAsyncValue.when(
      data: (results) {
        if (results.isEmpty) {
          return const Center(child: Text('No se encontraron resultados'));
        }
        return ListView(
          children: [
            if (results.subjects.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Materias',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ...results.subjects.map(
                (subject) => ListTile(
                  leading: const Icon(Icons.class_),
                  title: Text(subject.name),
                  subtitle: Text(subject.professorName ?? ''),
                  onTap: () {
                    context.push('/subjects/detail/${subject.id}');
                    close(context, null);
                  },
                ),
              ),
            ],
            if (results.tasks.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Tareas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ...results.tasks.map(
                (task) => ListTile(
                  leading: const Icon(Icons.task),
                  title: Text(task.title),
                  subtitle: Text(task.description ?? ''),
                  onTap: () {
                    context.push('/tasks/detail/${task.id}');
                    close(context, null);
                  },
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
