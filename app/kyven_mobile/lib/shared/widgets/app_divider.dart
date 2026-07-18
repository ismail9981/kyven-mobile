import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_colors.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({this.height = AppSpacing.xl, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: 1,
      color: context.appColors.divider,
    );
  }
}
