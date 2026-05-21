import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveys = ref.watch(surveysProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stakeholder Surveys'),
        actions: [
          IconButton(
            tooltip: 'Dashboard',
            icon: const Icon(Icons.dashboard_outlined),
            onPressed: () => context.push('/dashboard'),
          ),
        ],
      ),
      body: surveys.when(
        data: (list) {
          if (list.isEmpty) {
            return const _Empty();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final s = list[i];
              return Card(
                child: ListTile(
                  title: Text(s.title),
                  subtitle: Text(s.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Text('${s.questions.length} q'),
                  onTap: () => context.push('/interview/${s.id}'),
                ),
              );
            },
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.poll_outlined, size: 64),
            SizedBox(height: 12),
            Text('No surveys yet.'),
            SizedBox(height: 6),
            Text('Seed Supabase with surveys + questions (see README).'),
          ],
        ),
      ),
    );
  }
}
