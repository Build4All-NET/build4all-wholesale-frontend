import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

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

  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _deletePasswordController;

  final FocusNode _phoneFocusNode = FocusNode();

  String? _selectedCity;
  String _originalEmail = '';
  String _initialCountryCode = 'LB';
  String _fullPhone = '';
  bool _filledOnce = false;
  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;

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

    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
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

    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _deletePasswordController.dispose();

    _phoneFocusNode.dispose();

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
    _addressController.text = profile.business.storeAddress;
    _businessTypeController.text = profile.business.businessType;

    final phone = profile.business.phoneNumber.trim();
    _fullPhone = phone;

    if (phone.isNotEmpty) {
      try {
        final parsed = PhoneNumber.fromCompleteNumber(completeNumber: phone);
        _initialCountryCode = parsed.countryISOCode;
        _phoneController.text = parsed.number;
        _fullPhone = parsed.completeNumber;
      } catch (_) {
        _initialCountryCode = 'LB';
        _phoneController.text = phone.replaceAll('+', '');
      }
    }

    _selectedCity = profile.business.city.trim().isEmpty
        ? null
        : profile.business.city.trim();

    _filledOnce = true;
  }

  String? _validateName(String? value, String fieldName) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return '$fieldName is required';
    }

    if (text.length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    final validNameRegex = RegExp(r'^[A-Za-zÀ-ÖØ-öø-ÿ\u0600-\u06FF ]+$');

    if (!validNameRegex.hasMatch(text)) {
      return '$fieldName cannot contain numbers or special characters';
    }

    return null;
  }

  String _normalizePhone(String value) {
    var cleaned = value.trim();

    cleaned = cleaned
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('.', '');

    if (cleaned.startsWith('00')) {
      cleaned = '+${cleaned.substring(2)}';
    }

    return cleaned;
  }

  String? _validateInternationalPhone(String? value) {
    final phone = _normalizePhone(
      _fullPhone.isNotEmpty ? _fullPhone : value ?? '',
    );

    if (phone.isEmpty) {
      return '${context.l10n.phoneNumber} is required';
    }

    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone)) {
      return 'Enter a valid phone number with country code';
    }

    return null;
  }

  Future<void> _hideKeyboardSafely() async {
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 220));
  }

  String _cleanError(Object error, String fallback) {
    final text = error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('AppException: ', '')
        .trim();

    return text.isEmpty ? fallback : text;
  }

  Future<bool> _showEmailVerificationSheet({
    required String email,
  }) async {
    final repository =
        context.read<RetailerProfileCubit>().retailerProfileRepository;

    String codeText = '';
    String? localError;
    bool localLoading = false;

    Future<void> closeSheet(BuildContext sheetContext, bool value) async {
      await _hideKeyboardSafely();

      if (!sheetContext.mounted) return;

      Navigator.of(sheetContext).pop(value);
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final colorScheme = Theme.of(sheetContext).colorScheme;
            final canVerify = codeText.trim().length == 6 && !localLoading;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                top: 16,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Icon(
                          Icons.mark_email_read_outlined,
                          color: colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      title: const Text(
                        'Verify new email',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      enabled: !localLoading,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (!sheetContext.mounted) return;

                        setSheetState(() {
                          codeText = value.trim();
                          localError = null;
                        });
                      },
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '6-digit code',
                      ),
                    ),
                    if (localError != null &&
                        localError!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          localError!,
                          style: const TextStyle(
                            color: AppThemeTokens.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: localLoading
                                ? null
                                : () async {
                                    await closeSheet(sheetContext, false);
                                  },
                            child: const Text(
                              'Cancel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: localLoading
                                ? null
                                : () async {
                                    await _hideKeyboardSafely();

                                    if (!sheetContext.mounted) return;

                                    setSheetState(() {
                                      localLoading = true;
                                      localError = null;
                                    });

                                    try {
                                      await repository.resendEmailChangeCode();

                                      if (!sheetContext.mounted) return;

                                      setSheetState(() {
                                        localLoading = false;
                                        localError = 'Verification code sent.';
                                      });
                                    } catch (e) {
                                      if (!sheetContext.mounted) return;

                                      setSheetState(() {
                                        localLoading = false;
                                        localError = _cleanError(
                                          e,
                                          'Could not resend code.',
                                        );
                                      });
                                    }
                                  },
                            child: const Text(
                              'Resend',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: !canVerify
                            ? null
                            : () async {
                                await _hideKeyboardSafely();

                                if (!sheetContext.mounted) return;

                                setSheetState(() {
                                  localLoading = true;
                                  localError = null;
                                });

                                try {
                                  await repository.verifyEmailChange(
                                    code: codeText.trim(),
                                  );

                                  if (!sheetContext.mounted) return;

                                  await closeSheet(sheetContext, true);
                                } catch (e) {
                                  if (!sheetContext.mounted) return;

                                  setSheetState(() {
                                    localLoading = false;
                                    localError = _cleanError(
                                      e,
                                      'Invalid verification code.',
                                    );
                                  });
                                }
                              },
                        child: localLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Verify',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    await _hideKeyboardSafely();

    return result == true;
  }

  Future<bool> _showPasswordVerificationSheet({
    required String email,
    required String newPassword,
  }) async {
    final repository =
        context.read<RetailerProfileCubit>().retailerProfileRepository;

    String codeText = '';
    String? localError;
    bool localLoading = false;

    Future<void> closeSheet(BuildContext sheetContext, bool value) async {
      await _hideKeyboardSafely();

      if (!sheetContext.mounted) return;

      Navigator.of(sheetContext).pop(value);
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final colorScheme = Theme.of(sheetContext).colorScheme;
            final canVerify = codeText.trim().length == 6 && !localLoading;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                top: 16,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Icon(
                          Icons.lock_reset_outlined,
                          color: colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      title: const Text(
                        'Verify password change',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        'Enter the 6-digit code sent to $email',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      enabled: !localLoading,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (!sheetContext.mounted) return;

                        setSheetState(() {
                          codeText = value.trim();
                          localError = null;
                        });
                      },
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '6-digit code',
                      ),
                    ),
                    if (localError != null &&
                        localError!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          localError!,
                          style: const TextStyle(
                            color: AppThemeTokens.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: localLoading
                                ? null
                                : () async {
                                    await closeSheet(sheetContext, false);
                                  },
                            child: const Text(
                              'Cancel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: localLoading
                                ? null
                                : () async {
                                    await _hideKeyboardSafely();

                                    if (!sheetContext.mounted) return;

                                    setSheetState(() {
                                      localLoading = true;
                                      localError = null;
                                    });

                                    try {
                                      await repository.sendPasswordResetCode(
                                        email: email,
                                      );

                                      if (!sheetContext.mounted) return;

                                      setSheetState(() {
                                        localLoading = false;
                                        localError =
                                            'Password verification code sent.';
                                      });
                                    } catch (e) {
                                      if (!sheetContext.mounted) return;

                                      setSheetState(() {
                                        localLoading = false;
                                        localError = _cleanError(
                                          e,
                                          'Could not resend code.',
                                        );
                                      });
                                    }
                                  },
                            child: const Text(
                              'Resend',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: !canVerify
                            ? null
                            : () async {
                                await _hideKeyboardSafely();

                                if (!sheetContext.mounted) return;

                                setSheetState(() {
                                  localLoading = true;
                                  localError = null;
                                });

                                try {
                                  final code = codeText.trim();

                                  await repository.verifyPasswordResetCode(
                                    email: email,
                                    code: code,
                                  );

                                  await repository.updatePasswordWithCode(
                                    email: email,
                                    code: code,
                                    newPassword: newPassword,
                                  );

                                  if (!sheetContext.mounted) return;

                                  await closeSheet(sheetContext, true);
                                } catch (e) {
                                  if (!sheetContext.mounted) return;

                                  setSheetState(() {
                                    localLoading = false;
                                    localError = _cleanError(
                                      e,
                                      'Could not update password.',
                                    );
                                  });
                                }
                              },
                        child: localLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Verify',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    await _hideKeyboardSafely();

    return result == true;
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

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    final passwordRequested =
        currentPassword.isNotEmpty || newPassword.isNotEmpty;

    if (passwordRequested) {
      if (currentPassword.isEmpty) {
        _showMessage(l10n.currentPasswordRequired);
        return;
      }

      if (newPassword.isEmpty) {
        _showMessage('${l10n.newPassword} is required');
        return;
      }

      if (newPassword.length < 6) {
        _showMessage(l10n.passwordMinLength);
        return;
      }

      final currentPasswordOk = await cubit.validateCurrentPassword(
        currentPassword: currentPassword,
      );

      if (!mounted) return;

      if (!currentPasswordOk) {
        _showCubitError(cubit);
        return;
      }

      final sent = await cubit.sendPasswordResetCode(
        email: _originalEmail,
      );

      if (!mounted) return;

      if (!sent) {
        _showCubitError(cubit);
        return;
      }

      _showMessage('Password verification code sent');

      final passwordVerified = await _showPasswordVerificationSheet(
        email: _originalEmail,
        newPassword: newPassword,
      );

      if (!mounted) return;

      if (!passwordVerified) {
        _showMessage(
          'Password was not updated because the verification code was not confirmed.',
        );
        return;
      }

      _currentPasswordController.clear();
      _newPasswordController.clear();
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

    if (emailChanged) {
      if (!accountResult.emailVerificationRequired) {
        _showMessage(
          'Email verification is required before updating the email.',
        );
        return;
      }

      _showMessage('Verification code sent');

      final verified = await _showEmailVerificationSheet(
        email: currentEmail,
      );

      if (!mounted) return;

      if (!verified) {
        _emailController.text = _originalEmail;

        await cubit.loadProfile();

        if (!mounted) return;

        _showMessage(
          'Email was not updated because the verification code was not confirmed.',
        );

        return;
      }

      _originalEmail = currentEmail.toLowerCase();
    }

    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();

    final businessUpdated = await cubit.updateBusinessInfo(
      fullName: fullName,
      storeName: _storeNameController.text.trim(),
      phoneNumber: _normalizePhone(_fullPhone),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    });
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

    final deleted = await cubit.deleteAccount(
      password: password,
    );

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
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(
                                      r'[A-Za-zÀ-ÖØ-öø-ÿ\u0600-\u06FF ]',
                                    ),
                                  ),
                                ],
                                validator: (value) =>
                                    _validateName(value, l10n.firstName),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PrimaryTextField(
                                controller: _lastNameController,
                                hintText: l10n.lastName,
                                prefixIcon: const Icon(Icons.person_outline),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(
                                      r'[A-Za-zÀ-ÖØ-öø-ÿ\u0600-\u06FF ]',
                                    ),
                                  ),
                                ],
                                validator: (value) =>
                                    _validateName(value, l10n.lastName),
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
                        IntlPhoneField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          initialCountryCode: _initialCountryCode,
                          disableLengthCheck: false,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: l10n.phoneNumber,
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                          validator: (phone) {
                            final value = phone?.completeNumber ?? _fullPhone;
                            return _validateInternationalPhone(value);
                          },
                          onChanged: (phone) {
                            _fullPhone = phone.number.trim().isEmpty
                                ? ''
                                : phone.completeNumber;
                          },
                          onCountryChanged: (_) {
                            _fullPhone = '';
                          },
                        ),
                        const SizedBox(height: 12),
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
                          controller: _currentPasswordController,
                          hintText: l10n.currentPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          obscureText: _hideCurrentPassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => _hideCurrentPassword =
                                    !_hideCurrentPassword,
                              );
                            },
                            icon: Icon(
                              _hideCurrentPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        PrimaryTextField(
                          controller: _newPasswordController,
                          hintText: l10n.newPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          obscureText: _hideNewPassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => _hideNewPassword = !_hideNewPassword,
                              );
                            },
                            icon: Icon(
                              _hideNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
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

  const _SectionTitle({
    required this.title,
  });

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