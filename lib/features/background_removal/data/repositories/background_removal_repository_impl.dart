import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/image_service.dart';
import '../../../history/data/datasources/history_local_datasource.dart';
import '../../../history/data/models/processed_image_model.dart';
import '../../../history/domain/entities/processed_image.dart';
import '../../../packages/data/datasources/plans_local_datasource.dart';
import '../../domain/repositories/background_removal_repository.dart';
import '../datasources/background_removal_remote_datasource.dart';

class BackgroundRemovalRepositoryImpl implements BackgroundRemovalRepository {
  final BackgroundRemovalRemoteDataSource remoteDataSource;
  final HistoryLocalDataSource historyDataSource;
  final PlansLocalDataSource plansDataSource;
  final ImageService imageService;
  final NetworkInfo networkInfo;

  BackgroundRemovalRepositoryImpl({
    required this.remoteDataSource,
    required this.historyDataSource,
    required this.plansDataSource,
    required this.imageService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProcessedImage>> removeBackground(
    String imagePath,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    // Enforce the daily limit of the current plan.
    final plan = plansDataSource.getCurrentPlan();
    if (!plan.hasUnlimitedImages &&
        plansDataSource.getTodayUsage() >= plan.dailyLimit) {
      return const Left(LimitReachedFailure());
    }

    try {
      final resultPath = await remoteDataSource.removeBackground(imagePath);
      final originalPath = await imageService.persistFile(imagePath);

      final item = ProcessedImageModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        originalPath: originalPath,
        resultPath: resultPath,
        createdAt: DateTime.now(),
      );

      await historyDataSource.add(item);
      await plansDataSource.incrementUsage();
      return Right(item);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('We could not process this image.'));
    }
  }
}
