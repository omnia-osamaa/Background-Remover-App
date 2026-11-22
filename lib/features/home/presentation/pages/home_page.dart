import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/checkerboard.dart';
import '../../../../core/widgets/local_image.dart';
import '../../../history/presentation/cubit/history_cubit.dart';
import '../../../packages/presentation/widgets/plan_summary_card.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: const [
            _Header(),
            SizedBox(height: 24),
            _UploadCard(),
            SizedBox(height: 20),
            PlanSummaryCard(),
            SizedBox(height: 28),
            _RecentSection(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurface.withOpacity(0.65);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final name = state.user?.name ?? '';
        final firstName = name.trim().isEmpty ? 'there' : name.trim().split(' ').first;
        final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, $firstName',
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Ready to remove a background?',
                      style: textTheme.bodyMedium?.copyWith(color: muted)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF4A2FD6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 36),
          const SizedBox(height: 16),
          const Text(
            'Remove a background\nin one tap',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            onPressed: () => context.push(AppRoutes.upload),
            icon: const Icon(Icons.add_photo_alternate_rounded),
            label: const Text('Upload photo'),
          ),
        ],
      ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Recent',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (state.items.isNotEmpty)
                  TextButton(
                    onPressed: () => context.go(AppRoutes.history),
                    child: const Text('See all'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined,
                        size: 36,
                        color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    const SizedBox(height: 10),
                    Text(
                      'No images yet.\nYour processed photos will appear here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.items.length > 8 ? 8 : state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final item = state.items[i];
                    return GestureDetector(
                      onTap: () => context.push(AppRoutes.result, extra: item),
                      child: SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Checkerboard(
                            child: LocalImage(
                              path: item.resultPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
