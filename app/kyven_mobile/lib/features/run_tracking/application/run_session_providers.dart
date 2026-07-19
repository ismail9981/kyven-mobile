import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'run_session_notifier.dart';
import 'run_session_state.dart';

final runSessionProvider =
    NotifierProvider<RunSessionNotifier, RunSessionState>(
      RunSessionNotifier.new,
    );
