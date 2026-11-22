import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/plan_entity.dart';
import '../cubit/plan_cubit.dart';
import '../widgets/plan_card.dart';
import 'payment_page.dart';

class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  bool _yearly = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Plans')),
      body: BlocBuilder<PlanCubit, PlanState>(
        builder: (context, state) {
          if (state.plans.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                'Choose the plan that fits you',
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Upgrade anytime. Cancel anytime.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.65),
                ),
              ),
              const SizedBox(height: 20),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Monthly')),
                  ButtonSegment(value: true, label: Text('Yearly · Save 17%')),
                ],
                selected: {_yearly},
                onSelectionChanged: (s) => setState(() => _yearly = s.first),
              ),
              const SizedBox(height: 28),
              for (final PlanEntity plan in state.plans) ...[
                PlanCard(
                  plan: plan,
                  yearly: _yearly,
                  isCurrent: state.currentPlan?.id == plan.id,
                  onSelect: () => context.push(
                    AppRoutes.payment,
                    extra: PaymentArgs(plan: plan, yearly: _yearly),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          );
        },
      ),
    );
  }
}
