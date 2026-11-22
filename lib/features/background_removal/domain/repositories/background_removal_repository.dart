import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../history/domain/entities/processed_image.dart';

abstract class BackgroundRemovalRepository {
  /// Removes the background of the image at [imagePath] and saves the result
  /// to the user's history.
  Future<Either<Failure, ProcessedImage>> removeBackground(String imagePath);
}
