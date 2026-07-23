import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/personal_records.dart';
import 'analytics_formatters.dart';

class PersonalRecordsSection extends StatelessWidget {
  const PersonalRecordsSection({required this.records, super.key});

  final PersonalRecords records;

  @override
  Widget build(BuildContext context) {
    final available = records.available;
    if (available.isEmpty) {
      return const AppCard(
        child: AppEmptyState(
          title: 'No personal records yet',
          message: 'Complete a run to start building your record board.',
          icon: Icons.workspace_premium_outlined,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Personal Records',
          subtitle: 'Best efforts derived from saved runs.',
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final record in available) ...[
          _RecordCard(record: record),
          if (record != available.last) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppCard(
      semanticLabel:
          '${AnalyticsFormatters.recordTitle(record.type)}, ${AnalyticsFormatters.recordValue(record)}',
      child: Row(
        children: [
          Icon(Icons.military_tech_outlined, color: colors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              AnalyticsFormatters.recordTitle(record.type),
              style: theme.textTheme.titleMedium,
            ),
          ),
          Text(
            AnalyticsFormatters.recordValue(record),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
