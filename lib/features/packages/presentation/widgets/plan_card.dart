import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/plan_entity.dart';

String formatPrice(double value) => '\$${value.toStringAsFixed(2)}';

class PlanCard extends StatelessWidget {
  final PlanEntity plan;
  final bool yearly;
  final bool isCurrent;
  final VoidCallback? onSelect;

  const PlanCard({
    super.key,
    required this.plan,
    required this.yearly,
    required this.isCurrent,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final muted = theme.colorScheme.onSurface.withOpacity(0.65);
    final highlight = plan.isBestValue;

    final price =
        yearly ? plan.yearlyMonthlyEquivalent : plan.monthlyPrice;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: highlight
                  ? AppColors.primary
                  : theme.colorScheme.onSurface.withOpacity(0.08),
              width: highlight ? 2 : 1,
            ),
            boxShadow: highlight
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Current plan',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.isFree ? 'Free' : formatPrice(price),
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: highlight ? AppColors.primary : null,
                    ),
                  ),
                  if (!plan.isFree) ...[
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('/ month',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: muted)),
                    ),
                  ],
                ],
              ),
              if (!plan.isFree && yearly)
                Text(
                  'Billed ${formatPrice(plan.yearlyTotal)} per year',
                  style: textTheme.bodySmall?.copyWith(color: muted),
                ),
              const SizedBox(height: 16),
              for (final feature in plan.features)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: plan.isFree
                            ? muted
                            : AppColors.secondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(feature, style: textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              if (!plan.isFree) ...[
                const SizedBox(height: 16),
                if (isCurrent)
                  const OutlinedButton(
                    onPressed: null,
                    child: Text('Your current plan'),
                  )
                else
                  ElevatedButton(
                    onPressed: onSelect,
                    child: Text('Choose ${plan.name}'),
                  ),
              ],
            ],
          ),
        ),
        if (highlight)
          Positioned(
            top: -12,
            right: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'BEST VALUE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
