import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/primary_button.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../cubit/retailer_profile_cubit.dart';
import '../cubit/retailer_profile_state.dart';

class ProfileVerificationCodeScreen extends StatelessWidget {
  final String mode;
  final String email;
  final String? newPassword;

  const ProfileVerificationCodeScreen({
    super.key,
    required this.mode,
    required this.email,
    this.newPassword,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerProfileCubit>(),
      child: _ProfileVerificationCodeView(
        mode: mode,
        email: email,
        newPassword: newPassword,
      ),
    );
  }
}

class _ProfileVerificationCodeView extends StatefulWidget {
  final String mode;
  final String email;
  final String? newPassword;

  const _ProfileVerificationCodeView({
    required this.mode,
    required this.email,
    required this.newPassword,
  });

  bool get isEmailMode => mode == 'email';
  bool get isPasswordMode => mode == 'password';

  @override
  State<_ProfileVerificationCodeView> createState() =>
      _ProfileVerificationCodeViewState();
}

class _ProfileVerificationCodeViewState
    extends State<_ProfileVerificationCodeView> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final l10n = context.l10n;
    final code = _codeController.text.trim();

    if (code.length != 6) {
      _showMessage(l10n.verificationCode);
      return;
    }

    final cubit = context.read<RetailerProfileCubit>();

    bool success = false;

    if (widget.isEmailMode) {
      success = await cubit.verifyEmailChange(code);
    } else if (widget.isPasswordMode) {
      final password = widget.newPassword;

      if (password == null || password.isEmpty) {
        _showMessage(l10n.passwordsDoNotMatch);
        return;
      }

      success = await cubit.updatePasswordWithCode(
        email: widget.email,
        code: code,
        newPassword: password,
      );
    }

    if (!mounted) return;

    if (success) {
      context.pop(true);
    } else {
      final error = cubit.state.errorMessage;
      _showMessage(
        error == null || error.trim().isEmpty ? l10n.verificationCode : error,
      );
      cubit.clearMessages();
    }
  }

  Future<void> _resend() async {
    final cubit = context.read<RetailerProfileCubit>();

    bool success = false;

    if (widget.isEmailMode) {
      success = await cubit.resendEmailChangeCode();
    } else if (widget.isPasswordMode) {
      success = await cubit.sendPasswordResetCode(email: widget.email);
    }

    if (!mounted) return;

    if (success) {
      _showMessage(context.l10n.resendCode);
    } else {
      final error = cubit.state.errorMessage;
      _showMessage(
        error == null || error.trim().isEmpty ? context.l10n.resendCode : error,
      );
      cubit.clearMessages();
    }
  }

  void _showMessage(String message) {
    if (!mounted || message.trim().isEmpty) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final title = widget.isEmailMode
        ? l10n.verifyEmail
        : l10n.changePasswordOptional;

    final message = widget.isEmailMode
        ? l10n.emailVerificationRequired
        : l10n.passwordVerificationCodeSent;

    return BlocBuilder<RetailerProfileCubit, RetailerProfileState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(
                AppThemeTokens.screenHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: primaryColor.withValues(alpha: 0.10),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        color: primaryColor,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeTokens.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: l10n.verificationCode,
                      counterText: '',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    text: l10n.confirm,
                    isLoading: state.isSaving,
                    onPressed: state.isSaving ? null : _verify,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: state.isSaving ? null : _resend,
                      child: Text(
                        l10n.resendCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
