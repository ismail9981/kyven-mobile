import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import 'design_system_section.dart';

class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DesignSystemSection(
          title: 'Loading states',
          child: Column(
            children: [
              AppLoadingIndicator(label: 'Preparing your run'),
              SizedBox(height: AppSpacing.xl),
              LinearProgressIndicator(value: 0.65),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const DesignSystemSection(
          title: 'Empty and error states',
          child: Column(
            children: [
              AppEmptyState(
                title: 'No activities yet',
                message: 'Completed runs will appear here.',
                icon: Icons.route_outlined,
              ),
              AppDivider(),
              AppErrorState(
                title: 'Unable to load',
                message: 'Check your connection and try again.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const DesignSystemSection(
          title: 'Semantic feedback',
          description: 'Icons and text reinforce meaning beyond color alone.',
          child: Column(
            children: [
              AppStatusBanner(
                status: AppStatus.success,
                title: 'Run saved',
                message: 'Your activity is ready to review.',
              ),
              SizedBox(height: AppSpacing.md),
              AppStatusBanner(
                status: AppStatus.warning,
                title: 'GPS signal is weak',
                message: 'Wait briefly for a more accurate route.',
              ),
              SizedBox(height: AppSpacing.md),
              AppStatusBanner(
                status: AppStatus.error,
                title: 'Unable to save',
                message: 'Your run remains on this device for another attempt.',
              ),
              SizedBox(height: AppSpacing.md),
              AppStatusBanner(
                status: AppStatus.info,
                title: 'Preview mode',
                message: 'No backend action will be performed.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
