import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'design_system_section.dart';

class TypographySection extends StatelessWidget {
  const TypographySection({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final styles = [
      ('Display', text.appDisplay),
      ('Screen title', text.appScreenTitle),
      ('Section title', text.appSectionTitle),
      ('Body', text.appBody),
      ('Body secondary', text.appBodySecondary),
      ('Metric large', text.appMetricLarge),
      ('Metric medium', text.appMetricMedium),
      ('Label', text.appLabel),
      ('Caption', text.appCaption),
      ('Button', text.appButton),
    ];

    return DesignSystemSection(
      title: 'Typography scale',
      description: 'Semantic type roles sourced from the global theme.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < styles.length; index++) ...[
            Text(styles[index].$1, style: styles[index].$2),
            if (index < styles.length - 1)
              const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}
