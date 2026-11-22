import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  UserModel? getCachedUser();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;
  AuthLocalDataSourceImpl(this.prefs);

  @override
  Future<void> cacheUser(UserModel user) async {
    await prefs.setString(AppConstants.userKey!, jsonEncode(user.toJson()));
    await prefs.setString(AppConstants.authTokenKey, user.token);
  }

  @override
  UserModel? getCachedUser() {
    final raw = prefs.getString(AppConstants.userKey!);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clear() async {
    await prefs.remove(AppConstants.userKey!);
    await prefs.remove(AppConstants.authTokenKey);
  }
}
