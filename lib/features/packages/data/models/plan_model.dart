import '../../domain/entities/plan_entity.dart';

class PlanModel extends PlanEntity {
  const PlanModel({
    required super.id,
    required super.name,
    required super.monthlyPrice,
    required super.dailyLimit,
    required super.features,
    super.isBestValue,
  });
}
