import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Reusable empty / error state: icon, title, message and optional actions.
class StateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final String? secondaryText;
  final VoidCallback? onSecondary;
  final Color color;

  const StateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.secondaryText,
    this.onSecondary,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
              ),
              child: Icon(icon, size: 52, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.65),
                height: 1.5,
              ),
            ),
            if (actionText != null) ...[
              const SizedBox(height: 28),
              ElevatedButton(onPressed: onAction, child: Text(actionText!)),
            ],
            if (secondaryText != null) ...[
              const SizedBox(height: 4),
              TextButton(onPressed: onSecondary, child: Text(secondaryText!)),
            ],
          ],
        ),
      ),
    );
  }
}
