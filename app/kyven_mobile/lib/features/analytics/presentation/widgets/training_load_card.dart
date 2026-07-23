import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/analytics_trend.dart';
import '../../domain/entities/training_load_snapshot.dart';
import 'analytics_bar_chart.dart';
import 'analytics_formatters.dart';

class TrainingLoadCard extends StatelessWidget {
  const TrainingLoadCard({required this.load, super.key});

  final TrainingLoadSnapshot load;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      key: const ValueKey('analytics-training-load-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Training Load', style: theme.textTheme.titleLarge),
              ),
              AppTag(
                label: AnalyticsFormatters.loadLabel(load.classification),
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'A simple duration and intensity estimate. Not medical guidance.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AnalyticsBarChart(
            trend: AnalyticsTrend(points: load.dailyLoadPoints),
            semanticLabel: 'Daily training load chart',
            valueSuffix: '',
            height: 128,
          ),
        ],
      ),
    );
  }
}
