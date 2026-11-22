import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/repositories/plans_repository.dart';
import '../datasources/plans_local_datasource.dart';

class PlansRepositoryImpl implements PlansRepository {
  final PlansLocalDataSource localDataSource;
  PlansRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<PlanEntity>>> getPlans() async {
    try {
      return Right(localDataSource.getPlans());
    } catch (_) {
      return const Left(CacheFailure('Could not load plans'));
    }
  }

  @override
  Future<Either<Failure, PlanEntity>> getCurrentPlan() async {
    try {
      return Right(localDataSource.getCurrentPlan());
    } catch (_) {
      return const Left(CacheFailure('Could not load your plan'));
    }
  }

  @override
  Future<Either<Failure, PlanEntity>> subscribe(String planId) async {
    try {
      // Demo checkout: simulates a payment request.
      await Future.delayed(const Duration(milliseconds: 1500));
      await localDataSource.setCurrentPlan(planId);
      return Right(localDataSource.getCurrentPlan());
    } catch (_) {
      return const Left(ServerFailure('Payment failed. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, int>> getTodayUsage() async {
    try {
      return Right(localDataSource.getTodayUsage());
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
