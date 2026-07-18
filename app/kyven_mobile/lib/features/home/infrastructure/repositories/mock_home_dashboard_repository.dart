import '../../domain/entities/home_dashboard.dart';
import '../../domain/repositories/home_dashboard_repository.dart';

class MockHomeDashboardRepository implements HomeDashboardRepository {
  const MockHomeDashboardRepository();

  @override
  HomeDashboard getDashboard() {
    return const HomeDashboard(
      runnerName: 'Alex',
      greeting: 'Good Morning,',
      motivation: 'Today is built for easy momentum.',
      weeklyDistance: 18.4,
      weeklyGoal: 25,
      currentStreak: 6,
      weather: '28°C · Clear preview',
      todayMetrics: [
        ActivityMetric(
          label: 'Distance',
          value: '3.8 km',
          semanticValue: '3.8 kilometers',
        ),
        ActivityMetric(
          label: 'Calories',
          value: '312',
          semanticValue: '312 calories',
        ),
        ActivityMetric(
          label: 'Time',
          value: '24m',
          semanticValue: '24 minutes',
        ),
        ActivityMetric(
          label: 'Steps',
          value: '4.9k',
          semanticValue: '4,900 steps',
        ),
      ],
      weeklyProgress: [
        WeeklyProgressDay(label: 'M', distance: 3.2, goal: 4),
        WeeklyProgressDay(label: 'T', distance: 0, goal: 4),
        WeeklyProgressDay(label: 'W', distance: 5.1, goal: 4),
        WeeklyProgressDay(label: 'T', distance: 2.4, goal: 4),
        WeeklyProgressDay(label: 'F', distance: 3.8, goal: 4),
        WeeklyProgressDay(label: 'S', distance: 1.6, goal: 4),
        WeeklyProgressDay(label: 'S', distance: 2.3, goal: 4),
      ],
      trainingPlan: TrainingPlanPreview(
        title: 'Easy Run',
        description: 'Low intensity rhythm builder',
        duration: '32 min',
        intensity: 'Comfortable',
      ),
      challenges: [
        ChallengePreview(
          title: 'Run 20 km this week',
          description: '18.4 km complete',
          progress: 0.92,
        ),
        ChallengePreview(
          title: 'Three calm starts',
          description: '2 of 3 complete',
          progress: 0.66,
        ),
        ChallengePreview(
          title: 'Weekend motion',
          description: 'One run remaining',
          progress: 0.42,
        ),
      ],
      recentActivities: [
        RecentActivity(
          title: 'Waterfront Flow',
          date: 'Yesterday',
          distance: '5.2 km',
          duration: '29:38',
          pace: '5:42/km',
        ),
        RecentActivity(
          title: 'Sunrise Reset',
          date: 'Wed',
          distance: '4.1 km',
          duration: '24:10',
          pace: '5:53/km',
        ),
        RecentActivity(
          title: 'Evening Shakeout',
          date: 'Mon',
          distance: '3.2 km',
          duration: '19:44',
          pace: '6:10/km',
        ),
      ],
    );
  }
}
