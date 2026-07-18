import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';

class AuthFooterNote extends StatelessWidget {
  const AuthFooterNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.appColors.secondaryText,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
