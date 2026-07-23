import 'package:equatable/equatable.dart';

enum AnalyticsPeriodType { week, month, allTime }

class AnalyticsPeriod extends Equatable {
  const AnalyticsPeriod({
    required this.start,
    required this.end,
    required this.type,
  });

  final DateTime start;
  final DateTime end;
  final AnalyticsPeriodType type;

  bool contains(DateTime value) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  @override
  List<Object> get props => [start, end, type];
}
