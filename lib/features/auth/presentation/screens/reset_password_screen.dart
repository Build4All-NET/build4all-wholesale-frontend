import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _codeController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_codeController.text.trim().isEmpty ||
        _newPasswordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (_newPasswordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await sl<AuthService>().verifyResetCode(
        email: widget.email,
        code: _codeController.text.trim(),
      );

      await sl<AuthRepository>().resetPassword(
        resetToken: '${widget.email}|||${_codeController.text.trim()}',
        newPassword: _newPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 8),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
                  side: const BorderSide(color: AppThemeTokens.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Enter reset code',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppThemeTokens.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'We sent a code to ${widget.email}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text('Code'),
                      const SizedBox(height: 8),
                      PrimaryTextField(
                        controller: _codeController,
                        hintText: 'Enter code',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const Text('New Password'),
                      const SizedBox(height: 8),
                      PrimaryTextField(
                        controller: _newPasswordController,
                        hintText: 'Enter new password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      const Text('Confirm Password'),
                      const SizedBox(height: 8),
                      PrimaryTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Re-enter new password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Update Password',
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}