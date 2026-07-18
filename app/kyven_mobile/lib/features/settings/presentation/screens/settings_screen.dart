import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppFoundationScreen(
      title: 'Settings',
      description: 'Application settings route.',
    );
  }
}
