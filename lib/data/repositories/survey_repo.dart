import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/question.dart';
import '../models/survey.dart';

class SurveyRepo {
  final SupabaseClient _db;
  SurveyRepo(this._db);

  Future<List<Survey>> listSurveys() async {
    final surveys = await _db.from('surveys').select().order('created_at');
    final ids = (surveys as List).map((s) => s['id'] as String).toList();
    if (ids.isEmpty) return [];
    final qs = await _db.from('questions').select().inFilter('survey_id', ids).order('order_index');
    final byId = <String, List<Question>>{};
    for (final raw in (qs as List)) {
      final q = Question.fromMap(Map<String, dynamic>.from(raw as Map));
      byId.putIfAbsent(q.surveyId, () => []).add(q);
    }
    return surveys.map<Survey>((s) {
      final m = Map<String, dynamic>.from(s as Map);
      return Survey.fromMap(m, byId[m['id']] ?? const []);
    }).toList();
  }

  Future<Survey?> getSurvey(String id) async {
    final s = await _db.from('surveys').select().eq('id', id).maybeSingle();
    if (s == null) return null;
    final qs = await _db.from('questions').select().eq('survey_id', id).order('order_index');
    final questions = (qs as List)
        .map((r) => Question.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
    return Survey.fromMap(Map<String, dynamic>.from(s), questions);
  }
}
