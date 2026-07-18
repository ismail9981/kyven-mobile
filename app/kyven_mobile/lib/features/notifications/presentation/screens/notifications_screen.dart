import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppFoundationScreen(
      title: 'Notifications',
      description: 'Notification center route.',
    );
  }
}
