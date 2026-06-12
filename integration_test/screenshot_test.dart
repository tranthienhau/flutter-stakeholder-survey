import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_stakeholder_survey/data/models/question.dart';
import 'package:flutter_stakeholder_survey/data/models/response.dart';
import 'package:flutter_stakeholder_survey/data/models/survey.dart';
import 'package:flutter_stakeholder_survey/features/dashboard/dashboard_screen.dart';
import 'package:flutter_stakeholder_survey/features/home/home_screen.dart';
import 'package:flutter_stakeholder_survey/features/interview/interview_screen.dart';
import 'package:flutter_stakeholder_survey/providers/providers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final boundaryKey = GlobalKey();
  // name -> base64 PNG; sent to the host driver via reportData, which writes
  // the files (the sim filesystem is read-only, so we cannot write here).
  final shots = <String, String>{};

  // Capture the rendered widget tree to a real PNG via RepaintBoundary.toImage.
  Future<void> shoot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300));
    final boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    shots[name] = base64Encode(bytes!.buffer.asUint8List());
  }

  final now = DateTime.now();

  final productSurvey = Survey(
    id: 'survey-product',
    title: 'Q3 Product Direction',
    description:
        'Validate the roadmap with key stakeholders before the planning cycle.',
    createdAt: now,
    questions: [
      Question(
        id: 'q1',
        surveyId: 'survey-product',
        prompt: 'How would you rate the current product direction?',
        type: QuestionType.rating,
        choices: const [],
        order: 0,
        required: true,
      ),
      Question(
        id: 'q2',
        surveyId: 'survey-product',
        prompt: 'Which area should we prioritise next quarter?',
        type: QuestionType.singleChoice,
        choices: const ['Onboarding', 'Reporting', 'Integrations', 'Performance'],
        order: 1,
        required: true,
      ),
      Question(
        id: 'q3',
        surveyId: 'survey-product',
        prompt: 'Which channels do your customers rely on?',
        type: QuestionType.multiChoice,
        choices: const ['Email', 'Mobile app', 'Web portal', 'API'],
        order: 2,
        required: false,
      ),
    ],
  );

  final onboardingSurvey = Survey(
    id: 'survey-onboarding',
    title: 'Customer Onboarding Health Check',
    description: 'Pulse check across success, sales, and support leaders.',
    createdAt: now,
    questions: [
      Question(
        id: 'o1',
        surveyId: 'survey-onboarding',
        prompt: 'Time to first value?',
        type: QuestionType.shortText,
        choices: const [],
        order: 0,
        required: true,
      ),
    ],
  );

  final surveys = [productSurvey, onboardingSurvey];

  List<SurveyResponse> responsesFor(String surveyId) => List.generate(
        18,
        (i) => SurveyResponse(
          id: 'r-$surveyId-$i',
          surveyId: surveyId,
          stakeholderName: 'Stakeholder ${i + 1}',
          stakeholderRole: 'Role ${i + 1}',
          answers: const {'q1': 4},
          submittedAt: now.subtract(Duration(days: i % 14, hours: i)),
        ),
      );

  Map<String, int> byDayFor(String surveyId) {
    final map = <String, int>{};
    final counts = [1, 2, 0, 3, 4, 2, 1, 5, 3, 2, 4, 1, 2, 3];
    for (var i = 0; i < 14; i++) {
      final d = now.subtract(Duration(days: 13 - i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      map[key] = counts[i];
    }
    return map;
  }

  List<Override> overrides() => [
        surveysProvider.overrideWith((ref) => surveys),
        surveyProvider.overrideWith(
          (ref, id) => surveys.firstWhere((s) => s.id == id),
        ),
        responsesProvider.overrideWith(
          (ref, surveyId) => responsesFor(surveyId),
        ),
        responsesByDayProvider.overrideWith(
          (ref, surveyId) => byDayFor(surveyId),
        ),
      ];

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
          home: RepaintBoundary(key: boundaryKey, child: screen),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('capture stakeholder survey flow', (tester) async {
    // 01 - Home: list of surveys
    await pump(tester, const HomeScreen());
    await shoot(tester, '01-surveys');

    // 02 - Interview: mixed question types
    await pump(tester, const InterviewScreen(surveyId: 'survey-product'));
    await shoot(tester, '02-interview');

    // 03 - Dashboard: stats + bar chart
    await pump(tester, const DashboardScreen());
    await shoot(tester, '03-dashboard');

    // Hand the PNGs to the host driver, which writes them to screenshots/.
    binding.reportData = <String, dynamic>{'shots': shots};
  });
}
