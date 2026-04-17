import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_dropdown_field.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/select_option_l10n_extension.dart';
import '../../../../core/models/select_option.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/login_request_model.dart';

class RetailerSignupScreen extends StatefulWidget {
  const RetailerSignupScreen({super.key});

  @override
  State<RetailerSignupScreen> createState() => _RetailerSignupScreenState();
}

class _RetailerSignupScreenState extends State<RetailerSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _storeNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _storeAddressController;
  late final TextEditingController _verificationCodeController;

  String? _selectedCity;
  String? _selectedBusinessType;

  bool _isLoading = false;
  bool _verificationSent = false;

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
    SelectOption(value: 'Other', labelKey: 'businessOther'),
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _storeNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _storeAddressController = TextEditingController();
    _verificationCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _storeNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _storeAddressController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _sendVerification() async {
   

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await sl<AuthService>().sendBuild4AllVerification(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _verificationSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _splitName(String fullName) {
    final cleaned = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return ['', ''];
    final parts = cleaned.split(' ');
    if (parts.length == 1) return [parts.first, '.'];
    return [parts.first, parts.sublist(1).join(' ')];
  }

  Future<void> _completeSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_verificationSent) return;

    setState(() => _isLoading = true);

    try {
      final names = _splitName(_fullNameController.text);
      final firstName = names[0];
      final lastName = names[1];

      final pendingId = await sl<AuthService>().verifyBuild4AllEmailCode(
        email: _emailController.text.trim(),
        code: _verificationCodeController.text.trim(),
      );

      final completed = await sl<AuthService>().completeBuild4AllProfile(
        pendingId: pendingId,
        username: _usernameController.text.trim(),
        firstName: firstName,
        lastName: lastName,
        isPublicProfile: false,
      );

      final user = Map<String, dynamic>.from(completed['user'] as Map);
      final build4allUserId = user['id'] is int
          ? user['id'] as int
          : int.parse(user['id'].toString());

      await sl<AuthService>().syncRetailerFromBuild4All(
        build4allUserId: build4allUserId,
        username: _usernameController.text.trim(),
        firstName: firstName,
        lastName: lastName,
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        password: _passwordController.text.trim(),
        storeName: _storeNameController.text.trim(),
        storeAddress: _storeAddressController.text.trim(),
        city: _selectedCity!,
        businessType: _selectedBusinessType!,
      );

      final localLogin = await sl<AuthService>().login(
        LoginRequestModel(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );

      if (localLogin.token != null && localLogin.token!.isNotEmpty) {
        await sl<AuthStorage>().saveSession(
          token: localLogin.token!,
          userId: localLogin.userId,
          role: localLogin.role,
          profileCompleted: localLogin.profileCompleted,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retailer account created successfully')),
      );

      context.go('/retailer-dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(' ', '');
    final lebanesePhoneRegex = RegExp(
      r'^(\+961|0)?(3|70|71|76|78|79|81)\d{6}$',
    );

    if (!lebanesePhoneRegex.hasMatch(cleaned)) {
      return context.l10n.enterValidLebanesePhone;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        title: Text(l10n.createRetailerAccount),
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
                        Center(
                          child: Text(
                            l10n.joinMarketplace,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppThemeTokens.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(l10n.fullName),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _fullNameController,
                          hintText: l10n.fullName,
                          validator: (value) =>
                              Validators.requiredField(value, fieldName: l10n.fullName),
                        ),

                        const SizedBox(height: 16),

                        Text('Username'),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _usernameController,
                          hintText: 'username',
                          validator: (value) =>
                              Validators.requiredField(value, fieldName: 'Username'),
                        ),

                        const SizedBox(height: 16),

                        Text(l10n.storeName),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _storeNameController,
                          hintText: l10n.storeName,
                          validator: (value) =>
                              Validators.requiredField(value, fieldName: l10n.storeName),
                        ),

                        const SizedBox(height: 16),

                        Text(l10n.phoneNumber),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _phoneNumberController,
                          hintText: '+961 76 123 456',
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 16),

                        Text(l10n.email),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _emailController,
                          hintText: l10n.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),

                        const SizedBox(height: 16),

                        Text(l10n.password),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _passwordController,
                          hintText: l10n.password,
                          obscureText: true,
                          validator: Validators.password,
                        ),

                        const SizedBox(height: 16),

                        Text(l10n.confirmPassword),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _confirmPasswordController,
                          hintText: l10n.confirmPassword,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '${l10n.confirmPassword} is required';
                            }
                            if (value.trim() != _passwordController.text.trim()) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        Text(l10n.storeAddress),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _storeAddressController,
                          hintText: l10n.storeAddress,
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
                                (city) => DropdownMenuItem<String>(
                                  value: city.value,
                                  child: Text(context.trOption(city.labelKey)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedCity = value);
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
                                (type) => DropdownMenuItem<String>(
                                  value: type.value,
                                  child: Text(context.trOption(type.labelKey)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedBusinessType = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${l10n.businessType} is required';
                            }
                            return null;
                          },
                        ),

                        if (_verificationSent) ...[
                          const SizedBox(height: 16),
                          Text('Verification code'),
                          const SizedBox(height: 8),
                          PrimaryTextField(
                            controller: _verificationCodeController,
                            hintText: 'Enter the code sent to your email',
                            validator: (value) {
                              if (!_verificationSent) return null;
                              if (value == null || value.trim().isEmpty) {
                                return 'Verification code is required';
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 28),

                        if (!_verificationSent)
                          PrimaryButton(
                            text: 'Send verification code',
                            isLoading: _isLoading,
                            onPressed: _sendVerification,
                          )
                        else
                          PrimaryButton(
                            text: l10n.createAccount,
                            isLoading: _isLoading,
                            onPressed: _completeSignup,
                          ),

                        const SizedBox(height: 16),

                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(l10n.alreadyHaveAccount),
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