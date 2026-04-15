import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_dropdown_field.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/select_option_l10n_extension.dart';
import '../../../../core/models/select_option.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';
import 'package:flutter/services.dart';

class RetailerSignupScreen extends StatefulWidget {
  const RetailerSignupScreen({super.key});

  @override
  State<RetailerSignupScreen> createState() => _RetailerSignupScreenState();
}

class _RetailerSignupScreenState extends State<RetailerSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _storeNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _storeAddressController;

  String? _selectedCity;
  String? _selectedBusinessType;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<SelectOption> _cities = const [
    SelectOption(value: 'Beirut', labelKey: 'cityBeirut'),
    SelectOption(value: 'Tripoli', labelKey: 'cityTripoli'),
    SelectOption(value: 'Sidon', labelKey: 'citySidon'),
    SelectOption(value: 'Tyre', labelKey: 'cityTyre'),
    SelectOption(value: 'Zahle', labelKey: 'cityZahle'),
    SelectOption(value: 'Jounieh', labelKey: 'cityJounieh'),
    SelectOption(value: 'Nabatieh', labelKey: 'cityNabatieh'),
    SelectOption(value: 'Byblos', labelKey: 'cityByblos'),
    SelectOption(value: 'Aley', labelKey: 'cityAley'),
    SelectOption(value: 'Baalbek', labelKey: 'cityBaalbek'),
  ];

  final List<SelectOption> _businessTypes = const [
    SelectOption(value: 'Mini Market', labelKey: 'businessMiniMarket'),
    SelectOption(value: 'Supermarket', labelKey: 'businessSupermarket'),
    SelectOption(value: 'Pharmacy', labelKey: 'businessPharmacy'),
    SelectOption(value: 'Restaurant', labelKey: 'businessRestaurant'),
    SelectOption(value: 'Cafe', labelKey: 'businessCafe'),
    SelectOption(value: 'Retail Shop', labelKey: 'businessRetailShop'),
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _storeNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _storeAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _storeNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  void _submit(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;

    cubit.retailerSignup(
      fullName: _fullNameController.text.trim(),
      storeName: _storeNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      storeAddress: _storeAddressController.text.trim(),
      city: _selectedCity!,
      businessType: _selectedBusinessType!,
    );
  }

  String? _validateLebanesePhone(String? value) {
    final l10n = context.l10n;

    if (value == null || value.trim().isEmpty) {
      return '${l10n.phoneNumber} is required';
    }

    final cleaned = value.replaceAll(' ', '');
    final lebanesePhoneRegex = RegExp(
      r'^(\+961|0)?(3|70|71|76|78|79|81)\d{6}$',
    );

    if (!lebanesePhoneRegex.hasMatch(cleaned)) {
      return l10n.enterValidLebanesePhone;
    }

    return null;
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

          if (state.signupSuccess && state.signupResponse != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.signupResponse!.message)),
            );
            context.read<AuthCubit>().clearMessages();
            context.pop();
          }
        },
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          final l10n = context.l10n;

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.login),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeTokens.screenHorizontalPadding,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
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
                              const SizedBox(height: 8),
                              AuthHeader(
                                icon: Icons.shopping_cart_checkout_outlined,
                                iconBackgroundColor: const Color(0xFFDBEAFE),
                                iconColor: const Color(0xFF2563EB),
                                title: l10n.createRetailerAccount,
                                subtitle: l10n.joinMarketplace,
                              ),
                              const SizedBox(height: 28),

                              Text(l10n.fullName),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _fullNameController,
                                hintText: 'John Doe',
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: l10n.fullName,
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(l10n.storeName),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _storeNameController,
                                hintText: 'ABC Store',
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: l10n.storeName,
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(l10n.phoneNumber),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _phoneNumberController,
                                hintText: '+961 70 123 456',
                                keyboardType: TextInputType.phone,
                                validator: _validateLebanesePhone,
                              ),

                              const SizedBox(height: 16),

                              Text(l10n.email),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _emailController,
                                hintText: 'your.email@example.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email,
                              ),

                              const SizedBox(height: 16),

                              Text(l10n.password),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: Validators.password,

                                decoration: InputDecoration(
                                  hintText: '******',
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
                              const SizedBox(height: 16),

                              Text(l10n.confirmPassword),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                validator: (value) =>
                                    Validators.confirmPassword(
                                      value,
                                      _passwordController.text.trim(),
                                    ),
                                decoration: InputDecoration(
                                  hintText: '******',
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
                              const SizedBox(height: 16),

                              Text(l10n.storeAddress),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _storeAddressController,
                                hintText: '123 Main Street',
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: l10n.storeAddress,
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(l10n.city),
                              const SizedBox(height: 8),
                              PrimaryDropdownField<String>(
                                value: _selectedCity,
                                hintText: l10n.selectCity,
                                items: _cities
                                    .map(
                                      (city) => DropdownMenuItem(
                                        value: city.value,
                                        child: Text(
                                          context.trOption(city.labelKey),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCity = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '${l10n.city} is required';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              Text(l10n.businessType),
                              const SizedBox(height: 8),
                              PrimaryDropdownField<String>(
                                value: _selectedBusinessType,
                                hintText: l10n.selectBusinessType,
                                items: _businessTypes
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type.value,
                                        child: Text(
                                          context.trOption(type.labelKey),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBusinessType = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '${l10n.businessType} is required';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              PrimaryButton(
                                text: l10n.createAccount,
                                isLoading: state.isLoading,
                                onPressed: () => _submit(cubit),
                              ),

                              const SizedBox(height: 18),

                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text('${l10n.alreadyHaveAccount} '),
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Text(
                                      l10n.login,
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

                              const SizedBox(height: 8),
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
