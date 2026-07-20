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
  static const _countdownValues = ['3', '2', '1'];
  Timer? _countdownTimer;
  var _countdownIndex = 0;
  var _countdownActive = false;
  var _transitionCommitted = false;

  @override
  void dispose() {
    _stopCountdown();
    super.dispose();
  }

  void _startCountdown() {
    if (_countdownActive || _transitionCommitted) {
      return;
    }

    ref.read(runSessionProvider.notifier).reset();
    setState(() {
      _countdownActive = true;
      _transitionCommitted = false;
      _countdownIndex = 0;
    });
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 650), (_) {
      if (!_countdownActive || _transitionCommitted) {
        _stopCountdown();
        return;
      }
      if (_countdownIndex >= _countdownValues.length - 1) {
        _completeCountdown();
        return;
      }
      if (!mounted) {
        _stopCountdown();
        return;
      }
      setState(() => _countdownIndex += 1);
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _cancelCountdown() {
    if (!_countdownActive || _transitionCommitted) {
      return;
    }

    _stopCountdown();
    ref.read(runSessionProvider.notifier).reset();
    if (!mounted) {
      return;
    }
    setState(() {
      _countdownActive = false;
      _countdownIndex = 0;
    });
  }

  void _completeCountdown() {
    if (!_countdownActive || _transitionCommitted) {
      return;
    }

    _transitionCommitted = true;
    _countdownActive = false;
    _stopCountdown();
    if (!mounted) {
      return;
    }
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

    return PopScope(
      canPop: !_countdownActive,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _countdownActive) {
          _cancelCountdown();
        }
      },
      child: AppScaffold(
        padding: EdgeInsets.zero,
        body: Stack(
          children: [
            const Positioned.fill(
              child: AppKyvenVelocityField(intensity: 0.34),
            ),
            SafeArea(
              child: SingleChildScrollView(
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
                        _countdownActive ? 'Starting' : 'Ready',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _countdownActive
                            ? 'Settle in. Your run begins in a breath.'
                            : 'A focused run session starts when you are ready.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppPalette.smoke,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      if (_countdownActive)
                        Semantics(
                          liveRegion: true,
                          label: 'Countdown $countdownValue',
                          child: ExcludeSemantics(
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: reduceMotion
                                    ? AppDurations.instant
                                    : AppDurations.normal,
                                layoutBuilder:
                                    (currentChild, previousChildren) {
                                      return currentChild ??
                                          const SizedBox.shrink();
                                    },
                                child: _CountdownStep(
                                  key: ValueKey(
                                    'run-countdown-$countdownValue',
                                  ),
                                  value: countdownValue,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        const _PreparationGlyph(),
                      const SizedBox(height: AppSpacing.xl),
                      AppProgressRing(
                        progress: _countdownActive
                            ? (0.34 + (_countdownIndex * 0.33)).clamp(0, 1)
                            : 0,
                        size: AppLayout.runRing * 0.84,
                        strokeWidth: AppSpacing.md,
                        glowOpacity: _countdownActive ? 0.72 : 0.48,
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
                      if (_countdownActive)
                        const SizedBox(height: AppLayout.minimumTapTarget)
                      else
                        AppButton(
                          key: const ValueKey('run-begin-session-button'),
                          label: 'Begin Session',
                          onPressed: _startCountdown,
                          icon: Icons.arrow_forward_rounded,
                        ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
            if (_countdownActive)
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.sm,
                child: SafeArea(
                  top: false,
                  child: _CancelCountdownButton(onPressed: _cancelCountdown),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreparationGlyph extends StatelessWidget {
  const _PreparationGlyph();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.directions_run_rounded,
        color: AppPalette.white,
        size: AppLayout.iconContainer,
      ),
    );
  }
}

class _CancelCountdownButton extends StatelessWidget {
  const _CancelCountdownButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Cancel countdown and return to run preparation',
      child: Align(
        alignment: Alignment.center,
        child: TextButton(
          key: const ValueKey('run-countdown-cancel-button'),
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppPalette.smoke,
            minimumSize: const Size(88, AppLayout.minimumTapTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
          ),
          child: const Text('Cancel'),
        ),
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
