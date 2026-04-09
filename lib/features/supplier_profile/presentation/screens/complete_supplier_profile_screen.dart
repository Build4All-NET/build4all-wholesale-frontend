import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_dropdown_field.dart';
import '../../../../common/widgets/primary_text_field.dart';
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
    'Building Materials',
    'Electrical Supplies',
    'Plumbing',
    'Tools & Hardware',
    'Industrial Equipment',
    'Home Improvement',
    'Wholesale Distribution',
    'Other',
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

  Future<void> _submit(SupplierProfileCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await sl<AuthStorage>().getUserId();

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User session not found. Please login again.')),
      );
      return;
    }

    await cubit.createSupplierProfile(
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

  String? _validateLebanesePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(' ', '');
    final lebanesePhoneRegex =
        RegExp(r'^(\+961|0)?(3|70|71|76|78|79|81)\d{6}$');

    if (!lebanesePhoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid Lebanese phone number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupplierProfileCubit>(),
      child: BlocConsumer<SupplierProfileCubit, SupplierProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context.read<SupplierProfileCubit>().clearMessages();
          }

          if (state.success && state.profile != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Supplier profile completed successfully')),
            );
            context.read<SupplierProfileCubit>().clearMessages();
            context.go('/dashboard');
          }
        },
        builder: (context, state) {
          final cubit = context.read<SupplierProfileCubit>();

          return Scaffold(
            backgroundColor: AppThemeTokens.background,
            appBar: AppBar(
              title: const Text('Supplier Manager'),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 82,
                                  height: 82,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDCFCE7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.business_outlined,
                                    size: 38,
                                    color: AppThemeTokens.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Center(
                                child: Text(
                                  'Complete Supplier Profile',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppThemeTokens.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Center(
                                child: Text(
                                  'Complete your profile to start managing your business',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppThemeTokens.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              const Text(
                                'Company Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 18),

                              const Text('Company Name *'),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _companyNameController,
                                hintText: 'Your Company Name',
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: 'Company name',
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text('Company Address *'),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _companyAddressController,
                                hintText: 'Your business address',
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: 'Company address',
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text('Phone Number *'),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _phoneNumberController,
                                hintText: '+961 70 123 456',
                                keyboardType: TextInputType.phone,
                                validator: _validateLebanesePhone,
                              ),

                              const SizedBox(height: 16),

                              const Text('City *'),
                              const SizedBox(height: 8),
                              PrimaryDropdownField<String>(
                                value: _selectedCity,
                                hintText: 'Select your city',
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
                                hintText: 'Select your business type',
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

                              const Text(
                                'Business Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 18),

                              const Text('Business Description *'),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _descriptionController,
                                hintText: 'Tell us about your business and what you offer',
                                maxLines: 5,
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: 'Business description',
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text('Logo URL'),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _logoUrlController,
                                hintText: 'https://example.com/logo.png',
                                keyboardType: TextInputType.url,
                                validator: (_) => null,
                              ),

                              const SizedBox(height: 28),

                              PrimaryButton(
                                text: 'Complete Profile',
                                isLoading: state.isLoading,
                                onPressed: () => _submit(cubit),
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
