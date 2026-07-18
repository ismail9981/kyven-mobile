import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppFoundationScreen(
      title: 'Activities',
      description: 'Activity history route.',
    );
  }
}
