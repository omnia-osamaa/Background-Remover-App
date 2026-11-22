import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plan_entity.dart';
import '../repositories/plans_repository.dart';

class GetPlans implements UseCase<List<PlanEntity>, NoParams> {
  final PlansRepository repository;
  GetPlans(this.repository);

  @override
  Future<Either<Failure, List<PlanEntity>>> call(NoParams params) =>
      repository.getPlans();
}

class GetCurrentPlan implements UseCase<PlanEntity, NoParams> {
  final PlansRepository repository;
  GetCurrentPlan(this.repository);

  @override
  Future<Either<Failure, PlanEntity>> call(NoParams params) =>
      repository.getCurrentPlan();
}

class SubscribeToPlan implements UseCase<PlanEntity, String> {
  final PlansRepository repository;
  SubscribeToPlan(this.repository);

  @override
  Future<Either<Failure, PlanEntity>> call(String planId) =>
      repository.subscribe(planId);
}

class GetTodayUsage implements UseCase<int, NoParams> {
  final PlansRepository repository;
  GetTodayUsage(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) =>
      repository.getTodayUsage();
}
