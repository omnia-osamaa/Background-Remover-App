import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/state_view.dart';
import '../cubit/forgot_password_cubit.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ForgotPasswordCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgotPasswordCubit>().sendLink(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mutedColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.65);

    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status &&
          curr.status == ForgotPasswordStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(state.errorMessage ?? 'Something went wrong'),
            backgroundColor: AppColors.error,
          ));
      },
      builder: (context, state) {
        if (state.status == ForgotPasswordStatus.sent) {
          return Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: StateView(
                icon: Icons.mark_email_read_rounded,
                color: AppColors.success,
                title: 'Check your email',
                message:
                    'We sent a password reset link to ${_emailController.text.trim()}.',
                actionText: 'Back to Log In',
                onAction: () => context.pop(),
              ),
            ),
          );
        }

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
                      'Forgot password?',
                      style: textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your email and we'll send you a link to reset your password.",
                      style: textTheme.bodyLarge?.copyWith(color: mutedColor),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: Validators.email,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      text: 'Send Reset Link',
                      isLoading: state.status == ForgotPasswordStatus.loading,
                      onPressed: _submit,
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
