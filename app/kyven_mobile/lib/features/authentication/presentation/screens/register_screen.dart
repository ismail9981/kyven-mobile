import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/auth_providers.dart';
import '../widgets/auth_screen_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    await ref
        .read(authNotifierProvider.notifier)
        .register(
          name: _nameController.text,
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
      semanticLabel: 'Create account screen',
      eyebrow: 'Create Account',
      title: 'Start with a clean slate.',
      message: 'Create your KYVEN account and carry your progress forward.',
      children: [
        AppTextField(
          key: const ValueKey('register-name-field'),
          controller: _nameController,
          label: 'Name',
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          prefixIcon: const Icon(Icons.person_rounded),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          key: const ValueKey('register-email-field'),
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          prefixIcon: const Icon(Icons.mail_rounded),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          key: const ValueKey('register-password-field'),
          controller: _passwordController,
          label: 'Password',
          obscureText: true,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          prefixIcon: const Icon(Icons.lock_rounded),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          key: const ValueKey('register-confirm-password-field'),
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          prefixIcon: const Icon(Icons.verified_user_rounded),
          onSubmitted: (_) => _register(),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          key: const ValueKey('register-submit-button'),
          label: 'Create Account',
          onPressed: isLoading ? null : _register,
          isLoading: isLoading,
          icon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          key: const ValueKey('register-login-button'),
          label: 'Already have an account?',
          onPressed: () => context.goNamed(AppRoute.login.name),
          variant: AppButtonVariant.ghost,
        ),
      ],
    );
  }
}
