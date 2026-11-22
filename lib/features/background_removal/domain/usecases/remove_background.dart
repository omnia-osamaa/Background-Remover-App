import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../history/domain/entities/processed_image.dart';
import '../repositories/background_removal_repository.dart';

class RemoveBackground implements UseCase<ProcessedImage, String> {
  final BackgroundRemovalRepository repository;
  RemoveBackground(this.repository);

  @override
  Future<Either<Failure, ProcessedImage>> call(String imagePath) {
    return repository.removeBackground(imagePath);
  }
}
