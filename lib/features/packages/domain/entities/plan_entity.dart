import 'package:equatable/equatable.dart';

class PlanEntity extends Equatable {
  static const int unlimited = -1;

  final String id;
  final String name;
  final double monthlyPrice;

  /// Images per day, or [unlimited].
  final int dailyLimit;
  final List<String> features;
  final bool isBestValue;

  const PlanEntity({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.dailyLimit,
    required this.features,
    this.isBestValue = false,
  });

  bool get isFree => monthlyPrice == 0;
  bool get hasUnlimitedImages => dailyLimit == unlimited;

  /// Yearly billing = 10 months for the price of 12 (2 months free).
  double get yearlyTotal => monthlyPrice * 10;
  double get yearlyMonthlyEquivalent => yearlyTotal / 12;

  String get limitLabel =>
      hasUnlimitedImages ? 'Unlimited images' : '$dailyLimit images per day';

  @override
  List<Object?> get props =>
      [id, name, monthlyPrice, dailyLimit, features, isBestValue];
}
