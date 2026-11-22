import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, bool>> isOnboardingSeen();
  Future<Either<Failure, Unit>> setOnboardingSeen();
}
