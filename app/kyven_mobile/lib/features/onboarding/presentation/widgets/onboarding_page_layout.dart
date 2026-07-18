import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';

class OnboardingPageLayout extends StatelessWidget {
  const OnboardingPageLayout({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.semanticLabel,
    this.hero,
    this.children = const [],
    super.key,
  });

  final String body;
  final List<Widget> children;
  final String eyebrow;
  final Widget? hero;
  final String semanticLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Semantics(
      container: true,
      label: semanticLabel,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: AppResponsiveContent(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: colors.primaryText,
                  height: 0.98,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.secondaryText,
                  height: 1.42,
                ),
              ),
              if (hero case final hero?) ...[
                const SizedBox(height: AppSpacing.xxxl),
                Center(child: hero),
              ],
              if (children.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxxl),
                ...children.expand(
                  (child) => [child, const SizedBox(height: AppSpacing.md)],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
