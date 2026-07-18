import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppFoundationScreen(
      title: 'Authentication',
      description: 'Account entry route.',
    );
  }
}
