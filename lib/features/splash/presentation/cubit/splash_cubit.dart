import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/get_cached_user_usecase.dart';
import '../../../onboarding/domain/usecases/check_onboarding_seen.dart';

enum SplashDestination { onboarding, login, home }

class SplashState extends Equatable {
  final SplashDestination? destination;
  const SplashState({this.destination});

  @override
  List<Object?> get props => [destination];
}

class SplashCubit extends Cubit<SplashState> {
  final CheckOnboardingSeen checkOnboardingSeen;
  final GetCachedUserUseCase getCachedUser;

  SplashCubit({
    required this.checkOnboardingSeen,
    required this.getCachedUser,
  }) : super(const SplashState());

  Future<void> start() async {
    final seenFuture = checkOnboardingSeen(const NoParams());
    final userFuture = getCachedUser(const NoParams());
    await Future.delayed(const Duration(milliseconds: 2200));

    final seen = (await seenFuture).fold((_) => false, (value) => value);
    final user = (await userFuture).fold((_) => null, (value) => value);
    if (isClosed) return;

    final SplashDestination destination;
    if (user != null) {
      destination = SplashDestination.home;
    } else if (seen) {
      destination = SplashDestination.login;
    } else {
      destination = SplashDestination.onboarding;
    }
    emit(SplashState(destination: destination));
  }
}
