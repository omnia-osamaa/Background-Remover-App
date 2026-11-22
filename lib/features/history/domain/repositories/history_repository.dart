import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/processed_image.dart';

abstract class HistoryRepository {
  /// Newest first.
  Future<Either<Failure, List<ProcessedImage>>> getHistory();
  Future<Either<Failure, Unit>> deleteImage(String id);
}
