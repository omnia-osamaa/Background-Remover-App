import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;
  OnboardingRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, bool>> isOnboardingSeen() async {
    try {
      return Right(localDataSource.isSeen());
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> setOnboardingSeen() async {
    try {
      await localDataSource.setSeen();
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
