import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/goals_providers.dart';
import '../../domain/entities/goal_evaluation_result.dart';
import '../../domain/entities/personal_goal.dart';
import '../../domain/services/goal_period_service.dart';
import '../widgets/goal_formatters.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({this.goalId, super.key});

  final String? goalId;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _title = TextEditingController();
  final _target = TextEditingController();
  GoalType _type = GoalType.distance;
  GoalPeriodType _periodType = GoalPeriodType.weekly;
  DateTime _start = DateTime.now();
  DateTime? _end;
  String? _error;
  var _initialized = false;
  var _saving = false;

  bool get _isEditing => widget.goalId != null;

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    super.dispose();
  }

  void _initialize(PersonalGoal? goal, DateTime now) {
    if (_initialized) return;
    _initialized = true;
    _start = now;
    if (goal == null) return;
    _title.text = goal.title;
    _target.text = _targetText(goal.targetValue);
    _type = goal.type;
    _periodType = goal.periodType;
    _start = goal.startAt;
    _end = goal.periodType == GoalPeriodType.custom
        ? goal.endAt.subtract(const Duration(days: 1))
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(goalsNowProvider);
    final selectedGoal = widget.goalId == null
        ? const AsyncValue<GoalEvaluationResult?>.data(null)
        : ref.watch(selectedGoalProvider(widget.goalId!));

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: AppResponsiveContent(
        child: selectedGoal.when(
          data: (result) {
            _initialize(result?.goal, now);
            final canEdit = result?.goal.isEditable ?? true;
            if (!canEdit) {
              return const AppEmptyState(
                title: 'Goal is read-only',
                message:
                    'Completed and expired goals can be archived from details.',
              );
            }
            return _FormContent(
              isEditing: _isEditing,
              title: _title,
              target: _target,
              type: _type,
              periodType: _periodType,
              start: _start,
              end: _end,
              error: _error,
              saving: _saving,
              onTypeChanged: (value) => setState(() => _type = value),
              onPeriodChanged: (value) => setState(() => _periodType = value),
              onPickStart: () => _pickDate(isStart: true),
              onPickEnd: () => _pickDate(isStart: false),
              onSubmit: () => _submit(result?.goal),
            );
          },
          error: (_, _) => const AppErrorState(
            title: 'Goal unavailable',
            message: 'KYVEN could not prepare this goal form.',
          ),
          loading: () => const Center(child: AppLoadingIndicator()),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _start : _end ?? _start;
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (date == null || !mounted) return;
    setState(() {
      if (isStart) {
        _start = date;
        if (_end != null && _end!.isBefore(date)) {
          _end = date;
        }
      } else {
        _end = date;
      }
    });
  }

  Future<void> _submit(PersonalGoal? existing) async {
    if (_saving) return;
    final now = ref.read(goalsNowProvider);
    final title = _title.text.trim();
    final target = double.tryParse(_target.text.trim());
    final periodService = ref.read(goalPeriodServiceProvider);

    if (title.isEmpty) {
      setState(() => _error = 'Title cannot be blank.');
      return;
    }
    if (target == null || !target.isFinite || target <= 0) {
      setState(() => _error = 'Target must be greater than zero.');
      return;
    }

    late GoalPeriod period;
    try {
      period = periodService.resolve(
        type: _periodType,
        selectedStart: _start,
        selectedEnd: _end,
      );
    } on GoalPeriodException catch (error) {
      setState(() => _error = error.message);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final unit = _unitFor(_type);
    final goal = (existing ?? _newGoal(now)).copyWith(
      title: title,
      type: _type,
      targetValue: target,
      periodType: _periodType,
      startAt: period.startAt,
      endAt: period.endAt,
      updatedAt: now,
      unit: unit,
      status: GoalStatus.active,
      clearCompletedAt: existing != null,
    );

    try {
      final coordinator = ref.read(goalsCoordinatorProvider);
      if (existing == null) {
        await coordinator.createGoal(goal);
      } else {
        await coordinator.updateGoal(goal);
      }
      if (mounted) {
        context.goNamed(AppRoute.goals.name);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  PersonalGoal _newGoal(DateTime now) {
    return PersonalGoal(
      id: ref.read(goalIdGeneratorProvider).generate(now),
      title: '',
      type: _type,
      targetValue: 1,
      periodType: _periodType,
      startAt: now,
      endAt: now.add(const Duration(days: 7)),
      createdAt: now,
      updatedAt: now,
      status: GoalStatus.active,
      unit: _unitFor(_type),
    );
  }

  GoalUnit _unitFor(GoalType type) {
    return switch (type) {
      GoalType.distance => GoalUnit.kilometers,
      GoalType.runCount => GoalUnit.runs,
      GoalType.duration => GoalUnit.minutes,
      GoalType.calories => GoalUnit.calories,
    };
  }

  String _targetText(double value) {
    if (value == value.roundToDouble()) {
      return '${value.round()}';
    }
    return '$value';
  }
}

class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.isEditing,
    required this.title,
    required this.target,
    required this.type,
    required this.periodType,
    required this.start,
    required this.end,
    required this.error,
    required this.saving,
    required this.onTypeChanged,
    required this.onPeriodChanged,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onSubmit,
  });

  final DateTime? end;
  final String? error;
  final bool isEditing;
  final ValueChanged<GoalPeriodType> onPeriodChanged;
  final VoidCallback onPickEnd;
  final VoidCallback onPickStart;
  final VoidCallback onSubmit;
  final ValueChanged<GoalType> onTypeChanged;
  final GoalPeriodType periodType;
  final bool saving;
  final DateTime start;
  final TextEditingController target;
  final TextEditingController title;
  final GoalType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      key: const PageStorageKey('goal-form-scroll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Edit Goal' : 'Create Goal',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            key: const ValueKey('goal-title-field'),
            controller: title,
            label: 'Goal title',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppChoiceSelector<GoalType>(
            options: const [
              AppChoiceOption(value: GoalType.distance, label: 'Distance'),
              AppChoiceOption(value: GoalType.runCount, label: 'Runs'),
              AppChoiceOption(value: GoalType.duration, label: 'Duration'),
              AppChoiceOption(value: GoalType.calories, label: 'Calories'),
            ],
            selected: type,
            onSelected: onTypeChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('goal-target-field'),
            controller: target,
            label: 'Target (${GoalFormatters.unitLabel(_unitFor(type))})',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppChoiceSelector<GoalPeriodType>(
            options: const [
              AppChoiceOption(value: GoalPeriodType.weekly, label: 'Weekly'),
              AppChoiceOption(value: GoalPeriodType.monthly, label: 'Monthly'),
              AppChoiceOption(value: GoalPeriodType.custom, label: 'Custom'),
            ],
            selected: periodType,
            onSelected: onPeriodChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            key: const ValueKey('goal-start-date-button'),
            label: 'Start: ${GoalFormatters.date(start)}',
            onPressed: onPickStart,
            variant: AppButtonVariant.secondary,
          ),
          if (periodType == GoalPeriodType.custom) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              key: const ValueKey('goal-end-date-button'),
              label:
                  'End: ${end == null ? 'Choose date' : GoalFormatters.date(end!)}',
              onPressed: onPickEnd,
              variant: AppButtonVariant.secondary,
            ),
          ],
          if (error case final message?) ...[
            const SizedBox(height: AppSpacing.lg),
            AppStatusBanner(
              status: AppStatus.error,
              title: 'Check goal details',
              message: message,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            key: const ValueKey('save-goal-button'),
            label: isEditing ? 'Save Goal' : 'Create Goal',
            onPressed: saving ? null : onSubmit,
            isLoading: saving,
          ),
        ],
      ),
    );
  }

  GoalUnit _unitFor(GoalType type) {
    return switch (type) {
      GoalType.distance => GoalUnit.kilometers,
      GoalType.runCount => GoalUnit.runs,
      GoalType.duration => GoalUnit.minutes,
      GoalType.calories => GoalUnit.calories,
    };
  }
}
