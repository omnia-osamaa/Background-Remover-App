import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;

  /// When true the logo is white (for use on the purple splash background).
  final bool onDark;

  const AppLogo({super.key, this.size = 88, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onDark ? Colors.white : null,
        gradient: onDark
            ? null
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Icon(
        Icons.auto_fix_high_rounded,
        size: size * 0.52,
        color: onDark ? AppColors.primary : Colors.white,
      ),
    );
  }
}
