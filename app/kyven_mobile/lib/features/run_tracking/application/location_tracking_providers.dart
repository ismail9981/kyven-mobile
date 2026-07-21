import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/run_session.dart';
import 'run_location_controller.dart';
import 'run_location_state.dart';
import 'run_session_providers.dart';

final runLocationProvider =
    NotifierProvider<RunLocationController, RunLocationState>(
      RunLocationController.new,
    );

final runLocationLifecycleProvider = Provider<void>((ref) {
  ref.listen(runSessionProvider.select((state) => state.status), (
    previous,
    next,
  ) {
    if (next == RunSessionStatus.idle || next == RunSessionStatus.completed) {
      unawaited(ref.read(runLocationProvider.notifier).stopTracking());
    }
  });
});
