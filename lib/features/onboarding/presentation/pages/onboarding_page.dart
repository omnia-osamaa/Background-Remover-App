import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_illustration.dart';

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingData(this.icon, this.title, this.description);
}

const _pages = <_OnboardingData>[
  _OnboardingData(
    Icons.add_photo_alternate_rounded,
    'Pick any photo',
    'Choose a photo from your gallery or take a new one in seconds.',
  ),
  _OnboardingData(
    Icons.auto_fix_high_rounded,
    'Background gone in one tap',
    'Our AI cuts out the subject cleanly and gives you a transparent result.',
  ),
  _OnboardingData(
    Icons.ios_share_rounded,
    'Edit, download & share',
    'Add a new color, gradient or photo background, then save or share it.',
  ),
];

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext(int currentPage) {
    if (currentPage == _pages.length - 1) {
      context.read<OnboardingCubit>().complete();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (prev, curr) => !prev.completed && curr.completed,
      listener: (context, state) => context.go(AppRoutes.login),
      builder: (context, state) {
        final isLast = state.currentPage == _pages.length - 1;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      opacity: isLast ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: isLast
                            ? null
                            : () => context.read<OnboardingCubit>().complete(),
                        child: const Text('Skip'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged:
                          context.read<OnboardingCubit>().pageChanged,
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OnboardingIllustration(icon: page.icon),
                            const SizedBox(height: 40),
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.65),
                                height: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == state.currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: isLast ? 'Get Started' : 'Next',
                    onPressed: () => _onNext(state.currentPage),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
