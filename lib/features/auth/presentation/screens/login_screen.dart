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
import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _obscurePassword = true;

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

  void _submit(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;

    cubit.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
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

          if (state.loginSuccess && state.user != null) {
            final user = state.user!;

            if (user.isSupplier) {
              if (user.profileCompleted == false) {
                context.go('/complete-supplier-profile');
              } else {
                context.go('/supplier-dashboard');
              }
            } else if (user.isRetailer) {
              context.go('/retailer-dashboard');
            }
          }
        },
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          final l10n = context.l10n;

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
                              AuthHeader(
                                icon: Icons.storefront_outlined,
                                iconBackgroundColor: const Color(0xFFDCFCE7),
                                iconColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                title: l10n.supplierManager,
                                subtitle: l10n.loginSubtitle,
                              ),
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
                                text: l10n.login,
                                isLoading: state.isLoading,
                                onPressed: () => _submit(cubit),
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
