import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/local_image.dart';
import '../../../../core/widgets/state_view.dart';
import '../cubit/processing_cubit.dart';

class ProcessingPage extends StatelessWidget {
  final String imagePath;
  const ProcessingPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProcessingCubit>()..start(imagePath),
      child: _ProcessingView(imagePath: imagePath),
    );
  }
}

class _ProcessingView extends StatefulWidget {
  final String imagePath;
  const _ProcessingView({required this.imagePath});

  @override
  State<_ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<_ProcessingView>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    'Analyzing your photo...',
    'Detecting the subject...',
    'Removing the background...',
    'Polishing the edges...',
  ];

  late final AnimationController _scan;
  Timer? _timer;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _scan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!mounted) return;
      setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProcessingCubit, ProcessingState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status && curr.status == ProcessingStatus.success,
      listener: (context, state) {
        context.pushReplacement(AppRoutes.result, extra: state.result);
      },
      builder: (context, state) {
        if (state.status == ProcessingStatus.failure) {
          return _FailureView(
            state: state,
            onRetry: () =>
                context.read<ProcessingCubit>().start(widget.imagePath),
          );
        }
        return _buildProcessing(context);
      },
    );
  }

  Widget _buildProcessing(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurface.withOpacity(0.65);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          LocalImage(path: widget.imagePath),
                          Container(color: Colors.black.withOpacity(0.25)),
                          AnimatedBuilder(
                            animation: _scan,
                            builder: (context, _) => Align(
                              alignment: Alignment(0, -1 + 2 * _scan.value),
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Colors.transparent,
                                    AppColors.secondary,
                                    Colors.transparent,
                                  ]),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondary
                                          .withOpacity(0.7),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _messages[_messageIndex],
                  key: ValueKey(_messageIndex),
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              Text('This usually takes a few seconds',
                  style: textTheme.bodySmall?.copyWith(color: muted)),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(minHeight: 6),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  final ProcessingState state;
  final VoidCallback onRetry;

  const _FailureView({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final Widget content;

    switch (state.error) {
      case ProcessingError.network:
        content = StateView(
          icon: Icons.wifi_off_rounded,
          color: AppColors.warning,
          title: 'No internet connection',
          message: 'Check your connection and try again.',
          actionText: 'Try again',
          onAction: onRetry,
          secondaryText: 'Go back',
          onSecondary: () => context.pop(),
        );
      case ProcessingError.limit:
        content = StateView(
          icon: Icons.hourglass_bottom_rounded,
          color: AppColors.warning,
          title: 'Daily limit reached',
          message:
              "You've used all your images for today. Upgrade your plan to keep going.",
          actionText: 'View plans',
          onAction: () => context.go(AppRoutes.packages),
          secondaryText: 'Maybe later',
          onSecondary: () => context.pop(),
        );
      case ProcessingError.failed:
      case ProcessingError.none:
        content = StateView(
          icon: Icons.error_outline_rounded,
          color: AppColors.error,
          title: 'Processing failed',
          message:
              state.message ?? 'Something went wrong. Please try another photo.',
          actionText: 'Try again',
          onAction: onRetry,
          secondaryText: 'Choose another photo',
          onSecondary: () => context.pushReplacement(AppRoutes.upload),
        );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(child: content),
    );
  }
}
