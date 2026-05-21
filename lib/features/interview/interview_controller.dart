import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/response.dart';
import '../../providers/providers.dart';

class InterviewState {
  final String name;
  final String role;
  final Map<String, dynamic> answers;
  final bool submitting;
  final String? error;

  InterviewState({
    this.name = '',
    this.role = '',
    this.answers = const {},
    this.submitting = false,
    this.error,
  });

  InterviewState copyWith({
    String? name,
    String? role,
    Map<String, dynamic>? answers,
    bool? submitting,
    String? error,
  }) =>
      InterviewState(
        name: name ?? this.name,
        role: role ?? this.role,
        answers: answers ?? this.answers,
        submitting: submitting ?? this.submitting,
        error: error,
      );
}

class InterviewController extends StateNotifier<InterviewState> {
  InterviewController(this._ref, this.surveyId) : super(InterviewState());
  final Ref _ref;
  final String surveyId;

  void setName(String v) => state = state.copyWith(name: v);
  void setRole(String v) => state = state.copyWith(role: v);

  void answer(String questionId, dynamic value) {
    final next = Map<String, dynamic>.from(state.answers);
    next[questionId] = value;
    state = state.copyWith(answers: next);
  }

  Future<bool> submit() async {
    state = state.copyWith(submitting: true, error: null);
    try {
      await _ref.read(responseRepoProvider).submit(
            SurveyResponse(
              id: const Uuid().v4(),
              surveyId: surveyId,
              stakeholderName: state.name,
              stakeholderRole: state.role,
              answers: state.answers,
              submittedAt: DateTime.now().toUtc(),
            ),
          );
      _ref.invalidate(responsesProvider(surveyId));
      _ref.invalidate(responsesByDayProvider(surveyId));
      state = state.copyWith(submitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
      return false;
    }
  }
}

final interviewControllerProvider = StateNotifierProvider.autoDispose
    .family<InterviewController, InterviewState, String>(
        (ref, surveyId) => InterviewController(ref, surveyId));
