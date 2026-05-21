enum QuestionType { shortText, longText, rating, singleChoice, multiChoice }

QuestionType qtFromString(String s) =>
    QuestionType.values.firstWhere((e) => e.name == s, orElse: () => QuestionType.shortText);

class Question {
  final String id;
  final String surveyId;
  final String prompt;
  final QuestionType type;
  final List<String> choices;
  final int order;
  final bool required;

  Question({
    required this.id,
    required this.surveyId,
    required this.prompt,
    required this.type,
    required this.choices,
    required this.order,
    required this.required,
  });

  factory Question.fromMap(Map<String, dynamic> m) => Question(
        id: m['id'] as String,
        surveyId: m['survey_id'] as String,
        prompt: m['prompt'] as String,
        type: qtFromString(m['type'] as String),
        choices: ((m['choices'] ?? []) as List).cast<String>(),
        order: (m['order_index'] ?? 0) as int,
        required: (m['required'] ?? false) as bool,
      );
}
