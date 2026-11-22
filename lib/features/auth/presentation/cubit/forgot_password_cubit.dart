import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/forgot_password_usecase.dart';

enum ForgotPasswordStatus { initial, loading, sent, failure }

class ForgotPasswordState extends Equatable {
  final ForgotPasswordStatus status;
  final String? errorMessage;

  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, errorMessage];
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordUseCase forgotPasswordUseCase;

  ForgotPasswordCubit({required this.forgotPasswordUseCase})
      : super(const ForgotPasswordState());

  Future<void> sendLink(String email) async {
    emit(const ForgotPasswordState(status: ForgotPasswordStatus.loading));
    final result = await forgotPasswordUseCase(email.trim());
    if (isClosed) return;
    result.fold(
      (failure) => emit(ForgotPasswordState(
        status: ForgotPasswordStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(const ForgotPasswordState(status: ForgotPasswordStatus.sent)),
    );
  }
}
