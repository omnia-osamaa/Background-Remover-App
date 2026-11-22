import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> forgotPassword(String email);

  Future<Either<Failure, Unit>> logout();

  /// Returns the logged-in user, or null when nobody is logged in.
  Future<Either<Failure, UserEntity?>> getCachedUser();
}
