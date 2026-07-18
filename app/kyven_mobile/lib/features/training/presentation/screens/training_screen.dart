import 'package:flutter/material.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  static const _options = [
    AppChoiceOption(value: '5K', label: '5K'),
    AppChoiceOption(value: '10K', label: '10K'),
    AppChoiceOption(value: 'Half', label: 'Half'),
  ];
  String _focus = '5K';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        key: const PageStorageKey('training-scroll'),
        child: AppResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTag(
                label: 'Coach signal · Optimal',
                color: AppPalette.lime,
                icon: Icons.auto_awesome_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Build speed.\nStay fluid.',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              _ReadinessHero(focus: _focus),
              const SizedBox(height: AppSpacing.xl),
              AppChoiceSelector<String>(
                options: _options,
                selected: _focus,
                onSelected: (value) => setState(() => _focus = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(
                title: 'Next ignition',
                subtitle: 'Tuesday · 6:30 AM',
              ),
              const SizedBox(height: AppSpacing.md),
              const _NextWorkout(),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(
                title: 'Week flow',
                subtitle: 'Stress balanced across three sessions',
              ),
              const SizedBox(height: AppSpacing.md),
              const _WeekFlow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadinessHero extends StatelessWidget {
  const _ReadinessHero({required this.focus});

  final String focus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      showShadow: true,
      glowColor: AppPalette.electricBright,
      padding: const EdgeInsets.all(AppSpacing.xl),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppPalette.graphite, AppPalette.electricDeep],
      ),
      child: Row(
        children: [
          AppProgressRing(
            progress: 0.82,
            size: AppLayout.avatarLarge,
            strokeWidth: AppSpacing.sm,
            child: Text('82', style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READY TO LOAD',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppPalette.lime,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$focus foundation',
                  key: const ValueKey('training-selected-focus'),
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Week 2 / 8 · Form rising',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppPalette.cloud,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextWorkout extends StatelessWidget {
  const _NextWorkout();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: AppPalette.lime,
      borderColor: AppPalette.lime,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              Text(
                'TEMPO / 04',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppPalette.ink,
                  letterSpacing: 1,
                ),
              ),
              const Icon(Icons.north_east_rounded, color: AppPalette.ink),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Controlled\ncombustion.',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: const [
              Expanded(
                child: _DarkStat(value: '32', label: 'MIN'),
              ),
              Expanded(
                child: _DarkStat(value: '4:58', label: 'PACE'),
              ),
              Expanded(
                child: _DarkStat(value: '7.2', label: 'KM'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({required this.value, required this.label});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppPalette.ink),
      ),
      Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppPalette.ink.withValues(alpha: 0.65),
          letterSpacing: 1,
        ),
      ),
    ],
  );
}

class _WeekFlow extends StatelessWidget {
  const _WeekFlow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessions = const [
      ('TUE', 'Tempo ignition', '32 MIN', AppPalette.lime),
      ('THU', 'Easy float', '40 MIN', AppPalette.electricBright),
      ('SUN', 'Long horizon', '70 MIN', AppPalette.violet),
    ];
    return Column(
      children: [
        for (var i = 0; i < sessions.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: AppSpacing.md,
                    height: AppSpacing.md,
                    decoration: BoxDecoration(
                      color: sessions[i].$4,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i < sessions.length - 1)
                    Container(
                      width: AppSpacing.xxs,
                      height: AppSpacing.xxxl,
                      color: AppPalette.steel,
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Row(
                    children: [
                      SizedBox(
                        width: AppLayout.avatarSmall,
                        child: Text(
                          sessions[i].$1,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppPalette.smoke,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          sessions[i].$2,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        sessions[i].$3,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: sessions[i].$4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
