class SurveyResponse {
  final String id;
  final String surveyId;
  final String stakeholderName;
  final String stakeholderRole;
  final Map<String, dynamic> answers;
  final DateTime submittedAt;

  SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.stakeholderName,
    required this.stakeholderRole,
    required this.answers,
    required this.submittedAt,
  });

  Map<String, dynamic> toInsert() => {
        'id': id,
        'survey_id': surveyId,
        'stakeholder_name': stakeholderName,
        'stakeholder_role': stakeholderRole,
        'answers': answers,
        'submitted_at': submittedAt.toIso8601String(),
      };

  factory SurveyResponse.fromMap(Map<String, dynamic> m) => SurveyResponse(
        id: m['id'] as String,
        surveyId: m['survey_id'] as String,
        stakeholderName: (m['stakeholder_name'] ?? '') as String,
        stakeholderRole: (m['stakeholder_role'] ?? '') as String,
        answers: Map<String, dynamic>.from(m['answers'] as Map),
        submittedAt: DateTime.parse(m['submitted_at'] as String),
      );
}
