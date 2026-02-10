import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/search_service.dart';
import 'subject_notifier.dart'; // for databaseHelperProvider
import 'auth_notifier.dart' hide databaseHelperProvider;

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(databaseHelper: ref.watch(databaseHelperProvider));
});

final searchResultsProvider = FutureProvider.family<SearchResults, String>((
  ref,
  query,
) async {
  final service = ref.watch(searchServiceProvider);
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return const SearchResults();
  return service.search(query, user.userId);
});
