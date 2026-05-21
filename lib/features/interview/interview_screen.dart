import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import 'interview_controller.dart';
import 'question_widget.dart';

class InterviewScreen extends ConsumerWidget {
  final String surveyId;
  const InterviewScreen({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveyAsync = ref.watch(surveyProvider(surveyId));
    final state = ref.watch(interviewControllerProvider(surveyId));
    final ctrl = ref.read(interviewControllerProvider(surveyId).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Interview')),
      body: surveyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (survey) {
          if (survey == null) return const Center(child: Text('Survey not found'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(survey.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              if (survey.description.isNotEmpty) Text(survey.description),
              const Divider(height: 32),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Stakeholder name',
                  border: OutlineInputBorder(),
                ),
                onChanged: ctrl.setName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Role / organisation',
                  border: OutlineInputBorder(),
                ),
                onChanged: ctrl.setRole,
              ),
              const SizedBox(height: 24),
              for (final q in survey.questions) ...[
                QuestionWidget(
                  question: q,
                  value: state.answers[q.id],
                  onChanged: (v) => ctrl.answer(q.id, v),
                ),
                const SizedBox(height: 24),
              ],
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                ),
              FilledButton.icon(
                onPressed: state.submitting
                    ? null
                    : () async {
                        final ok = await ctrl.submit();
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Response submitted')),
                          );
                          context.pop();
                        }
                      },
                icon: state.submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}
