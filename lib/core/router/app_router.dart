import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/background_removal/presentation/pages/processing_page.dart';
import '../../features/background_removal/presentation/pages/result_page.dart';
import '../../features/background_removal/presentation/pages/upload_page.dart';
import '../../features/editor/presentation/pages/editor_page.dart';
import '../../features/history/domain/entities/processed_image.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/packages/presentation/pages/packages_page.dart';
import '../../features/packages/presentation/pages/payment_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../widgets/main_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';

  // Tabs (inside the bottom navigation shell)
  static const String home = '/home';
  static const String history = '/history';
  static const String packages = '/packages';
  static const String profile = '/profile';

  // Full-screen flows
  static const String upload = '/upload';
  static const String processing = '/processing';
  static const String result = '/result';
  static const String editor = '/editor';
  static const String payment = '/payment';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.history,
              builder: (context, state) => const HistoryPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.packages,
              builder: (context, state) => const PackagesPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.upload,
        builder: (context, state) => const UploadPage(),
      ),
      GoRoute(
        path: AppRoutes.processing,
        builder: (context, state) =>
            ProcessingPage(imagePath: state.extra as String),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) =>
            ResultPage(image: state.extra as ProcessedImage),
      ),
      GoRoute(
        path: AppRoutes.editor,
        builder: (context, state) =>
            EditorPage(image: state.extra as ProcessedImage),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) =>
            PaymentPage(args: state.extra as PaymentArgs),
      ),
    ],
  );
}
