import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_cached_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/sign_up_cubit.dart';
import '../../features/background_removal/data/datasources/background_removal_remote_datasource.dart';
import '../../features/background_removal/data/repositories/background_removal_repository_impl.dart';
import '../../features/background_removal/domain/repositories/background_removal_repository.dart';
import '../../features/background_removal/domain/usecases/remove_background.dart';
import '../../features/background_removal/presentation/cubit/processing_cubit.dart';
import '../../features/editor/presentation/cubit/editor_cubit.dart';
import '../../features/history/data/datasources/history_local_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/delete_history_item.dart';
import '../../features/history/domain/usecases/get_history.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/check_onboarding_seen.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/packages/data/datasources/plans_local_datasource.dart';
import '../../features/packages/data/repositories/plans_repository_impl.dart';
import '../../features/packages/domain/repositories/plans_repository.dart';
import '../../features/packages/domain/usecases/plans_usecases.dart';
import '../../features/packages/presentation/cubit/plan_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../services/image_service.dart';
import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));
  sl.registerLazySingleton<ImageService>(() => ImageService());
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl()));

  _initOnboarding();
  _initAuth();
  _initSplash();
  _initHistory();
  _initPackages();
  _initBackgroundRemoval();
  _initEditor();
  _initProfile();
}

void _initOnboarding() {
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CheckOnboardingSeen>(() => CheckOnboardingSeen(sl()));
  sl.registerLazySingleton<CompleteOnboarding>(() => CompleteOnboarding(sl()));
  sl.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(completeOnboarding: sl()),
  );
}

void _initAuth() {
  // TODO: swap AuthRemoteDataSourceFake for the real Dio implementation.
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceFake(),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(sl()));
  sl.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl()),
  );
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<GetCachedUserUseCase>(
    () => GetCachedUserUseCase(sl()),
  );

  sl.registerFactory<LoginCubit>(() => LoginCubit(loginUseCase: sl()));
  sl.registerFactory<SignUpCubit>(() => SignUpCubit(signUpUseCase: sl()));
  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(forgotPasswordUseCase: sl()),
  );
}

void _initSplash() {
  sl.registerFactory<SplashCubit>(
    () => SplashCubit(checkOnboardingSeen: sl(), getCachedUser: sl()),
  );
}

void _initHistory() {
  sl.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetHistory>(() => GetHistory(sl()));
  sl.registerLazySingleton<DeleteHistoryItem>(() => DeleteHistoryItem(sl()));
  sl.registerFactory<HistoryCubit>(
    () => HistoryCubit(getHistory: sl(), deleteHistoryItem: sl()),
  );
}

void _initPackages() {
  sl.registerLazySingleton<PlansLocalDataSource>(
    () => PlansLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PlansRepository>(() => PlansRepositoryImpl(sl()));
  sl.registerLazySingleton<GetPlans>(() => GetPlans(sl()));
  sl.registerLazySingleton<GetCurrentPlan>(() => GetCurrentPlan(sl()));
  sl.registerLazySingleton<GetTodayUsage>(() => GetTodayUsage(sl()));
  sl.registerLazySingleton<SubscribeToPlan>(() => SubscribeToPlan(sl()));
  sl.registerFactory<PlanCubit>(
    () => PlanCubit(
      getPlans: sl(),
      getCurrentPlan: sl(),
      getTodayUsage: sl(),
      subscribeToPlan: sl(),
    ),
  );
}

void _initBackgroundRemoval() {
  // Uses the real remove.bg API only when an API key is provided via
  // --dart-define=REMOVE_BG_API_KEY=... ; otherwise a fake source is used.
  sl.registerLazySingleton<BackgroundRemovalRemoteDataSource>(() {
    if (AppConstants.removeBgApiKey.isNotEmpty) {
      return BackgroundRemovalRemoveBgDataSource(
        imageService: sl(),
        apiKey: AppConstants.removeBgApiKey,
      );
    }
    return BackgroundRemovalFakeDataSource(sl());
  });
  sl.registerLazySingleton<BackgroundRemovalRepository>(
    () => BackgroundRemovalRepositoryImpl(
      remoteDataSource: sl(),
      historyDataSource: sl(),
      plansDataSource: sl(),
      imageService: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<RemoveBackground>(() => RemoveBackground(sl()));
  sl.registerFactory<ProcessingCubit>(
    () => ProcessingCubit(removeBackground: sl()),
  );
}

void _initEditor() {
  sl.registerFactory<EditorCubit>(() => EditorCubit());
}

void _initProfile() {
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(getCachedUser: sl(), logoutUseCase: sl()),
  );
}
