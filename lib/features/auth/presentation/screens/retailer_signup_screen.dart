import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../../data/services/auth_service.dart';
import 'retailer_verify_code_screen.dart';

class RetailerSignupScreen extends StatefulWidget {
  const RetailerSignupScreen({super.key});

  @override
  State<RetailerSignupScreen> createState() => _RetailerSignupScreenState();
}

class _RetailerSignupScreenState extends State<RetailerSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.emailRequired;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return context.l10n.enterValidEmail;
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.passwordRequired;
    }

    if (value.trim().length < 6) {
      return context.l10n.passwordMinLength;
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.confirmPasswordRequired;
    }

    if (value.trim() != _passwordController.text.trim()) {
      return context.l10n.passwordsDoNotMatch;
    }

    return null;
  }

  Future<void> _continueSignup() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await sl<AuthService>().sendBuild4AllVerification(
        email: email,
        password: password,
      );

      if (!mounted) return;

     Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => RetailerVerifyCodeScreen(
      email: email,
      password: password,
    ),
  ),
);
    } catch (e) {
      if (!mounted) return;

      AppToast.error(context, e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        PrimaryTextField(
          controller: controller,
          hintText: hintText,
          obscureText: true,
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
        title: Text(context.l10n.createRetailerAccount),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 8),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemeTokens.screenHorizontalPadding,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppThemeTokens.radiusLarge,
                  ),
                  side: const BorderSide(color: AppThemeTokens.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.step1of3,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.createYourAccount,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppThemeTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.createRetailerAccountUsingEmail,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),

                        Text(context.l10n.email),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _emailController,
                          hintText: context.l10n.enterYourEmail,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),

                        const SizedBox(height: 16),

                        _passwordField(
                          label: context.l10n.password,
                          controller: _passwordController,
                          hintText: context.l10n.enterPassword,
                          validator: _validatePassword,
                        ),

                        const SizedBox(height: 8),
                        Text(
                          context.l10n.passwordMinLength,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _passwordField(
                          label: context.l10n.confirmPassword,
                          controller: _confirmPasswordController,
                          hintText: context.l10n.reEnterPassword,
                          validator: _validateConfirmPassword,
                        ),

                        const SizedBox(height: 24),

                        PrimaryButton(
                          text: context.l10n.continueLabel,
                          isLoading: _isLoading,
                          onPressed: _continueSignup,
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                context.l10n.alreadyHaveAccount,
                                style: const TextStyle(
                                  color: AppThemeTokens.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  context.l10n.login,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
