import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/plan_cubit.dart';

/// Shows the current plan and today's usage. Used on Home and Profile.
class PlanSummaryCard extends StatelessWidget {
  const PlanSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.65);

    return BlocBuilder<PlanCubit, PlanState>(
      builder: (context, state) {
        final plan = state.currentPlan;

        if (plan == null) {
          return Container(
            height: 96,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }

        final unlimited = plan.hasUnlimitedImages;
        final progress = unlimited
            ? 0.0
            : (state.usedToday / plan.dailyLimit).clamp(0.0, 1.0).toDouble();
        final reachedLimit = !unlimited && state.usedToday >= plan.dailyLimit;
        final isTopPlan = unlimited;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current plan',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: muted)),
                        Text(
                          plan.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (!isTopPlan)
                    TextButton(
                      onPressed: () => context.go(AppRoutes.packages),
                      child: const Text('Upgrade'),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (unlimited)
                Text('Unlimited images today',
                    style: theme.textTheme.bodyMedium)
              else ...[
                Text(
                  '${state.usedToday} of ${plan.dailyLimit} images used today',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: reachedLimit ? AppColors.error : AppColors.primary,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
