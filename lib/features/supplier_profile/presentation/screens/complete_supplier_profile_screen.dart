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
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../bloc/supplier_profile_cubit.dart';
import '../bloc/supplier_profile_state.dart';

class CompleteSupplierProfileScreen extends StatefulWidget {
  const CompleteSupplierProfileScreen({super.key});

  @override
  State<CompleteSupplierProfileScreen> createState() =>
      _CompleteSupplierProfileScreenState();
}

class _CompleteSupplierProfileScreenState
    extends State<CompleteSupplierProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyNameController;
  late final TextEditingController _companyAddressController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _logoUrlController;

  String? _selectedCity;
  String? _selectedBusinessType;

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
    _companyNameController = TextEditingController();
    _companyAddressController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _descriptionController = TextEditingController();
    _logoUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
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

  Future<void> _submit(BuildContext context) async {
  FocusScope.of(context).unfocus();

  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please complete all required fields correctly.'),
      ),
    );
    return;
  }

  final userId = await sl<AuthStorage>().getUserId();

  if (!mounted) return;

  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.userSessionNotFound)),
    );
    return;
  }

  context.read<SupplierProfileCubit>().createSupplierProfile(
    userId: userId,
    companyName: _companyNameController.text.trim(),
    companyAddress: _companyAddressController.text.trim(),
    phoneNumber: _phoneNumberController.text.trim(),
    city: _selectedCity!,
    businessType: _selectedBusinessType!,
    description: _descriptionController.text.trim(),
    logoUrl: _logoUrlController.text.trim(),
  );
}

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (_) => sl<SupplierProfileCubit>(),
      child: BlocConsumer<SupplierProfileCubit, SupplierProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<SupplierProfileCubit>().clearMessages();
          }

          if (state.success && state.profile != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.supplierProfileSavedSuccessfully)),
            );
            context.read<SupplierProfileCubit>().clearMessages();
            context.go('/supplier-dashboard');
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppThemeTokens.background,
            appBar: AppBar(
              title: Text(l10n.completeSupplierProfile),
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
                                  Icons.business_outlined,
                                  size: 60,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  l10n.completeSupplierProfileTitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemeTokens.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  l10n.provideBusinessInfoToContinue,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppThemeTokens.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              Text(l10n.companyName),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _companyNameController,
                                hintText: l10n.enterCompanyName,
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: l10n.companyName,
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(l10n.companyAddress),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _companyAddressController,
                                hintText: l10n.enterCompanyAddress,
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: l10n.companyAddress,
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

                              Text(l10n.city),
                              const SizedBox(height: 8),
                              PrimaryDropdownField<String>(
                                value: _selectedCity,
                                hintText: l10n.selectCity,
                                items: _cities
                                    .map(
                                      (city) => DropdownMenuItem<String>(
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
                                      (type) => DropdownMenuItem<String>(
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

                              const SizedBox(height: 16),

                              Text(l10n.description),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _descriptionController,
                                hintText: l10n.tellAboutBusiness,
                                maxLines: 4,
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: l10n.description,
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(l10n.logoUrl),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _logoUrlController,
                                hintText: 'https://example.com/logo.png',
                                keyboardType: TextInputType.url,
                              ),

                              const SizedBox(height: 28),

                              PrimaryButton(
                                text: l10n.saveAndContinue,
                                isLoading: state.isLoading,
                                onPressed: () => _submit(context),
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