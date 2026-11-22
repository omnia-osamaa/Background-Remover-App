import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/processed_image.dart';
import '../repositories/history_repository.dart';

class GetHistory implements UseCase<List<ProcessedImage>, NoParams> {
  final HistoryRepository repository;
  GetHistory(this.repository);

  @override
  Future<Either<Failure, List<ProcessedImage>>> call(NoParams params) {
    return repository.getHistory();
  }
}
