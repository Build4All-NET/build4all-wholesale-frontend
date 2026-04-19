import 'package:flutter/material.dart';
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
import '../../data/services/auth_service.dart';

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

  bool _isLoading = false;
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
    SelectOption(value: 'Other', labelKey: 'businessOther'),
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

  void _logStep(String message) {
    debugPrint('========== RETAILER SIGNUP ==========');
    debugPrint(message);
    debugPrint('=====================================');
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

  List<String> _splitName(String fullName) {
    final cleaned = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return ['', ''];

    final parts = cleaned.split(' ');
    if (parts.length == 1) {
      return [parts.first, '.'];
    }

    return [parts.first, parts.sublist(1).join(' ')];
  }

  String _generateUsername({
    required String fullName,
    required String email,
  }) {
    final emailPrefix = email.split('@').first.trim().toLowerCase();
    final cleanedEmailPrefix =
        emailPrefix.replaceAll(RegExp(r'[^a-z0-9_]'), '');

    final cleanedName = fullName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');

    final base = cleanedName.isNotEmpty ? cleanedName : cleanedEmailPrefix;
    final suffix =
        DateTime.now().millisecondsSinceEpoch.toString().substring(8);

    final username = '${base}_$suffix';
    return username.length > 30 ? username.substring(0, 30) : username;
  }

  InputDecoration _passwordDecoration({
    required String hintText,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppThemeTokens.textSecondary,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: const BoxDecoration(
            color: Color(0xFFE7F0FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shopping_cart_checkout_outlined,
            size: 38,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.createRetailerAccount,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppThemeTokens.textPrimary,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.joinMarketplace,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppThemeTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<String?> _showVerificationCodeDialog() async {
    final controller = TextEditingController();

    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Verification code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the verification code sent to your email.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter code',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return code;
  }

  Future<void> _submitSignup() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCity == null || _selectedCity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city')),
      );
      return;
    }

    if (_selectedBusinessType == null || _selectedBusinessType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a business type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = sl<AuthService>();

      _logStep('STEP 1: send verification');
      await authService.sendBuild4AllVerification(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final verificationCode = await _showVerificationCodeDialog();

      if (verificationCode == null || verificationCode.isEmpty) {
        return;
      }

      if (!mounted) return;
      setState(() => _isLoading = true);

      _logStep('STEP 2: verify email code');
      final pendingId = await authService.verifyBuild4AllEmailCode(
        email: _emailController.text.trim(),
        code: verificationCode,
      );

      final names = _splitName(_fullNameController.text);
      final firstName = names[0];
      final lastName = names[1];

      final generatedUsername = _generateUsername(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      _logStep('STEP 3: complete Build4All profile');
      final completed = await authService.completeBuild4AllProfile(
        pendingId: pendingId,
        username: generatedUsername,
        firstName: firstName,
        lastName: lastName,
        isPublicProfile: false,
      );

      final user = Map<String, dynamic>.from(completed['user'] as Map);
      final build4allUserId = user['id'] is int
          ? user['id'] as int
          : int.parse(user['id'].toString());

      _logStep('STEP 4: sync retailer into wholesale backend');
      await authService.syncRetailerFromBuild4All(
        build4allUserId: build4allUserId,
        username: generatedUsername,
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please login.'),
        ),
      );

      context.go('/login');
    } catch (e) {
      _logStep('SIGNUP FAILED: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        _buildHeader(context),
                        const SizedBox(height: 28),

                        _label(l10n.fullName),
                        PrimaryTextField(
                          controller: _fullNameController,
                          hintText: 'John Doe',
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: l10n.fullName,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _label(l10n.storeName),
                        PrimaryTextField(
                          controller: _storeNameController,
                          hintText: 'ABC Store',
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: l10n.storeName,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _label(l10n.phoneNumber),
                        PrimaryTextField(
                          controller: _phoneNumberController,
                          hintText: '+961 70 123 456',
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        _label(l10n.email),
                        PrimaryTextField(
                          controller: _emailController,
                          hintText: 'your.email@example.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),

                        _label(l10n.password),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: Validators.password,
                          decoration: _passwordDecoration(
                            hintText: l10n.password,
                            obscure: _obscurePassword,
                            onToggle: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        _label(l10n.confirmPassword),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) => Validators.confirmPassword(
                            value,
                            _passwordController.text.trim(),
                          ),
                          decoration: _passwordDecoration(
                            hintText: l10n.confirmPassword,
                            obscure: _obscureConfirmPassword,
                            onToggle: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        _label(l10n.storeAddress),
                        PrimaryTextField(
                          controller: _storeAddressController,
                          hintText: '123 Main Street',
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: l10n.storeAddress,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _label(l10n.city),
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

                        _label(l10n.businessType),
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

                        const SizedBox(height: 28),

                        PrimaryButton(
                          text: l10n.createAccount,
                          isLoading: _isLoading,
                          onPressed: _submitSignup,
                        ),

                        const SizedBox(height: 18),

                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${l10n.alreadyHaveAccount} ',
                                style: const TextStyle(
                                  color: AppThemeTokens.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  l10n.login,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
  }
}