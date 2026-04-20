import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_dropdown_field.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/models/select_option.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../../data/services/auth_service.dart';

class CompleteRetailerProfileScreen extends StatefulWidget {
  const CompleteRetailerProfileScreen({super.key});

  @override
  State<CompleteRetailerProfileScreen> createState() =>
      _CompleteRetailerProfileScreenState();
}

class _CompleteRetailerProfileScreenState
    extends State<CompleteRetailerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _storeNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _storeAddressController;
  late final TextEditingController _fullNameController;

  String? _selectedCity;
  String? _selectedBusinessType;

  bool _isLoading = false;
  int? _userId;

  final List<SelectOption> _cities = const [
    SelectOption(value: 'Beirut', labelKey: 'Beirut'),
    SelectOption(value: 'Tripoli', labelKey: 'Tripoli'),
    SelectOption(value: 'Sidon', labelKey: 'Sidon'),
    SelectOption(value: 'Tyre', labelKey: 'Tyre'),
    SelectOption(value: 'Zahle', labelKey: 'Zahle'),
    SelectOption(value: 'Jounieh', labelKey: 'Jounieh'),
    SelectOption(value: 'Nabatieh', labelKey: 'Nabatieh'),
    SelectOption(value: 'Byblos', labelKey: 'Byblos'),
    SelectOption(value: 'Aley', labelKey: 'Aley'),
    SelectOption(value: 'Baalbek', labelKey: 'Baalbek'),
  ];

  final List<SelectOption> _businessTypes = const [
    SelectOption(value: 'Mini Market', labelKey: 'Mini Market'),
    SelectOption(value: 'Supermarket', labelKey: 'Supermarket'),
    SelectOption(value: 'Pharmacy', labelKey: 'Pharmacy'),
    SelectOption(value: 'Restaurant', labelKey: 'Restaurant'),
    SelectOption(value: 'Cafe', labelKey: 'Cafe'),
    SelectOption(value: 'Retail Shop', labelKey: 'Retail Shop'),
    SelectOption(value: 'Other', labelKey: 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _storeAddressController = TextEditingController();
    _fullNameController = TextEditingController();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _phoneNumberController.dispose();
    _storeAddressController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final current = await sl<AuthService>().getCurrentUser();
      _userId = current.userId;
      _fullNameController.text = current.fullName.isEmpty
          ? ''
          : current.fullName;
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCity == null || _selectedBusinessType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select city and business type'),
        ),
      );
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load current user'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await sl<AuthService>().updateRetailerProfile(
        userId: _userId!,
        fullName: _fullNameController.text.trim(),
        storeName: _storeNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        storeAddress: _storeAddressController.text.trim(),
        city: _selectedCity!,
        businessType: _selectedBusinessType!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retailer profile completed successfully')),
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
      return 'Enter a valid Lebanese phone number';
    }

    return null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        title: const Text('Complete Retailer Profile'),
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Complete your retailer profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppThemeTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your store information to continue.',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _label('Full Name'),
                        PrimaryTextField(
                          controller: _fullNameController,
                          hintText: 'Full name',
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: 'Full name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('Store Name'),
                        PrimaryTextField(
                          controller: _storeNameController,
                          hintText: 'ABC Store',
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: 'Store name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('Phone Number'),
                        PrimaryTextField(
                          controller: _phoneNumberController,
                          hintText: '+961 70 123 456',
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 16),
                        _label('Store Address'),
                        PrimaryTextField(
                          controller: _storeAddressController,
                          hintText: '123 Main Street',
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: 'Store address',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('City'),
                        PrimaryDropdownField<String>(
                          value: _selectedCity,
                          hintText: 'Select city',
                          items: _cities
                              .map(
                                (city) => DropdownMenuItem<String>(
                                  value: city.value,
                                  child: Text(city.value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedCity = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'City is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _label('Business Type'),
                        PrimaryDropdownField<String>(
                          value: _selectedBusinessType,
                          hintText: 'Select business type',
                          items: _businessTypes
                              .map(
                                (type) => DropdownMenuItem<String>(
                                  value: type.value,
                                  child: Text(type.value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedBusinessType = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Business type is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        PrimaryButton(
                          text: 'Save and continue',
                          isLoading: _isLoading,
                          onPressed: _save,
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