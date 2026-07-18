import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppFoundationScreen(
      title: 'Onboarding',
      description: 'First-run education route.',
    );
  }
}
