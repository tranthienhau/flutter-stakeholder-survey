import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/dashboard/dashboard_screen.dart';
import 'features/home/home_screen.dart';
import 'features/interview/interview_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/interview/:surveyId',
      builder: (_, state) => InterviewScreen(
        surveyId: state.pathParameters['surveyId']!,
      ),
    ),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
  ],
);

class StakeholderSurveyApp extends ConsumerWidget {
  const StakeholderSurveyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Stakeholder Survey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      ),
      routerConfig: _router,
    );
  }
}
