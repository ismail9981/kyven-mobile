import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kyven_mobile/app/router/app_route.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/goals/domain/entities/personal_goal.dart';
import 'package:kyven_mobile/features/goals/presentation/screens/goals_screen.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/run_summary_screen.dart';

import '../fakes/fake_goals_repository.dart';
import '../fakes/fake_run_history_repository.dart';
import '../helpers/test_app.dart';

void main() {
  final now = DateTime(2026, 7, 22, 12);

  Future<void> openGoals(
    WidgetTester tester, {
    FakeGoalsRepository? goalsRepository,
    FakeRunHistoryRepository? runRepository,
  }) async {
    await tester.pumpWidget(
      testApp(
        goalsRepository: goalsRepository,
        repository: runRepository,
        goalsNow: now,
      ),
    );
    await tester.pump();
    tester.element(find.byType(HomeScreen)).goNamed(AppRoute.goals.name);
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(AppDurations.fast);
    await tester.tap(finder);
  }

  testWidgets('empty Goals screen renders', (tester) async {
    await openGoals(tester);

    expect(find.byType(GoalsScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('goals-empty-state')), findsOneWidget);
    expect(find.text('No goals yet'), findsOneWidget);
  });

  testWidgets('active goal card displays progress and on-track status', (
    tester,
  ) async {
    await openGoals(
      tester,
      goalsRepository: FakeGoalsRepository([personalGoalFixture()]),
      runRepository: FakeRunHistoryRepository([
        savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 6),
      ]),
    );

    expect(find.byKey(const ValueKey('goal-card-goal-1')), findsOneWidget);
    expect(find.text('6.0 km / 10.0 km'), findsOneWidget);
    expect(find.text('ON TRACK'), findsOneWidget);
  });

  testWidgets('behind schedule and completed sections render', (tester) async {
    await openGoals(
      tester,
      goalsRepository: FakeGoalsRepository([
        personalGoalFixture(id: 'behind', targetValue: 100),
        personalGoalFixture(
          id: 'done',
          title: 'Finished',
          status: GoalStatus.completed,
          completedAt: DateTime(2026, 7, 21),
        ),
      ]),
      runRepository: FakeRunHistoryRepository([
        savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 1),
      ]),
    );

    expect(find.text('BEHIND PACE'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Finished'),
      360,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(AppDurations.slow);
    expect(find.text('Completed'), findsWidgets);
  });

  testWidgets('create form validates and creates a goal', (tester) async {
    final goalsRepository = FakeGoalsRepository();
    await openGoals(tester, goalsRepository: goalsRepository);

    await tester.tap(find.byKey(const ValueKey('create-goal-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    await tester.tap(find.byKey(const ValueKey('save-goal-button')));
    await tester.pump();
    expect(find.text('Title cannot be blank.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('goal-title-field')),
      'Run 20K',
    );
    await tester.enterText(
      find.byKey(const ValueKey('goal-target-field')),
      '20',
    );
    await tester.tap(find.byKey(const ValueKey('save-goal-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect((await goalsRepository.loadGoals()).single.title, 'Run 20K');
    expect(find.byType(GoalsScreen), findsOneWidget);
  });

  testWidgets('custom date validation rejects missing end date', (
    tester,
  ) async {
    await openGoals(tester);

    await tester.tap(find.byKey(const ValueKey('create-goal-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.enterText(
      find.byKey(const ValueKey('goal-title-field')),
      'Custom',
    );
    await tester.enterText(
      find.byKey(const ValueKey('goal-target-field')),
      '5',
    );
    await tester.tap(find.byKey(const ValueKey(GoalPeriodType.custom)));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('save-goal-button')));
    await tester.pump();

    expect(find.text('Choose an end date.'), findsOneWidget);
  });

  testWidgets('edit active goal and archive from details', (tester) async {
    final goalsRepository = FakeGoalsRepository([personalGoalFixture()]);
    await openGoals(tester, goalsRepository: goalsRepository);

    await tester.tap(find.byKey(const ValueKey('goal-card-goal-1')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    expect(find.text('Goal Details'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('edit-goal-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.enterText(
      find.byKey(const ValueKey('goal-title-field')),
      'Updated',
    );
    await tester.tap(find.byKey(const ValueKey('save-goal-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect((await goalsRepository.loadGoals()).single.title, 'Updated');

    await tester.tap(find.byKey(const ValueKey('goal-card-goal-1')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('archive-goal-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(
      (await goalsRepository.loadGoals()).single.status,
      GoalStatus.archived,
    );
  });

  testWidgets('saved run changes update goal progress', (tester) async {
    final goalsRepository = FakeGoalsRepository([personalGoalFixture()]);
    final runRepository = FakeRunHistoryRepository();
    await openGoals(
      tester,
      goalsRepository: goalsRepository,
      runRepository: runRepository,
    );

    expect(find.text('0.0 km / 10.0 km'), findsOneWidget);
    await runRepository.saveRun(
      savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 5),
    );
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.text('5.0 km / 10.0 km'), findsOneWidget);
  });

  testWidgets('goal completion feedback appears on Run Summary once', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final goal = personalGoalFixture(
      targetValue: 1,
      type: GoalType.runCount,
      unit: GoalUnit.runs,
    );
    await tester.pumpWidget(
      testApp(goalsRepository: FakeGoalsRepository([goal]), goalsNow: now),
    );
    await tester.pump();
    await tester.pump(AppDurations.slow);

    await tester.tap(find.byKey(const ValueKey('home-start-run-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(AppDurations.slow);
    await tapVisible(tester, find.byKey(const ValueKey('run-finish-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-finish-confirm-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(RunSummaryScreen), findsOneWidget);
    expect(
      find.byKey(const ValueKey('run-summary-goal-completion-card')),
      findsOneWidget,
    );
  });
}
