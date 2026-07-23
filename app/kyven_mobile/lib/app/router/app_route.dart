enum AppRoute {
  splash(name: 'splash', path: '/splash'),
  onboarding(name: 'onboarding', path: '/onboarding'),
  authentication(name: 'authentication', path: '/auth'),
  login(name: 'login', path: '/login'),
  register(name: 'register', path: '/register'),
  forgotPassword(name: 'forgot-password', path: '/forgot-password'),
  guest(name: 'guest', path: '/guest'),
  home(name: 'home', path: '/'),
  training(name: 'training', path: '/training'),
  trainingDetail(name: 'training-detail', path: '/training/:planId'),
  run(name: 'run', path: '/run'),
  runLive(name: 'run-live', path: '/run/live'),
  runSummary(name: 'run-summary', path: '/run/summary'),
  runHistory(name: 'run-history', path: '/history'),
  runDetail(name: 'run-detail', path: '/history/:runId'),
  challenges(name: 'challenges', path: '/challenges'),
  profile(name: 'profile', path: '/profile'),
  activities(name: 'activities', path: '/activities'),
  goals(name: 'goals', path: '/goals'),
  goalCreate(name: 'goal-create', path: '/goals/create'),
  goalDetail(name: 'goal-detail', path: '/goals/:goalId'),
  goalEdit(name: 'goal-edit', path: '/goals/:goalId/edit'),
  notifications(name: 'notifications', path: '/notifications'),
  settings(name: 'settings', path: '/settings'),
  designSystem(name: 'design-system', path: '/design-system');

  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;
}
