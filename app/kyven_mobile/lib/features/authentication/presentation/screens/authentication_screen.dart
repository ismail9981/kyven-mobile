import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_footer_note.dart';
import '../widgets/auth_screen_layout.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      semanticLabel: 'Authentication hub screen',
      eyebrow: 'Account',
      title: 'Keep your progress close.',
      message: 'Create a KYVEN account, sign in, or begin quietly as a guest.',
      hero: Semantics(
        label: 'KYVEN account Motion Path ring',
        image: true,
        child: AppProgressRing(
          progress: 0.86,
          size: 156,
          strokeWidth: AppSpacing.md,
          child: const AppKyvenMark(size: 48, color: AppPalette.white),
        ),
      ),
      children: [
        AppButton(
          key: const ValueKey('auth-create-account-button'),
          label: 'Create Account',
          onPressed: () => context.goNamed(AppRoute.register.name),
          icon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          key: const ValueKey('auth-sign-in-button'),
          label: 'Sign In',
          onPressed: () => context.goNamed(AppRoute.login.name),
          variant: AppButtonVariant.secondary,
        ),
        const AppDivider(height: AppSpacing.xxxl),
        AppButton(
          key: const ValueKey('auth-guest-button'),
          label: 'Continue as Guest',
          onPressed: () => context.goNamed(AppRoute.guest.name),
          variant: AppButtonVariant.ghost,
        ),
        const AuthFooterNote('You can always create an account later.'),
      ],
    );
  }
}
