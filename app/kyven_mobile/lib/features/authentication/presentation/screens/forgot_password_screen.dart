import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/auth_providers.dart';
import '../widgets/auth_screen_layout.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordReset(email: _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return AuthScreenLayout(
      semanticLabel: 'Forgot password screen',
      eyebrow: 'Reset Access',
      title: 'A quiet reset.',
      message: 'Enter your email and KYVEN will prepare the next step.',
      children: [
        if (authState.passwordResetSent) ...[
          const AppStatusBanner(
            key: ValueKey('forgot-password-success'),
            status: AppStatus.success,
            title: 'Check your inbox.',
            message: 'A reset link is ready in this UI-only preview.',
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        AppTextField(
          key: const ValueKey('forgot-email-field'),
          controller: _emailController,
          label: 'Email',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          prefixIcon: const Icon(Icons.mail_rounded),
          onSubmitted: (_) => _sendResetLink(),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          key: const ValueKey('forgot-submit-button'),
          label: 'Send Reset Link',
          onPressed: authState.isLoading ? null : _sendResetLink,
          isLoading: authState.isLoading,
          icon: Icons.arrow_forward_rounded,
        ),
      ],
    );
  }
}
