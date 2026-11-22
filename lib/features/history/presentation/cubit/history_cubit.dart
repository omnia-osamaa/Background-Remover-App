import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/processed_image.dart';
import '../../domain/usecases/delete_history_item.dart';
import '../../domain/usecases/get_history.dart';

enum HistoryStatus { initial, loading, loaded, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<ProcessedImage> items;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, items, errorMessage];
}

class HistoryCubit extends Cubit<HistoryState> {
  final GetHistory getHistory;
  final DeleteHistoryItem deleteHistoryItem;

  HistoryCubit({required this.getHistory, required this.deleteHistoryItem})
      : super(const HistoryState());

  Future<void> load() async {
    // Keep showing the current items while refreshing.
    if (state.status == HistoryStatus.initial) {
      emit(const HistoryState(status: HistoryStatus.loading));
    }
    final result = await getHistory(const NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(HistoryState(
        status: HistoryStatus.failure,
        items: state.items,
        errorMessage: failure.message,
      )),
      (items) => emit(HistoryState(status: HistoryStatus.loaded, items: items)),
    );
  }

  Future<void> delete(String id) async {
    await deleteHistoryItem(id);
    await load();
  }
}
