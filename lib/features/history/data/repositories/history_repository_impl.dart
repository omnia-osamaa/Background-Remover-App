import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/processed_image.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;
  HistoryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<ProcessedImage>>> getHistory() async {
    try {
      return Right(localDataSource.getAll());
    } catch (_) {
      return const Left(CacheFailure('Could not load your images'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteImage(String id) async {
    try {
      await localDataSource.remove(id);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Could not delete the image'));
    }
  }
}
