import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/response.dart';
import '../data/models/survey.dart';
import '../data/repositories/response_repo.dart';
import '../data/repositories/survey_repo.dart';

final supabaseProvider = Provider<SupabaseClient>((_) => Supabase.instance.client);

final surveyRepoProvider =
    Provider<SurveyRepo>((ref) => SurveyRepo(ref.watch(supabaseProvider)));

final responseRepoProvider =
    Provider<ResponseRepo>((ref) => ResponseRepo(ref.watch(supabaseProvider)));

final surveysProvider = FutureProvider<List<Survey>>((ref) async {
  return ref.watch(surveyRepoProvider).listSurveys();
});

final surveyProvider =
    FutureProvider.family<Survey?, String>((ref, id) async {
  return ref.watch(surveyRepoProvider).getSurvey(id);
});

final responsesProvider =
    FutureProvider.family<List<SurveyResponse>, String>((ref, surveyId) async {
  return ref.watch(responseRepoProvider).listForSurvey(surveyId);
});

final responsesByDayProvider =
    FutureProvider.family<Map<String, int>, String>((ref, surveyId) async {
  return ref.watch(responseRepoProvider).countByDay(surveyId);
});
