import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../run_tracking/domain/entities/saved_run.dart';
import '../../../run_tracking/presentation/widgets/saved_run_card.dart';
import 'home_section_shell.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    required this.latestRun,
    required this.onStartRun,
    required this.onOpenHistory,
    required this.onOpenRun,
    super.key,
  });

  final AsyncValue<SavedRun?> latestRun;
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
      child: latestRun.when(
        data: (run) {
          if (run == null) {
            return AppCard(
              key: const ValueKey('home-recent-empty-state'),
              child: AppEmptyState(
                title: 'No runs saved yet',
                message:
                    'Finish a run to begin shaping your personal Motion Path.',
                icon: Icons.route_rounded,
                iconColor: AppPalette.electricBright,
                actionLabel: 'Start Your First Run',
                onAction: onStartRun,
              ),
            );
          }

          return Column(
            key: const ValueKey('home-recent-activity-list'),
            children: [SavedRunCard(run: run, onTap: () => onOpenRun(run.id))],
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
