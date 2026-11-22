import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/sign_up_usecase.dart';

enum SignUpStatus { initial, loading, success, failure }

class SignUpState extends Equatable {
  final SignUpStatus status;
  final bool obscurePassword;
  final bool agreedToTerms;
  final String? errorMessage;

  const SignUpState({
    this.status = SignUpStatus.initial,
    this.obscurePassword = true,
    this.agreedToTerms = false,
    this.errorMessage,
  });

  SignUpState copyWith({
    SignUpStatus? status,
    bool? obscurePassword,
    bool? agreedToTerms,
    String? errorMessage,
  }) {
    return SignUpState(
      status: status ?? this.status,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, obscurePassword, agreedToTerms, errorMessage];
}

class SignUpCubit extends Cubit<SignUpState> {
  final SignUpUseCase signUpUseCase;

  SignUpCubit({required this.signUpUseCase}) : super(const SignUpState());

  void togglePasswordVisibility() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleTerms(bool value) => emit(state.copyWith(agreedToTerms: value));

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: SignUpStatus.loading));

    final result = await signUpUseCase(SignUpParams(
      name: name.trim(),
      email: email.trim(),
      password: password,
    ));
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: SignUpStatus.success)),
    );
  }
}
