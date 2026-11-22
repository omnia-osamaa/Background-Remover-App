import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

abstract class OnboardingLocalDataSource {
  bool isSeen();
  Future<void> setSeen();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences prefs;
  OnboardingLocalDataSourceImpl(this.prefs);

  @override
  bool isSeen() => prefs.getBool(AppConstants.onboardingSeenKey) ?? false;

  @override
  Future<void> setSeen() async {
    await prefs.setBool(AppConstants.onboardingSeenKey, true);
  }
}
