import 'question.dart';

class Survey {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final DateTime createdAt;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.createdAt,
  });

  factory Survey.fromMap(Map<String, dynamic> m, List<Question> qs) => Survey(
        id: m['id'] as String,
        title: m['title'] as String,
        description: (m['description'] ?? '') as String,
        questions: qs,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
