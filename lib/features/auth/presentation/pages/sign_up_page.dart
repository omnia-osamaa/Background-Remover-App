import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/sign_up_cubit.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SignUpCubit>(),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit(SignUpState state) {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!state.agreedToTerms) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Please accept the Terms & Privacy Policy'),
        ));
      return;
    }
    context.read<SignUpCubit>().signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mutedColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.65);

    return BlocConsumer<SignUpCubit, SignUpState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SignUpStatus.success) {
          context.go(AppRoutes.home);
        } else if (state.status == SignUpStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? 'Sign up failed'),
              backgroundColor: AppColors.error,
            ));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == SignUpStatus.loading;

        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create account',
                      style: textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to start removing backgrounds for free.',
                      style: textTheme.bodyLarge?.copyWith(color: mutedColor),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      controller: _nameController,
                      label: 'Full name',
                      hint: 'Your name',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'At least 6 characters',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: state.obscurePassword,
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                      suffix: IconButton(
                        icon: Icon(state.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: context
                            .read<SignUpCubit>()
                            .togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _confirmController,
                      label: 'Confirm password',
                      hint: 'Repeat your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: state.obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: Validators.confirmPassword(
                          () => _passwordController.text),
                      onSubmitted: (_) => _submit(state),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: state.agreedToTerms,
                          onChanged: (v) => context
                              .read<SignUpCubit>()
                              .toggleTerms(v ?? false),
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Create Account',
                      isLoading: isLoading,
                      onPressed: () => _submit(state),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?',
                            style: textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: const Text('Log In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
