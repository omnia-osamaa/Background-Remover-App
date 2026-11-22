import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/plan_entity.dart';

abstract class PlansRepository {
  Future<Either<Failure, List<PlanEntity>>> getPlans();
  Future<Either<Failure, PlanEntity>> getCurrentPlan();
  Future<Either<Failure, PlanEntity>> subscribe(String planId);

  /// How many images were processed today.
  Future<Either<Failure, int>> getTodayUsage();
}
