import '../../domain/entities/home_dashboard.dart';
import '../../domain/repositories/home_dashboard_repository.dart';

class MockHomeDashboardRepository implements HomeDashboardRepository {
  const MockHomeDashboardRepository();

  @override
  HomeDashboard getDashboard() {
    return const HomeDashboard(
      runnerName: 'Runner',
      greeting: '',
      motivation: '',
      weeklyDistance: 0,
      weeklyGoal: 20,
      currentStreak: 0,
      weather: '',
      todayMetrics: [],
      weeklyProgress: [
        WeeklyProgressDay(label: 'M', distance: 0, goal: 1),
        WeeklyProgressDay(label: 'T', distance: 0, goal: 1),
        WeeklyProgressDay(label: 'W', distance: 0, goal: 1),
        WeeklyProgressDay(label: 'T', distance: 0, goal: 1),
        WeeklyProgressDay(label: 'F', distance: 0, goal: 1),
        WeeklyProgressDay(label: 'S', distance: 0, goal: 1),
        WeeklyProgressDay(label: 'S', distance: 0, goal: 1),
      ],
      trainingPlan: TrainingPlanPreview(
        title: 'Next Movement',
        description: 'Choose a calm effort when you are ready',
        duration: 'Open',
        intensity: 'Self-guided',
      ),
      challenges: [
        ChallengePreview(
          title: 'Build your Motion Path',
          description: 'Complete a run to begin',
          progress: 0,
        ),
      ],
      recentActivities: [],
    );
  }
}
