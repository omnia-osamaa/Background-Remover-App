import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/usecases/plans_usecases.dart';

enum PlanStatus { initial, loading, loaded, subscribing, subscribed, failure }

class PlanState extends Equatable {
  final PlanStatus status;
  final List<PlanEntity> plans;
  final PlanEntity? currentPlan;
  final int usedToday;
  final String? errorMessage;

  const PlanState({
    this.status = PlanStatus.initial,
    this.plans = const [],
    this.currentPlan,
    this.usedToday = 0,
    this.errorMessage,
  });

  PlanState copyWith({
    PlanStatus? status,
    List<PlanEntity>? plans,
    PlanEntity? currentPlan,
    int? usedToday,
    String? errorMessage,
  }) {
    return PlanState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      currentPlan: currentPlan ?? this.currentPlan,
      usedToday: usedToday ?? this.usedToday,
      errorMessage: errorMessage,
    );
  }

  /// Images left today, or null when unlimited.
  int? get remainingToday {
    final plan = currentPlan;
    if (plan == null || plan.hasUnlimitedImages) return null;
    final left = plan.dailyLimit - usedToday;
    return left < 0 ? 0 : left;
  }

  @override
  List<Object?> get props =>
      [status, plans, currentPlan, usedToday, errorMessage];
}

class PlanCubit extends Cubit<PlanState> {
  final GetPlans getPlans;
  final GetCurrentPlan getCurrentPlan;
  final GetTodayUsage getTodayUsage;
  final SubscribeToPlan subscribeToPlan;

  PlanCubit({
    required this.getPlans,
    required this.getCurrentPlan,
    required this.getTodayUsage,
    required this.subscribeToPlan,
  }) : super(const PlanState());

  Future<void> load() async {
    if (state.status == PlanStatus.initial) {
      emit(state.copyWith(status: PlanStatus.loading));
    }

    final plans = await getPlans(const NoParams());
    final current = await getCurrentPlan(const NoParams());
    final usage = await getTodayUsage(const NoParams());
    if (isClosed) return;

    emit(state.copyWith(
      status: PlanStatus.loaded,
      plans: plans.fold((_) => state.plans, (v) => v),
      currentPlan: current.fold((_) => state.currentPlan, (v) => v),
      usedToday: usage.fold((_) => state.usedToday, (v) => v),
    ));
  }

  Future<void> subscribe(String planId) async {
    emit(state.copyWith(status: PlanStatus.subscribing));
    final result = await subscribeToPlan(planId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: PlanStatus.failure,
        errorMessage: failure.message,
      )),
      (plan) => emit(state.copyWith(
        status: PlanStatus.subscribed,
        currentPlan: plan,
      )),
    );
  }
}
