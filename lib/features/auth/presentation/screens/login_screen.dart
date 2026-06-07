import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/branding/app_brand_logo.dart';
import '../../../../core/branding/branding_cubit.dart';
import '../../../../core/branding/branding_state.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../injection_container.dart';
import '../../data/services/build4all_login_gate.dart';
import '../../domain/entities/login_account_type.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_account_choice_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  final Build4AllLoginGate _loginGate = Build4AllLoginGate();

  bool _obscurePassword = true;
  bool _isCheckingAccounts = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthCubit cubit) async {
  if (!_formKey.currentState!.validate()) return;

  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  setState(() {
    _isCheckingAccounts = true;
  });

  try {
    final gateResult = await _loginGate.checkAvailableAccounts(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (gateResult.hasBoth) {
      final selectedType = await showModalBottomSheet<LoginAccountType>(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        isScrollControlled: true,
        builder: (_) => const LoginAccountChoiceDialog(),
      );

      if (selectedType == null) {
        return;
      }

      await cubit.login(
        email: email,
        password: password,
        preferredAccountType: selectedType,
      );

      return;
    }

    if (gateResult.hasOnlySupplier) {
      await cubit.login(
        email: email,
        password: password,
        preferredAccountType: LoginAccountType.supplier,
      );

      return;
    }

    if (gateResult.hasOnlyRetailer) {
      await cubit.login(
        email: email,
        password: password,
        preferredAccountType: LoginAccountType.retailer,
      );

      return;
    }

    await cubit.login(email: email, password: password);
  } catch (e) {
    if (!mounted) return;

    AppToast.error(context, e);
  } finally {
    if (mounted) {
      setState(() {
        _isCheckingAccounts = false;
      });
    }
  }
}

  Widget _buildBrandingHeader(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = context.l10n;

    return BlocBuilder<BrandingCubit, BrandingState>(
      builder: (context, brandingState) {
        return Column(
          children: [
            AppBrandLogo(
              size: 82,
              iconSize: 38,
              fallbackIcon: Icons.storefront_outlined,
              fallbackIconColor: primaryColor,
              backgroundColor: primaryColor.withValues(alpha: 0.12),
            ),
            const SizedBox(height: 20),
            Text(
              brandingState.appName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.loginSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLoginNavigation(BuildContext context, AuthState state) {
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      AppToast.error(context, state.errorMessage!);
      context.read<AuthCubit>().clearMessages();
    }

    if (state.loginSuccess && state.user != null) {
      final user = state.user!;

      if (user.isSupplier) {
        if (user.profileCompleted == false) {
          context.go('/complete-supplier-profile');
        } else {
          context.go('/supplier-dashboard');
        }
        return;
      }

      if (user.isRetailer) {
        if (user.profileCompleted == false) {
          context.go('/complete-retailer-profile');
        } else {
          context.go('/retailer-dashboard');
        }
        return;
      }

      AppToast.error(context, 'Unknown user role returned from backend.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: _handleLoginNavigation,
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          final l10n = context.l10n;

          final isLoading = state.isLoading || _isCheckingAccounts;

          return Scaffold(
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
                              const Align(
                                alignment: AlignmentDirectional.topEnd,
                                child: LanguageSelector(),
                              ),
                              const SizedBox(height: 6),
                              _buildBrandingHeader(context),
                              const SizedBox(height: 28),
                              Text(
                                l10n.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _emailController,
                                hintText: 'user@example.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.password,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: Validators.password,
                                decoration: InputDecoration(
                                  hintText: '******',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () =>
                                      context.push('/forgot-password'),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              PrimaryButton(
                                text: isLoading ? 'Checking...' : l10n.login,
                                isLoading: isLoading,
                                onPressed: () {
                                  if (isLoading) return;
                                  _submit(cubit);
                                },
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      l10n.orContinueWith,
                                      style: const TextStyle(
                                        color: AppThemeTokens.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed: null,
                                  icon: const Icon(
                                    Icons.g_mobiledata,
                                    size: 26,
                                  ),
                                  label: Text(l10n.loginWithGoogle),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppThemeTokens.textPrimary,
                                    side: const BorderSide(
                                      color: AppThemeTokens.border,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppThemeTokens.radiusMedium,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text('${l10n.dontHaveAccount} '),
                                  GestureDetector(
                                    onTap: () => context.push('/signup'),
                                    child: Text(
                                      l10n.signUp,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
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