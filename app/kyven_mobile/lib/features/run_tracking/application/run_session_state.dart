import 'package:equatable/equatable.dart';

import '../domain/entities/run_metrics.dart';
import '../domain/entities/run_session.dart';
import '../domain/entities/run_summary.dart';

class RunSessionState extends Equatable {
  const RunSessionState({
    this.status = RunSessionStatus.idle,
    this.session,
    this.summary,
  });

  final RunSession? session;
  final RunSessionStatus status;
  final RunSummary? summary;

  RunMetrics get metrics => session?.metrics ?? RunMetrics.zero();

  bool get hasActiveSession =>
      status == RunSessionStatus.running ||
      status == RunSessionStatus.paused ||
      status == RunSessionStatus.finishing;

  RunSessionState copyWith({
    RunSessionStatus? status,
    RunSession? session,
    RunSummary? summary,
    bool clearSession = false,
    bool clearSummary = false,
  }) {
    return RunSessionState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      summary: clearSummary ? null : summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [status, session, summary];
}
