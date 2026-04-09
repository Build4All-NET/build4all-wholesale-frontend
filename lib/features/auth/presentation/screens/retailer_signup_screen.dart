import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_dropdown_field.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';

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

  final List<String> _cities = const [
  'Beirut',
  'Tripoli',
  'Sidon',
  'Tyre',
  'Zahle',
  'Jounieh',
  'Nabatieh',
  'Byblos',
  'Aley',
  'Baalbek',
];


  final List<String> _businessTypes = const [
    'Mini Market',
    'Supermarket',
    'Pharmacy',
    'Restaurant',
    'Cafe',
    'Retail Shop',
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
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

          return Scaffold(
            appBar: AppBar(
              title: const Text('Back to Login'),
              backgroundColor: AppThemeTokens.background,
              elevation: 0,
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
                        side: const BorderSide(
                          color: AppThemeTokens.border,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              const AuthHeader(
                                icon: Icons.shopping_cart_checkout_outlined,
                                iconBackgroundColor: Color(0xFFDBEAFE),
                                iconColor: Color(0xFF2563EB),
                                title: 'Create Retailer Account',
                                subtitle: 'Join our wholesale marketplace',
                              ),
                              const SizedBox(height: 28),

                              const Text('Full Name *'),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _fullNameController,
                                hintText: 'John Doe',
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: 'Full name',
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text('Store Name *'),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _storeNameController,
                                hintText: 'ABC Store',
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: 'Store name',
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text('Phone Number *'),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                  controller: _phoneNumberController,
                                  hintText: '+961 70 123 456',
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                 if (value == null || value.trim().isEmpty) {
                                               return 'Phone number is required';
                                             }

                                 final cleaned = value.replaceAll(' ', '');
                                 final lebanesePhoneRegex = RegExp(r'^(\+961|0)?(3|70|71|76|78|79|81)\d{6}$');

                                 if (!lebanesePhoneRegex.hasMatch(cleaned)) {
                                 return 'Enter a valid Lebanese phone number';
                                 }

                                return null;
                                },
                               ),


                              const SizedBox(height: 16),

                              const Text('Email *'),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _emailController,
                                hintText: 'your.email@example.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email,
                              ),

                              const SizedBox(height: 16),

                              const Text('Password *'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: Validators.password,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
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

                              const Text('Confirm Password *'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                validator: (value) => Validators.confirmPassword(
                                  value,
                                  _passwordController.text.trim(),
                                ),
                                decoration: InputDecoration(
                                  hintText: '••••••••',
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

                              const Text('Store Address *'),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _storeAddressController,
                                hintText: '123 Main Street',
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: 'Store address',
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text('City *'),
                              const SizedBox(height: 8),
                              PrimaryDropdownField<String>(
                                value: _selectedCity,
                                hintText: 'Select city',
                                items: _cities
                                    .map(
                                      (city) => DropdownMenuItem(
                                        value: city,
                                        child: Text(city),
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
                                    return 'City is required';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              const Text('Business Type *'),
                              const SizedBox(height: 8),
                              PrimaryDropdownField<String>(
                                value: _selectedBusinessType,
                                hintText: 'Select type',
                                items: _businessTypes
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
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
                                    return 'Business type is required';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              PrimaryButton(
                                text: 'Create Account',
                                isLoading: state.isLoading,
                                onPressed: () => _submit(cubit),
                              ),

                              const SizedBox(height: 18),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Already have an account? '),
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: AppThemeTokens.primary,
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

