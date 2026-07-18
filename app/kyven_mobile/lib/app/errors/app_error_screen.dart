import 'package:flutter/material.dart';

import '../../shared/widgets/widgets.dart';

class AppErrorScreen extends StatelessWidget {
  const AppErrorScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppErrorState(title: 'Something went wrong', message: message),
    );
  }
}
