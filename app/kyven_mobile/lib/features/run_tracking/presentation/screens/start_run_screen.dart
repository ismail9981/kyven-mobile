import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/run_session_providers.dart';

class StartRunScreen extends ConsumerStatefulWidget {
  const StartRunScreen({super.key});

  @override
  ConsumerState<StartRunScreen> createState() => _StartRunScreenState();
}

class _StartRunScreenState extends ConsumerState<StartRunScreen> {
  static const _countdownValues = ['3', '2', '1', 'Go'];
  Timer? _countdownTimer;
  var _countdownIndex = 0;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 650), (_) {
      if (!mounted) return;
      setState(() {
        if (_countdownIndex < _countdownValues.length - 1) {
          _countdownIndex += 1;
        }
      });
      if (_countdownIndex == _countdownValues.length - 1) {
        _countdownTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _beginSession(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(runSessionProvider.notifier);
    notifier.prepare();
    notifier.start();
    context.goNamed(AppRoute.runLive.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countdownValue = _countdownValues[_countdownIndex];
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: Stack(
        children: [
          const Positioned.fill(child: AppKyvenVelocityField(intensity: 0.34)),
          SingleChildScrollView(
            key: const PageStorageKey('start-run-preparation-scroll'),
            child: AppResponsiveContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppTag(
                    label: 'GPS LOCKED · PREVIEW',
                    color: AppPalette.lime,
                    icon: Icons.gps_fixed_rounded,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(
                    'Ready',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'A focused run session starts when you are ready.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppPalette.smoke,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Semantics(
                    liveRegion: true,
                    label: 'Countdown $countdownValue',
                    child: ExcludeSemantics(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: reduceMotion
                              ? AppDurations.instant
                              : AppDurations.normal,
                          layoutBuilder: (currentChild, previousChildren) {
                            return currentChild ?? const SizedBox.shrink();
                          },
                          child: _CountdownStep(
                            key: ValueKey('run-countdown-$countdownValue'),
                            value: countdownValue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppProgressRing(
                    progress: (0.2 + (_countdownIndex * 0.24)).clamp(0, 1),
                    size: AppLayout.runRing * 0.84,
                    strokeWidth: AppSpacing.md,
                    glowOpacity: 0.72,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: AppPalette.white,
                          size: 72,
                        ),
                        Text(
                          'RUN SESSION',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppPalette.smoke,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  AppButton(
                    key: const ValueKey('run-begin-session-button'),
                    label: 'Begin Session',
                    onPressed: () => _beginSession(context, ref),
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownStep extends StatelessWidget {
  const _CountdownStep({required this.value, super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SizedBox.square(
        dimension: 76,
        child: Center(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
