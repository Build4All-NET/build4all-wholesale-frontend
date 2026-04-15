import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'package:flutter/services.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? initialToken;

  const ResetPasswordScreen({super.key, this.initialToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tokenController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken ?? '');
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;

    cubit.resetPassword(
      resetToken: _tokenController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<AuthCubit>().clearMessages();
          }

          if (state.resetPasswordSuccess &&
              state.resetPasswordResponse != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.resetPasswordResponse!.message)),
            );
            context.read<AuthCubit>().clearMessages();
            context.go('/');
          }
        },
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          final l10n = context.l10n;

          return Scaffold(
            backgroundColor: AppThemeTokens.background,
            appBar: AppBar(
              title: Text(l10n.resetPassword),
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppThemeTokens.screenHorizontalPadding,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
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
                        padding: const EdgeInsets.all(18),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              Icon(
                                Icons.lock_reset,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.resetPassword,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppThemeTokens.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.enterResetTokenAndPassword,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppThemeTokens.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 28),

                              PrimaryTextField(
                                controller: _tokenController,
                                hintText: l10n.pasteResetToken,
                                prefixIcon: const Icon(Icons.vpn_key_outlined),
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: l10n.resetToken,
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: _obscureNewPassword,
                                validator: Validators.password,

                                decoration: InputDecoration(
                                  hintText: l10n.newPassword,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewPassword =
                                            !_obscureNewPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscureNewPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                validator: (value) =>
                                    Validators.confirmPassword(
                                      value,
                                      _newPasswordController.text.trim(),
                                    ),

                                decoration: InputDecoration(
                                  hintText: l10n.confirmNewPassword,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              PrimaryButton(
                                text: l10n.resetPassword,
                                isLoading: state.isLoading,
                                onPressed: () => _submit(cubit),
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
        },
      ),
    );
  }
}
