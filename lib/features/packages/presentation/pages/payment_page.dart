import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/plan_entity.dart';
import '../cubit/plan_cubit.dart';
import '../widgets/plan_card.dart';

class PaymentArgs {
  final PlanEntity plan;
  final bool yearly;
  const PaymentArgs({required this.plan, required this.yearly});
}

enum _PayMethod { card, wallet }

class PaymentPage extends StatefulWidget {
  final PaymentArgs args;
  const PaymentPage({super.key, required this.args});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  _PayMethod _method = _PayMethod.card;

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _pay() {
    FocusScope.of(context).unfocus();
    if (_method == _PayMethod.card &&
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<PlanCubit>().subscribe(widget.args.plan.id);
  }

  Future<void> _showSuccess(PlanEntity plan) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 56),
        title: Text('Welcome to ${plan.name}!'),
        content: const Text(
          'Your plan is active. Enjoy more images and higher quality.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Start removing backgrounds'),
          ),
        ],
      ),
    );
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.args.plan;
    final yearly = widget.args.yearly;
    final total = yearly ? plan.yearlyTotal : plan.monthlyPrice;
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurface.withOpacity(0.65);

    return BlocConsumer<PlanCubit, PlanState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == PlanStatus.subscribed) {
          _showSuccess(state.currentPlan ?? plan);
        } else if (state.status == PlanStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? 'Payment failed'),
              backgroundColor: AppColors.error,
            ));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == PlanStatus.subscribing;

        return Scaffold(
          appBar: AppBar(title: const Text('Upgrade')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('${plan.name} plan',
                                  style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700)),
                            ),
                            Text(yearly ? 'Yearly' : 'Monthly',
                                style: textTheme.bodyMedium
                                    ?.copyWith(color: muted)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(plan.limitLabel,
                              style: textTheme.bodySmall
                                  ?.copyWith(color: muted)),
                        ),
                        const Divider(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Text('Total',
                                  style: textTheme.titleMedium),
                            ),
                            Text(
                              formatPrice(total),
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Payment method',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _MethodTile(
                    icon: Icons.credit_card_rounded,
                    label: 'Credit / Debit card',
                    selected: _method == _PayMethod.card,
                    onTap: () => setState(() => _method = _PayMethod.card),
                  ),
                  const SizedBox(height: 10),
                  _MethodTile(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Google Pay / Apple Pay',
                    selected: _method == _PayMethod.wallet,
                    onTap: () => setState(() => _method = _PayMethod.wallet),
                  ),
                  if (_method == _PayMethod.card) ...[
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _cardController,
                            label: 'Card number',
                            hint: '1234 5678 9012 3456',
                            prefixIcon: Icons.credit_card_rounded,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: Validators.cardNumber,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _expiryController,
                                  label: 'Expiry',
                                  hint: 'MM/YY',
                                  prefixIcon: Icons.date_range_rounded,
                                  keyboardType: TextInputType.datetime,
                                  textInputAction: TextInputAction.next,
                                  validator: Validators.expiry,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: AppTextField(
                                  controller: _cvvController,
                                  label: 'CVV',
                                  hint: '123',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  validator: Validators.cvv,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo checkout: no real payment is made.',
                          style: textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Pay ${formatPrice(total)}',
                    isLoading: isLoading,
                    onPressed: _pay,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(child: Text(label)),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : null,
            ),
          ],
        ),
      ),
    );
  }
}
