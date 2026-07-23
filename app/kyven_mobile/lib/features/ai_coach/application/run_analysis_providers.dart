import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services/run_analysis_engine.dart';

final runAnalysisEngineProvider = Provider<RunAnalysisEngine>(
  (ref) => const RuleBasedRunAnalysisEngine(),
);
