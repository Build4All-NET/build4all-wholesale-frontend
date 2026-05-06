import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
  late final TextEditingController _businessTypeController;

  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _deletePasswordController;

  String? _selectedCity;
  String _originalEmail = '';
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
    _businessTypeController = TextEditingController();

    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _deletePasswordController = TextEditingController();
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
    _businessTypeController.dispose();

    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deletePasswordController.dispose();

    super.dispose();
  }

  void _fillControllers(RetailerProfileState state) {
    if (_filledOnce || state.profile == null) return;

    final profile = state.profile!;

    _usernameController.text = profile.account.username;
    _firstNameController.text = profile.account.firstName;
    _lastNameController.text = profile.account.lastName;
    _emailController.text = profile.account.email;
    _originalEmail = profile.account.email.trim().toLowerCase();

    _storeNameController.text = profile.business.storeName;
    _phoneController.text = profile.business.phoneNumber;
    _addressController.text = profile.business.storeAddress;
    _businessTypeController.text = profile.business.businessType;

    _selectedCity = profile.business.city.trim().isEmpty
        ? null
        : profile.business.city.trim();

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

  Future<void> _save() async {
    final l10n = context.l10n;
    final cubit = context.read<RetailerProfileCubit>();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCity == null || _selectedCity!.trim().isEmpty) {
      _showMessage('${l10n.city} is required');
      return;
    }

    final currentEmail = _emailController.text.trim();
    final emailChanged = currentEmail.toLowerCase() != _originalEmail;

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final passwordRequested =
        newPassword.isNotEmpty || confirmPassword.isNotEmpty;

    if (passwordRequested) {
      if (newPassword.length < 6) {
        _showMessage(l10n.passwordMinLength);
        return;
      }

      if (newPassword != confirmPassword) {
        _showMessage(l10n.passwordsDoNotMatch);
        return;
      }
    }

    final accountResult = await cubit.updateAccountInfo(
      username: _usernameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      changedEmail: emailChanged ? currentEmail : null,
    );

    if (!mounted) return;

    if (accountResult == null) {
      _showCubitError(cubit);
      return;
    }

    if (emailChanged && accountResult.emailVerificationRequired) {
      final verified = await context.push<bool>(
        '/retailer-profile/verify-code',
        extra: {'mode': 'email', 'email': currentEmail, 'newPassword': null},
      );

      if (!mounted) return;

      if (verified != true) {
        _showMessage(l10n.emailVerificationRequired);
        return;
      }

      _originalEmail = currentEmail.toLowerCase();
      _showMessage(l10n.emailUpdatedSuccessfully);
    }

    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();

    final businessUpdated = await cubit.updateBusinessInfo(
      fullName: fullName,
      storeName: _storeNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      storeAddress: _addressController.text.trim(),
      city: _selectedCity!,
      businessType: _businessTypeController.text.trim(),
      successMessage: l10n.profileUpdatedSuccessfully,
    );

    if (!mounted) return;

    if (!businessUpdated) {
      _showCubitError(cubit);
      return;
    }

    if (passwordRequested) {
      final sent = await cubit.sendPasswordResetCode(email: currentEmail);

      if (!mounted) return;

      if (!sent) {
        _showCubitError(cubit);
        return;
      }

      final passwordUpdated = await context.push<bool>(
        '/retailer-profile/verify-code',
        extra: {
          'mode': 'password',
          'email': currentEmail,
          'newPassword': newPassword,
        },
      );

      if (!mounted) return;

      if (passwordUpdated != true) {
        _showMessage(l10n.passwordVerificationCodeSent);
        return;
      }

      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _showMessage(l10n.passwordUpdatedSuccessfully);
    }

    if (!mounted) return;

    _showMessage(l10n.profileUpdatedSuccessfully);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    context.go('/retailer-profile');
  }

  void _showCubitError(RetailerProfileCubit cubit) {
    final message = cubit.state.errorMessage;

    if (message != null && message.trim().isNotEmpty) {
      _showMessage(message);
      cubit.clearMessages();
    }
  }

  void _showMessage(String message) {
    if (!mounted || message.trim().isEmpty) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteAccount() async {
    final l10n = context.l10n;
    final cubit = context.read<RetailerProfileCubit>();

    final password = _deletePasswordController.text.trim();

    if (password.isEmpty) {
      _showMessage(l10n.currentPasswordRequired);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteAccountConfirmTitle),
          content: Text(l10n.deleteAccountConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeTokens.error,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    final deleted = await cubit.deleteAccount(password: password);

    if (!mounted) return;

    if (deleted) {
      _showMessage(l10n.accountDeletedSuccessfully);

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      context.go('/login');
    } else {
      _showCubitError(cubit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<RetailerProfileCubit, RetailerProfileState>(
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
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
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
                        const SizedBox(height: 12),

                        PrimaryTextField(
                          controller: _businessTypeController,
                          hintText: l10n.businessType,
                          prefixIcon: const Icon(
                            Icons.business_center_outlined,
                          ),
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: l10n.businessType,
                          ),
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

                        PrimaryTextField(
                          controller: _newPasswordController,
                          hintText: l10n.newPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),

                        PrimaryTextField(
                          controller: _confirmPasswordController,
                          hintText: l10n.confirmPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          obscureText: true,
                        ),

                        const SizedBox(height: 28),
                        PrimaryButton(
                          text: l10n.saveChanges,
                          isLoading: state.isSaving,
                          onPressed: _save,
                        ),

                        const SizedBox(height: 28),

                        _DangerZoneSection(
                          passwordController: _deletePasswordController,
                          isDeleting: state.isDeletingAccount,
                          onDelete: _deleteAccount,
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

class _DangerZoneSection extends StatelessWidget {
  final TextEditingController passwordController;
  final bool isDeleting;
  final VoidCallback onDelete;

  const _DangerZoneSection({
    required this.passwordController,
    required this.isDeleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.dangerZone,
            style: const TextStyle(
              color: AppThemeTokens.error,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemeTokens.error.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppThemeTokens.error.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppThemeTokens.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.deleteAccountWarningTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppThemeTokens.error,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.deleteAccountWarningMessage,
                style: const TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              PrimaryTextField(
                controller: passwordController,
                hintText: l10n.currentPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: true,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isDeleting ? null : onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeTokens.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppThemeTokens.error.withValues(
                      alpha: 0.55,
                    ),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.deleteAccount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
