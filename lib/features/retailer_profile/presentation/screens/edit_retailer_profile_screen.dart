import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_dropdown_field.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/select_option_l10n_extension.dart';
import '../../../../core/models/select_option.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../cubit/retailer_profile_cubit.dart';
import '../cubit/retailer_profile_state.dart';

class EditRetailerProfileScreen extends StatelessWidget {
  const EditRetailerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerProfileCubit>()..loadProfile(),
      child: const _EditRetailerProfileView(),
    );
  }
}

class _EditRetailerProfileView extends StatefulWidget {
  const _EditRetailerProfileView();

  @override
  State<_EditRetailerProfileView> createState() =>
      _EditRetailerProfileViewState();
}

class _EditRetailerProfileViewState extends State<_EditRetailerProfileView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _storeNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String? _selectedCity;
  String? _selectedBusinessType;
  bool _filledOnce = false;

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
    _usernameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _storeNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _storeNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _fillControllers(RetailerProfileState state) {
    if (_filledOnce || state.profile == null) return;

    final profile = state.profile!;

    _usernameController.text = profile.account.username;
    _firstNameController.text = profile.account.firstName;
    _lastNameController.text = profile.account.lastName;
    _emailController.text = profile.account.email;

    _storeNameController.text = profile.business.storeName;
    _phoneController.text = profile.business.phoneNumber;
    _addressController.text = profile.business.storeAddress;
    _selectedCity = profile.business.city.isEmpty
        ? null
        : profile.business.city;
    _selectedBusinessType = profile.business.businessType.isEmpty
        ? null
        : profile.business.businessType;

    _filledOnce = true;
  }

  String? _validateLebanesePhone(String? value) {
    final l10n = context.l10n;

    if (value == null || value.trim().isEmpty) {
      return '${l10n.phoneNumber} is required';
    }

    final cleaned = value.replaceAll(' ', '');
    final regex = RegExp(r'^(\+961|0)?(3|70|71|76|78|79|81)\d{6}$');

    if (!regex.hasMatch(cleaned)) {
      return l10n.enterValidLebanesePhone;
    }

    return null;
  }

  void _save() {
    final l10n = context.l10n;

    if (!_formKey.currentState!.validate()) return;

    context.read<RetailerProfileCubit>().updateProfile(
      username: _usernameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      storeName: _storeNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      storeAddress: _addressController.text.trim(),
      city: _selectedCity!,
      businessType: _selectedBusinessType!,
      successMessage: l10n.profileUpdatedSuccessfully,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<RetailerProfileCubit, RetailerProfileState>(
      listener: (context, state) {
        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
          context.read<RetailerProfileCubit>().clearMessages();
        }

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<RetailerProfileCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        _fillControllers(state);

        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            title: Text(l10n.editProfile),
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
          ),
          body: state.isLoading && state.profile == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(
                    AppThemeTokens.screenHorizontalPadding,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _SectionTitle(title: l10n.accountInformation),
                        const SizedBox(height: 12),
                        PrimaryTextField(
                          controller: _usernameController,
                          hintText: l10n.username,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: l10n.username,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryTextField(
                                controller: _firstNameController,
                                hintText: l10n.firstName,
                                prefixIcon: const Icon(Icons.person_outline),
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: l10n.firstName,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PrimaryTextField(
                                controller: _lastNameController,
                                hintText: l10n.lastName,
                                prefixIcon: const Icon(Icons.person_outline),
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: l10n.lastName,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PrimaryTextField(
                          controller: _emailController,
                          hintText: l10n.email,
                          prefixIcon: const Icon(Icons.email_outlined),
                          readOnly: true,
                        ),
                        const SizedBox(height: 24),
                        _SectionTitle(title: l10n.businessInformation),
                        const SizedBox(height: 12),
                        PrimaryTextField(
                          controller: _storeNameController,
                          hintText: l10n.storeName,
                          prefixIcon: const Icon(Icons.storefront_outlined),
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: l10n.storeName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PrimaryTextField(
                          controller: _phoneController,
                          hintText: '+961 70 123 456',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          validator: _validateLebanesePhone,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryDropdownField<String>(
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
                                  setState(() => _selectedCity = value);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '${l10n.city} is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PrimaryDropdownField<String>(
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
                                  setState(() => _selectedBusinessType = value);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '${l10n.businessType} is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PrimaryTextField(
                          controller: _addressController,
                          hintText: l10n.address,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: l10n.address,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SectionTitle(title: l10n.changePasswordOptional),
                        const SizedBox(height: 12),
                        _PasswordInfoCard(
                          message: l10n.passwordManagedByBuild4All,
                        ),
                        const SizedBox(height: 28),
                        PrimaryButton(
                          text: l10n.saveChanges,
                          isLoading: state.isSaving,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PasswordInfoCard extends StatelessWidget {
  final String message;

  const _PasswordInfoCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
