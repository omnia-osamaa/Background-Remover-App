import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/checkerboard.dart';
import '../../../../core/widgets/local_image.dart';
import '../../../history/domain/entities/processed_image.dart';
import '../../../history/presentation/cubit/history_cubit.dart';
import '../../../packages/presentation/cubit/plan_cubit.dart';
import '../widgets/before_after_slider.dart';

class ResultPage extends StatefulWidget {
  final ProcessedImage image;
  const ResultPage({super.key, required this.image});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Refresh the data shown on Home / My Files / Plans.
    context.read<HistoryCubit>().load();
    context.read<PlanCubit>().load();
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : null,
      ));
  }

  Future<void> _download() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await sl<ImageService>().saveToGallery(widget.image.resultPath);
      _toast('Saved to your gallery');
    } catch (_) {
      _toast('Could not save the image. Check storage permission.',
          error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    try {
      await sl<ImageService>().share(widget.image.resultPath);
    } catch (_) {
      _toast('Could not share the image', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;
    final muted = Theme.of(context).colorScheme.onSurface.withOpacity(0.65);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BeforeAfterSlider(
                        before: ColoredBox(
                          color: Theme.of(context).colorScheme.surface,
                          child: LocalImage(
                            path: image.originalPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        after: Checkerboard(
                          child: LocalImage(
                            path: image.resultPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Drag the handle to compare',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: muted),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _saving ? null : _download,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded),
                label: const Text('Download'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.editor, extra: image),
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
