import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_toast.dart';
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
      AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        title: Text(context.l10n.forgotPassword),
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
                        Center(
                          child: Text(
                            context.l10n.resetPassword,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppThemeTokens.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            context.l10n.enterEmailToGenerateResetToken,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppThemeTokens.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(context.l10n.email),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _emailController,
                          hintText: context.l10n.enterYourEmail,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: context.l10n.email,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: context.l10n.sendCode,
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