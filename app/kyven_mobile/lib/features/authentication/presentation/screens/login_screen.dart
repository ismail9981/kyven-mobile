import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/auth_providers.dart';
import '../widgets/auth_screen_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    await ref
        .read(authNotifierProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (mounted) {
      context.goNamed(AppRoute.home.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return AuthScreenLayout(
      semanticLabel: 'Sign in screen',
      eyebrow: 'Welcome Back',
      title: 'Return to your rhythm.',
      message: 'Sign in when you are ready to keep your Motion Path moving.',
      children: [
        AppTextField(
          key: const ValueKey('login-email-field'),
          controller: _emailController,
          label: 'Email',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          prefixIcon: const Icon(Icons.mail_rounded),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          key: const ValueKey('login-password-field'),
          controller: _passwordController,
          label: 'Password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          prefixIcon: const Icon(Icons.lock_rounded),
          onSubmitted: (_) => _signIn(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            key: const ValueKey('forgot-password-link'),
            label: 'Forgot Password',
            onPressed: () => context.goNamed(AppRoute.forgotPassword.name),
            variant: AppButtonVariant.ghost,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          key: const ValueKey('login-submit-button'),
          label: 'Sign In',
          onPressed: isLoading ? null : _signIn,
          isLoading: isLoading,
          icon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          key: const ValueKey('login-create-account-button'),
          label: 'Create Account',
          onPressed: () => context.goNamed(AppRoute.register.name),
          variant: AppButtonVariant.secondary,
        ),
      ],
    );
  }
}
