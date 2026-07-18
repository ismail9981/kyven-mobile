import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/auth_providers.dart';
import '../widgets/auth_screen_layout.dart';

class GuestConfirmationScreen extends ConsumerWidget {
  const GuestConfirmationScreen({super.key});

  Future<void> _continueAsGuest(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).continueAsGuest();
    if (context.mounted) {
      context.goNamed(AppRoute.home.name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return AuthScreenLayout(
      semanticLabel: 'Guest mode confirmation screen',
      eyebrow: 'Guest Mode',
      title: 'Continue without an account?',
      message: 'Start now. Create an account later when you want sync.',
      children: [
        const _GuestModePoint(
          icon: Icons.phone_iphone_rounded,
          title: 'Local progress only',
        ),
        const SizedBox(height: AppSpacing.md),
        const _GuestModePoint(
          icon: Icons.cloud_queue_rounded,
          title: 'Cloud sync later',
        ),
        const SizedBox(height: AppSpacing.md),
        const _GuestModePoint(
          icon: Icons.upgrade_rounded,
          title: 'Can upgrade anytime',
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          key: const ValueKey('guest-continue-button'),
          label: 'Continue as Guest',
          onPressed: isLoading ? null : () => _continueAsGuest(context, ref),
          isLoading: isLoading,
          icon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          key: const ValueKey('guest-create-account-button'),
          label: 'Create Account',
          onPressed: () => context.goNamed(AppRoute.register.name),
          variant: AppButtonVariant.secondary,
        ),
      ],
    );
  }
}

class _GuestModePoint extends StatelessWidget {
  const _GuestModePoint({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
      ],
    );
  }
}
