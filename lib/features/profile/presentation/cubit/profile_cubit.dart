import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/get_cached_user_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';

class ProfileState extends Equatable {
  final UserEntity? user;
  const ProfileState({this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileCubit extends Cubit<ProfileState> {
  final GetCachedUserUseCase getCachedUser;
  final LogoutUseCase logoutUseCase;

  ProfileCubit({required this.getCachedUser, required this.logoutUseCase})
      : super(const ProfileState());

  Future<void> load() async {
    final result = await getCachedUser(const NoParams());
    if (isClosed) return;
    result.fold(
      (_) => emit(const ProfileState()),
      (user) => emit(ProfileState(user: user)),
    );
  }

  Future<void> logout() async {
    await logoutUseCase(const NoParams());
    if (isClosed) return;
    emit(const ProfileState());
  }
}
