import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../history/domain/entities/processed_image.dart';
import '../../domain/usecases/remove_background.dart';

enum ProcessingStatus { processing, success, failure }

enum ProcessingError { none, network, limit, failed }

class ProcessingState extends Equatable {
  final ProcessingStatus status;
  final ProcessingError error;
  final String? message;
  final ProcessedImage? result;

  const ProcessingState({
    this.status = ProcessingStatus.processing,
    this.error = ProcessingError.none,
    this.message,
    this.result,
  });

  @override
  List<Object?> get props => [status, error, message, result];
}

class ProcessingCubit extends Cubit<ProcessingState> {
  final RemoveBackground removeBackground;

  ProcessingCubit({required this.removeBackground})
      : super(const ProcessingState());

  Future<void> start(String imagePath) async {
    emit(const ProcessingState());

    final result = await removeBackground(imagePath);
    if (isClosed) return;

    result.fold(
      (failure) {
        final ProcessingError error;
        if (failure is NetworkFailure) {
          error = ProcessingError.network;
        } else if (failure is LimitReachedFailure) {
          error = ProcessingError.limit;
        } else {
          error = ProcessingError.failed;
        }
        emit(ProcessingState(
          status: ProcessingStatus.failure,
          error: error,
          message: failure.message,
        ));
      },
      (image) => emit(ProcessingState(
        status: ProcessingStatus.success,
        result: image,
      )),
    );
  }
}
