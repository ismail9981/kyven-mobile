import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';

class AuthScreenLayout extends StatelessWidget {
  const AuthScreenLayout({
    required this.eyebrow,
    required this.title,
    required this.message,
    required this.children,
    this.hero,
    this.semanticLabel,
    super.key,
  });

  final List<Widget> children;
  final String eyebrow;
  final Widget? hero;
  final String message;
  final String? semanticLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: Stack(
        children: [
          const Positioned.fill(child: AppKyvenVelocityField(intensity: 0.42)),
          Semantics(
            container: true,
            label: semanticLabel ?? title,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: AppResponsiveContent(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.xxxl,
                  AppSpacing.page,
                  AppSpacing.xxxl,
                ),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        title,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: colors.primaryText,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        message,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.secondaryText,
                          height: 1.42,
                        ),
                      ),
                      if (hero case final hero?) ...[
                        const SizedBox(height: AppSpacing.xxxl),
                        Center(child: hero),
                      ],
                      const SizedBox(height: AppSpacing.xxxl),
                      AppCard(
                        variant: AppCardVariant.elevated,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
