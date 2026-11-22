import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

class DeleteHistoryItem implements UseCase<Unit, String> {
  final HistoryRepository repository;
  DeleteHistoryItem(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteImage(id);
  }
}
