import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final bool obscurePassword;
  final String? errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.obscurePassword = true,
    this.errorMessage,
  });

  LoginState copyWith({
    LoginStatus? status,
    bool? obscurePassword,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, obscurePassword, errorMessage];
}

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit({required this.loginUseCase}) : super(const LoginState());

  void togglePasswordVisibility() {
    emit(state.copyWith(
      status: state.status,
      obscurePassword: !state.obscurePassword,
    ));
  }

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await loginUseCase(
      LoginParams(email: email.trim(), password: password),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: LoginStatus.success)),
    );
  }
}
