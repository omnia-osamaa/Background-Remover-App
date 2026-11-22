import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/checkerboard.dart';
import '../../../../core/widgets/local_image.dart';
import '../../../../core/widgets/state_view.dart';
import '../../domain/entities/processed_image.dart';
import '../cubit/history_cubit.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _confirmDelete(BuildContext context, ProcessedImage item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete image?'),
        content: const Text('This image will be removed from your files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<HistoryCubit>().delete(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Files')),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state.status == HistoryStatus.initial ||
              (state.status == HistoryStatus.loading && state.items.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == HistoryStatus.failure && state.items.isEmpty) {
            return StateView(
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              title: 'Something went wrong',
              message: state.errorMessage ?? 'We could not load your images.',
              actionText: 'Try again',
              onAction: () => context.read<HistoryCubit>().load(),
            );
          }

          if (state.items.isEmpty) {
            return StateView(
              icon: Icons.photo_library_outlined,
              title: 'No images yet',
              message:
                  'Images you process will show up here so you can find them later.',
              actionText: 'Remove a background',
              onAction: () => context.push(AppRoutes.upload),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<HistoryCubit>().load(),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.8,
              ),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _HistoryTile(
                  item: item,
                  onTap: () => context.push(AppRoutes.result, extra: item),
                  onDelete: () => _confirmDelete(context, item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ProcessedImage item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Checkerboard(
              child: LocalImage(path: item.resultPath, fit: BoxFit.cover),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 24, 4, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat.yMMMd().format(item.createdAt),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.white, size: 20),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
