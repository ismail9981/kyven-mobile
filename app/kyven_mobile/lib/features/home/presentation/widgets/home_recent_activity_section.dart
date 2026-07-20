import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../run_tracking/domain/entities/motion_insights.dart';
import '../../../run_tracking/domain/services/session_name_generator.dart';
import '../../../run_tracking/presentation/widgets/saved_run_card.dart';
import 'home_section_shell.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    required this.insights,
    required this.onStartRun,
    required this.onOpenHistory,
    required this.onOpenRun,
    super.key,
  });

  final AsyncValue<MotionInsights> insights;
  final VoidCallback onOpenHistory;
  final ValueChanged<String> onOpenRun;
  final VoidCallback onStartRun;

  @override
  Widget build(BuildContext context) {
    return HomeDashboardSection(
      title: 'Recent Activity',
      subtitle: 'Saved locally on this device',
      actionLabel: 'History',
      onAction: onOpenHistory,
      child: insights.when(
        data: (data) {
          if (data.latestRuns.isEmpty) {
            return AppCard(
              key: const ValueKey('home-recent-empty-state'),
              child: AppEmptyState(
                title: 'No runs recorded yet',
                message: 'Start your first movement.',
                icon: Icons.route_rounded,
                iconColor: AppPalette.electricBright,
                actionLabel: 'Start Your First Run',
                onAction: onStartRun,
              ),
            );
          }

          return Column(
            key: const ValueKey('home-recent-activity-list'),
            children: [
              for (var index = 0; index < data.latestRuns.length; index++) ...[
                SavedRunCard(
                  run: data.latestRuns[index],
                  title: const SessionNameGenerator().generate(
                    data.latestRuns[index],
                  ),
                  onTap: () => onOpenRun(data.latestRuns[index].id),
                ),
                if (index != data.latestRuns.length - 1)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
        loading: () => const AppLoadingIndicator(label: 'Loading latest run'),
        error: (_, _) => const AppStatusBanner(
          status: AppStatus.error,
          title: 'Latest run unavailable',
          message: 'KYVEN could not load your saved activity.',
        ),
      ),
    );
  }
}
