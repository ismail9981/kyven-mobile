import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import 'design_system_section.dart';

class ControlsSection extends StatelessWidget {
  const ControlsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DesignSystemSection(
          title: 'Buttons and states',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                label: 'Primary action',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Secondary action',
                variant: AppButtonVariant.secondary,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Ghost action',
                variant: AppButtonVariant.ghost,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Destructive action',
                variant: AppButtonVariant.destructive,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              const AppButton(label: 'Disabled action', onPressed: null),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Loading action',
                isLoading: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const DesignSystemSection(
          title: 'Text fields and states',
          child: Column(
            children: [
              AppTextField(
                label: 'Email address',
                hint: 'runner@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Password',
                hint: 'Enter a secure password',
                obscureText: true,
                suffixIcon: Icon(Icons.visibility_outlined),
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Field with error',
                errorText: 'Please review this value',
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(label: 'Disabled field', enabled: false),
            ],
          ),
        ),
      ],
    );
  }
}
