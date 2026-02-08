import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../widgets/molecules/empty_state.dart';
// Import entities/providers when available

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Placeholder data - Replace with Riverpod providers later
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Academic Task Manager'),
            Text(
              date_utils.DateUtilsHelper.formatDate(today),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Today\'s Overview'),
            const SizedBox(height: 12),
            _buildOverviewCards(context),
            const SizedBox(height: 24),
            _buildSectionHeader(
              context,
              'Upcoming Tasks',
              action: 'See All',
              onAction: () => context.go('/tasks'),
            ),
            const SizedBox(height: 12),
            // Placeholder for tasks list
            const EmptyState(
              message: 'No tasks for today!',
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              context,
              'Active Subjects',
              action: 'Manage',
              onAction: () => context.go('/subjects'),
            ),
            const SizedBox(height: 12),
            // Placeholder for subjects list
            const SizedBox(
              height: 120,
              child: Center(child: Text('No subjects added yet')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show modal to add task or subject
        },
        label: const Text('New Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (action != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(context, 'Pending', '12', Colors.orange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(context, 'Completed', '5', Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(context, 'Average', '8.5', Colors.blue),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
