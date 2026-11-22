import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/plan_entity.dart';
import '../models/plan_model.dart';

abstract class PlansLocalDataSource {
  List<PlanModel> getPlans();
  PlanModel getCurrentPlan();
  Future<void> setCurrentPlan(String planId);
  int getTodayUsage();
  Future<void> incrementUsage();
}

class PlansLocalDataSourceImpl implements PlansLocalDataSource {
  final SharedPreferences prefs;
  PlansLocalDataSourceImpl(this.prefs);

  static const List<PlanModel> _plans = [
    PlanModel(
      id: 'free',
      name: 'Free',
      monthlyPrice: 0,
      dailyLimit: 3,
      features: [
        '3 images per day',
        'Standard quality (up to 1080px)',
        'Basic editor',
        'Includes watermark',
      ],
    ),
    PlanModel(
      id: 'pro',
      name: 'Pro',
      monthlyPrice: 4.99,
      dailyLimit: 50,
      isBestValue: true,
      features: [
        '50 images per day',
        'HD quality (up to 4K)',
        'Full editor with custom backgrounds',
        'No watermark',
      ],
    ),
    PlanModel(
      id: 'premium',
      name: 'Premium',
      monthlyPrice: 9.99,
      dailyLimit: PlanEntity.unlimited,
      features: [
        'Unlimited images',
        'Ultra HD quality',
        'Priority processing',
        'No watermark',
        'Priority support',
      ],
    ),
  ];

  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  @override
  List<PlanModel> getPlans() => _plans;

  @override
  PlanModel getCurrentPlan() {
    final id = prefs.getString(AppConstants.planIdKey!) ?? 'free';
    return _plans.firstWhere((p) => p.id == id, orElse: () => _plans.first);
  }

  @override
  Future<void> setCurrentPlan(String planId) async {
    await prefs.setString(AppConstants.planIdKey!, planId);
  }

  @override
  int getTodayUsage() {
    if (prefs.getString(AppConstants.usageDateKey!) != _today) return 0;
    return prefs.getInt(AppConstants.usageCountKey!) ?? 0;
  }

  @override
  Future<void> incrementUsage() async {
    final count = getTodayUsage() + 1;
    await prefs.setString(AppConstants.usageDateKey!, _today);
    await prefs.setInt(AppConstants.usageCountKey!, count);
  }
}
