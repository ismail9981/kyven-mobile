import 'package:equatable/equatable.dart';

class AnalyticsDataPoint extends Equatable {
  const AnalyticsDataPoint({
    required this.date,
    required this.value,
    required this.label,
  });

  final DateTime date;
  final String label;
  final double value;

  @override
  List<Object> get props => [date, value, label];
}

class AnalyticsTrend extends Equatable {
  const AnalyticsTrend({required this.points});

  final List<AnalyticsDataPoint> points;

  double get total => points.fold(0, (sum, point) => sum + point.value);

  double get average => points.isEmpty ? 0 : total / points.length;

  double get min {
    if (points.isEmpty) return 0;
    return points.map((point) => point.value).reduce((a, b) => a < b ? a : b);
  }

  double get max {
    if (points.isEmpty) return 0;
    return points.map((point) => point.value).reduce((a, b) => a > b ? a : b);
  }

  @override
  List<Object> get props => [points];
}
