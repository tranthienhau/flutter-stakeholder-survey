import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/response.dart';

class ResponseRepo {
  final SupabaseClient _db;
  ResponseRepo(this._db);

  Future<void> submit(SurveyResponse r) async {
    await _db.from('responses').insert(r.toInsert());
  }

  Future<List<SurveyResponse>> listForSurvey(String surveyId) async {
    final rows = await _db
        .from('responses')
        .select()
        .eq('survey_id', surveyId)
        .order('submitted_at', ascending: false);
    return (rows as List)
        .map((r) => SurveyResponse.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<Map<String, int>> countByDay(String surveyId, {int days = 14}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final rows = await _db
        .from('responses')
        .select('submitted_at')
        .eq('survey_id', surveyId)
        .gte('submitted_at', since.toIso8601String());
    final out = <String, int>{};
    for (final raw in (rows as List)) {
      final d = DateTime.parse(raw['submitted_at'] as String);
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      out[key] = (out[key] ?? 0) + 1;
    }
    return out;
  }
}
