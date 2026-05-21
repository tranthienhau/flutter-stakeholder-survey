import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveys = ref.watch(surveysProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: surveys.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('No surveys'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: list.map((s) => _SurveyCard(surveyId: s.id, title: s.title)).toList(),
          );
        },
      ),
    );
  }
}

class _SurveyCard extends ConsumerWidget {
  final String surveyId;
  final String title;
  const _SurveyCard({required this.surveyId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responses = ref.watch(responsesProvider(surveyId));
    final byDay = ref.watch(responsesByDayProvider(surveyId));
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(
                  label: 'Total',
                  value: responses.maybeWhen(
                    data: (r) => r.length.toString(),
                    orElse: () => '-',
                  ),
                ),
                const SizedBox(width: 24),
                _Stat(
                  label: 'Last 14d',
                  value: byDay.maybeWhen(
                    data: (m) => m.values.fold<int>(0, (a, b) => a + b).toString(),
                    orElse: () => '-',
                  ),
                ),
                const SizedBox(width: 24),
                _Stat(
                  label: 'Today',
                  value: responses.maybeWhen(
                    data: (r) {
                      final today = DateTime.now();
                      return r
                          .where((x) =>
                              x.submittedAt.year == today.year &&
                              x.submittedAt.month == today.month &&
                              x.submittedAt.day == today.day)
                          .length
                          .toString();
                    },
                    orElse: () => '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: byDay.when(
                data: _BarChart.new,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final Map<String, int> data;
  const _BarChart(this.data);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(14, (i) {
      final d = now.subtract(Duration(days: 13 - i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return MapEntry(d, data[key] ?? 0);
    });
    final maxY = (days.map((e) => e.value).fold<int>(0, (a, b) => a > b ? a : b) + 1).toDouble();
    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= days.length || i % 3 != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(DateFormat('d/M').format(days[i].key),
                      style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: days[i].value.toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
