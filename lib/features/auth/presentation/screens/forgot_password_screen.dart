import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await sl<AuthRepository>().forgotPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      context.push(
        '/reset-password',
        extra: {
          'email': _emailController.text.trim(),
        },
      );
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
        title: const Text('Forgot Password'),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Reset your password',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppThemeTokens.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Enter your email to receive a reset code.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: AppThemeTokens.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text('Email'),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _emailController,
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              Validators.requiredField(value, fieldName: 'Email'),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'Send Code',
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
      ),
    );
  }
}