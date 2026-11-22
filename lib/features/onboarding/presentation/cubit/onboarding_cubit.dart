import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/complete_onboarding.dart';

class OnboardingState extends Equatable {
  final int currentPage;
  final bool completed;

  const OnboardingState({this.currentPage = 0, this.completed = false});

  OnboardingState copyWith({int? currentPage, bool? completed}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [currentPage, completed];
}

class OnboardingCubit extends Cubit<OnboardingState> {
  final CompleteOnboarding completeOnboarding;

  OnboardingCubit({required this.completeOnboarding})
      : super(const OnboardingState());

  void pageChanged(int index) => emit(state.copyWith(currentPage: index));

  Future<void> complete() async {
    // Even if saving fails, the user should still move on to login.
    await completeOnboarding(const NoParams());
    emit(state.copyWith(completed: true));
  }
}
