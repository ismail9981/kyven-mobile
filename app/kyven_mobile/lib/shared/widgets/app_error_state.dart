import 'package:flutter/material.dart';

import '../../core/theme/app_theme_colors.dart';
import 'app_empty_state.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String? actionLabel;
  final String message;
  final VoidCallback? onAction;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: context.appColors.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
