import '../entities/saved_run.dart';

class SessionNameGenerator {
  const SessionNameGenerator();

  String generate(SavedRun run) {
    final hour = run.completedAt.hour;

    if (run.completedAt.weekday >= DateTime.saturday && run.distanceKm >= 8) {
      return 'Weekend Long Run';
    }
    if (run.distanceKm >= 10) {
      return 'Long Run';
    }
    if (run.averagePace > Duration.zero &&
        run.averagePace <= const Duration(minutes: 5)) {
      return 'Tempo Session';
    }
    if (run.duration >= const Duration(minutes: 45)) {
      return 'Endurance Run';
    }
    if (run.distanceKm <= 3 || run.averagePace >= const Duration(minutes: 7)) {
      return 'Recovery Run';
    }
    if (hour >= 4 && hour < 7) {
      return 'Sunrise Run';
    }
    if (hour >= 7 && hour < 12) {
      return 'Morning Run';
    }
    if (hour >= 17 && hour < 21) {
      return 'Evening Run';
    }
    if (hour >= 21 || hour < 4) {
      return 'Night Run';
    }

    return 'Easy Run';
  }
}
