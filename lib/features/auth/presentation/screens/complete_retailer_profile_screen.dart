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

class CompleteRetailerProfileScreen extends StatefulWidget {
  const CompleteRetailerProfileScreen({super.key});

  @override
  State<CompleteRetailerProfileScreen> createState() =>
      _CompleteRetailerProfileScreenState();
}

class _CompleteRetailerProfileScreenState
    extends State<CompleteRetailerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _storeNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _storeAddressController;

  String? _selectedCity;
  String? _selectedBusinessType;
  bool _isLoading = false;

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
    SelectOption(
      value: 'Building Materials',
      labelKey: 'businessBuildingMaterials',
    ),
    SelectOption(
      value: 'Electrical Supplies',
      labelKey: 'businessElectricalSupplies',
    ),
    SelectOption(value: 'Plumbing', labelKey: 'businessPlumbing'),
    SelectOption(value: 'Tools & Hardware', labelKey: 'businessToolsHardware'),
    SelectOption(
      value: 'Industrial Equipment',
      labelKey: 'businessIndustrialEquipment',
    ),
    SelectOption(
      value: 'Home Improvement',
      labelKey: 'businessHomeImprovement',
    ),
    SelectOption(
      value: 'Wholesale Distribution',
      labelKey: 'businessWholesaleDistribution',
    ),
    SelectOption(value: 'Other', labelKey: 'businessOther'),
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _storeNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _storeAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _storeNameController.dispose();
    _phoneNumberController.dispose();
    _storeAddressController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await sl<AuthService>().updateRetailerProfile(
        fullName: _fullNameController.text.trim(),
        storeName: _storeNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        storeAddress: _storeAddressController.text.trim(),
        city: _selectedCity!,
        businessType: _selectedBusinessType!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retailer profile saved successfully')),
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        title: const Text('Complete Retailer Profile'),
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
                          child: Icon(
                            Icons.storefront_outlined,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'Complete Retailer Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppThemeTokens.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Provide your business information to continue.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: AppThemeTokens.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        const Text('Full Name'),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _fullNameController,
                          hintText: 'Enter your full name',
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: 'Full Name',
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text('Store Name'),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _storeNameController,
                          hintText: 'Enter store name',
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: 'Store Name',
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

                        const Text('Store Address'),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _storeAddressController,
                          hintText: 'Enter store address',
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: 'Store Address',
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
                                (type) => DropdownMenuItem<String>(
                                  value: type.value,
                                  child: Text(context.trOption(type.labelKey)),
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

                        const SizedBox(height: 28),

                        PrimaryButton(
                          text: l10n.saveAndContinue,
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
