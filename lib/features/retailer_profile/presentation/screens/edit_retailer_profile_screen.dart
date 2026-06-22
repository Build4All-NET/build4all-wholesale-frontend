import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/location/data/models/country_model.dart';
import '../../../../core/location/data/models/region_model.dart';
import '../../../../core/location/data/services/location_api_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/searchable_selection_field.dart';
import '../../../../injection_container.dart';
import '../../data/models/retailer_profile_model.dart';
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

  late final LocationApiService _locationApiService;

  final FocusNode _phoneFocusNode = FocusNode();

  List<CountryModel> _countries = [];
  List<RegionModel> _cities = [];

  CountryModel? _selectedCountry;
  RegionModel? _selectedCity;

  String _originalEmail = '';
  String _originalPhone = '';
  String _initialCountryCode = 'LB';
  String _fullPhone = '';

  bool _filledOnce = false;
  bool _isLocationSyncScheduled = false;
  bool _locationEditedByUser = false;
  bool _didLoadSavedCities = false;
  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _isLoadingCountries = true;
  bool _isLoadingCities = false;

  String? _locationError;

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

    _locationApiService = LocationApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    );

    _loadCountries();
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

  Future<void> _loadCountries() async {
    if (mounted) {
      setState(() {
        _isLoadingCountries = true;
        _locationError = null;
      });
    }

    try {
      final countries = await _locationApiService.getCountries();

      if (!mounted) return;

      setState(() {
        _countries = countries;
        _isLoadingCountries = false;
      });

      _scheduleLocationSyncFromProfile();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingCountries = false;
        _locationError = _cleanError(e, context.l10n.couldNotLoadCountries);
      });
    }
  }

  Future<void> _loadCitiesForCountry(
    CountryModel country, {
    String? cityToSelect,
  }) async {
    if (!mounted) return;

    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _selectedCity = null;
      _locationError = null;
    });

    try {
      final cities = await _locationApiService.getRegionsByCountry(country.id);

      if (!mounted) return;

      final selectedCity = _findCityFromList(cities, cityToSelect, country);

      setState(() {
        _cities = cities;
        _selectedCity = selectedCity;
        _isLoadingCities = false;
      });
    } catch (e) {
      if (!mounted) return;

      final fallbackCity = _createFallbackCityFromSavedValue(
        cityToSelect,
        country,
      );

      setState(() {
        _isLoadingCities = false;
        _selectedCity = fallbackCity;
        _cities = fallbackCity == null ? [] : [fallbackCity];
        _locationError = _cleanError(e, context.l10n.couldNotLoadCities);
      });
    }
  }

  void _scheduleLocationSyncFromProfile() {
    if (_isLocationSyncScheduled) return;

    _isLocationSyncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLocationSyncScheduled = false;

      if (!mounted) return;

      _syncSelectedLocationFromProfile();
    });
  }

  void _syncSelectedLocationFromProfile() {
    if (!mounted || _locationEditedByUser || _countries.isEmpty) return;

    final profile = context.read<RetailerProfileCubit>().state.profile;
    if (profile == null) return;

    final country = _findCountryFromProfile(profile.business);
    if (country == null) return;

    final shouldLoadCities =
        !_didLoadSavedCities || _selectedCountry?.id != country.id;

    setState(() {
      _selectedCountry = country;

      if (!_countries.any((item) => item.id == country.id)) {
        _countries = [country, ..._countries];
      }

      if (country.iso2Code.trim().isNotEmpty) {
        _initialCountryCode = country.iso2Code.trim().toUpperCase();
      }
    });

    if (shouldLoadCities) {
      _didLoadSavedCities = true;
      _loadCitiesForCountry(country, cityToSelect: profile.business.city);
    }
  }

  void _seedSavedLocationFromProfile(RetailerBusinessProfileModel business) {
    final savedCountry = _findCountryFromProfile(business);

    if (_selectedCountry == null && savedCountry != null) {
      _selectedCountry = savedCountry;

      if (!_countries.any((item) => item.id == savedCountry.id)) {
        _countries = [savedCountry, ..._countries];
      }

      if (savedCountry.iso2Code.trim().isNotEmpty) {
        _initialCountryCode = savedCountry.iso2Code.trim().toUpperCase();
      }
    }

    if (_selectedCity == null &&
        _selectedCountry != null &&
        business.city.trim().isNotEmpty) {
      final savedCity = _createFallbackCityFromSavedValue(
        business.city,
        _selectedCountry!,
      );

      if (savedCity != null) {
        _selectedCity = savedCity;

        if (!_cities.any(
          (item) =>
              item.id == savedCity.id &&
              _normalizeLocationName(item.name) ==
                  _normalizeLocationName(savedCity.name),
        )) {
          _cities = [savedCity, ..._cities];
        }
      }
    }
  }

  String _normalizeLocationName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  CountryModel? _findCountryFromProfile(RetailerBusinessProfileModel business) {
    final countryId = business.countryId;
    final countryIso2 = business.countryIso2Code.trim().toUpperCase();
    final countryIso3 = business.countryIso3Code.trim().toUpperCase();
    final countryName = _normalizeLocationName(business.countryName);

    if (countryId != null && countryId > 0) {
      for (final country in _countries) {
        if (country.id == countryId) return country;
      }
    }

    if (countryIso2.isNotEmpty) {
      for (final country in _countries) {
        if (country.iso2Code.trim().toUpperCase() == countryIso2) {
          return country;
        }
      }
    }

    if (countryIso3.isNotEmpty) {
      for (final country in _countries) {
        if (country.iso3Code.trim().toUpperCase() == countryIso3) {
          return country;
        }
      }
    }

    if (countryName.isNotEmpty) {
      for (final country in _countries) {
        if (_normalizeLocationName(country.name) == countryName) {
          return country;
        }
      }
    }

    if ((countryId != null && countryId > 0) ||
        business.countryName.trim().isNotEmpty ||
        countryIso2.isNotEmpty ||
        countryIso3.isNotEmpty) {
      return CountryModel(
        id: countryId ?? 0,
        iso2Code: countryIso2,
        iso3Code: countryIso3,
        name: business.countryName.trim().isNotEmpty
            ? business.countryName.trim()
            : countryIso2.isNotEmpty
            ? countryIso2
            : countryIso3,
        active: true,
      );
    }

    return null;
  }

  RegionModel? _findCityFromList(
    List<RegionModel> cities,
    String? cityToSelect,
    CountryModel country,
  ) {
    final savedCity = cityToSelect?.trim() ?? '';
    if (savedCity.isEmpty) return null;

    final normalizedSavedCity = _normalizeLocationName(savedCity);

    for (final city in cities) {
      if (_normalizeLocationName(city.name) == normalizedSavedCity) {
        return city;
      }
    }

    for (final city in cities) {
      if (_normalizeLocationName(city.code) == normalizedSavedCity) {
        return city;
      }
    }

    return _createFallbackCityFromSavedValue(savedCity, country);
  }

  RegionModel? _createFallbackCityFromSavedValue(
    String? cityToSelect,
    CountryModel country,
  ) {
    final savedCity = cityToSelect?.trim() ?? '';
    if (savedCity.isEmpty) return null;

    return RegionModel(
      id: 0,
      code: savedCity,
      name: savedCity,
      active: true,
      countryId: country.id,
      countryIso2Code: country.iso2Code,
      countryIso3Code: country.iso3Code,
      countryName: country.name,
    );
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
    _originalPhone = _normalizePhone(phone);

    if (profile.business.countryIso2Code.trim().isNotEmpty) {
      _initialCountryCode = profile.business.countryIso2Code
          .trim()
          .toUpperCase();
    }

    if (phone.isNotEmpty) {
      try {
        final parsed = PhoneNumber.fromCompleteNumber(completeNumber: phone);
        _initialCountryCode = parsed.countryISOCode;
        _phoneController.text = parsed.number;
        _fullPhone = parsed.completeNumber;
      } catch (_) {
        _phoneController.text = phone.replaceAll('+', '');
      }
    }

    _seedSavedLocationFromProfile(profile.business);

    _filledOnce = true;

    _scheduleLocationSyncFromProfile();
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
      return context.l10n.validPhoneForSelectedCountryError;
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

  Future<bool> _showEmailVerificationSheet({required String email}) async {
    final l10n = context.l10n;
    final repository = context
        .read<RetailerProfileCubit>()
        .retailerProfileRepository;

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
                      title: Text(
                        l10n.verifyNewEmail,
                        style: const TextStyle(
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (!sheetContext.mounted) return;

                        setSheetState(() {
                          codeText = value.trim();
                          localError = null;
                        });
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: l10n.sixDigitCode,
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
                            child: Text(
                              l10n.cancel,
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
                                        localError = l10n.verificationCodeSent;
                                      });
                                    } catch (e) {
                                      if (!sheetContext.mounted) return;

                                      setSheetState(() {
                                        localLoading = false;
                                        localError = _cleanError(
                                          e,
                                          l10n.couldNotResendCode,
                                        );
                                      });
                                    }
                                  },
                            child: Text(
                              l10n.resend,
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
                                      l10n.invalidVerificationCode,
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
                            : Text(
                                l10n.verify,
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

  Future<bool> _showPhoneVerificationSheet({
    required String phoneNumber,
  }) async {
    final l10n = context.l10n;

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
                          Icons.phone_android_outlined,
                          color: colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        l10n.verifyPhoneChange,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        l10n.enterStaticPhoneCode(phoneNumber),
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (!sheetContext.mounted) return;

                        setSheetState(() {
                          codeText = value.trim();
                          localError = null;
                        });
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: l10n.sixDigitCode,
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
                            child: Text(
                              l10n.cancel,
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
                                : () {
                                    if (!sheetContext.mounted) return;

                                    setSheetState(() {
                                      localError = l10n.staticPhoneCodeSent;
                                    });
                                  },
                            child: Text(
                              l10n.resend,
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

                                await Future.delayed(
                                  const Duration(milliseconds: 250),
                                );

                                if (!sheetContext.mounted) return;

                                if (codeText.trim() == '123456') {
                                  await closeSheet(sheetContext, true);
                                  return;
                                }

                                setSheetState(() {
                                  localLoading = false;
                                  localError =
                                      l10n.invalidPhoneVerificationCode;
                                });
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
                            : Text(
                                l10n.verify,
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
    final l10n = context.l10n;
    final repository = context
        .read<RetailerProfileCubit>()
        .retailerProfileRepository;

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
                      title: Text(
                        l10n.verifyPasswordChange,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        l10n.enterCodeSentToEmail(email),
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (!sheetContext.mounted) return;

                        setSheetState(() {
                          codeText = value.trim();
                          localError = null;
                        });
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: l10n.sixDigitCode,
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
                            child: Text(
                              l10n.cancel,
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
                                            l10n.passwordVerificationCodeSent;
                                      });
                                    } catch (e) {
                                      if (!sheetContext.mounted) return;

                                      setSheetState(() {
                                        localLoading = false;
                                        localError = _cleanError(
                                          e,
                                          l10n.couldNotResendCode,
                                        );
                                      });
                                    }
                                  },
                            child: Text(
                              l10n.resend,
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
                                      l10n.couldNotUpdatePassword,
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
                            : Text(
                                l10n.verify,
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

  RetailerBusinessProfileModel? get _currentBusinessProfile {
    return context.read<RetailerProfileCubit>().state.profile?.business;
  }

  bool _hasSavedCountry(RetailerBusinessProfileModel? business) {
    if (business == null) return false;

    return (business.countryId != null && business.countryId! > 0) ||
        business.countryName.trim().isNotEmpty ||
        business.countryIso2Code.trim().isNotEmpty ||
        business.countryIso3Code.trim().isNotEmpty;
  }

  bool _hasSavedCity(RetailerBusinessProfileModel? business) {
    return business?.city.trim().isNotEmpty == true;
  }

  bool _isSelectedCountryDifferentFromSaved(
    RetailerBusinessProfileModel? business,
  ) {
    if (business == null || _selectedCountry == null) return false;

    final savedCountry = _findCountryFromProfile(business);
    if (savedCountry == null) return false;

    if (savedCountry.id > 0 && _selectedCountry!.id > 0) {
      return savedCountry.id != _selectedCountry!.id;
    }

    final selectedIso2 = _selectedCountry!.iso2Code.trim().toUpperCase();
    final savedIso2 = savedCountry.iso2Code.trim().toUpperCase();
    if (selectedIso2.isNotEmpty && savedIso2.isNotEmpty) {
      return selectedIso2 != savedIso2;
    }

    return _normalizeLocationName(_selectedCountry!.name) !=
        _normalizeLocationName(savedCountry.name);
  }

  CountryModel? _countryForSave(RetailerBusinessProfileModel? business) {
    if (_selectedCountry != null) return _selectedCountry;
    if (business == null) return null;
    return _findCountryFromProfile(business);
  }

  String _cityNameForSave(RetailerBusinessProfileModel? business) {
    final selectedCityName = _selectedCity?.name.trim() ?? '';
    if (selectedCityName.isNotEmpty) return selectedCityName;

    if (!_isSelectedCountryDifferentFromSaved(business)) {
      return business?.city.trim() ?? '';
    }

    return '';
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final cubit = context.read<RetailerProfileCubit>();

    if (!_formKey.currentState!.validate()) return;

    final businessProfile = cubit.state.profile?.business;
    final countryForSave = _countryForSave(businessProfile);
    final cityNameForSave = _cityNameForSave(businessProfile);

    if (countryForSave == null || countryForSave.id <= 0) {
      _showMessage(l10n.countryRequiredError);
      return;
    }

    if (cityNameForSave.isEmpty) {
      _showMessage(l10n.cityRequiredError);
      return;
    }

    final currentEmail = _emailController.text.trim();
    final emailChanged = currentEmail.toLowerCase() != _originalEmail;

    final normalizedPhone = _normalizePhone(_fullPhone);
    final phoneChanged = normalizedPhone != _originalPhone;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    final passwordChangeRequested = newPassword.isNotEmpty;
    final currentPasswordTypedWithoutPasswordChange =
        currentPassword.isNotEmpty && newPassword.isEmpty && !phoneChanged;
    final sensitiveChangeRequiresPassword =
        phoneChanged || passwordChangeRequested;

    if (sensitiveChangeRequiresPassword && currentPassword.isEmpty) {
      _showMessage(l10n.currentPasswordRequired);
      return;
    }

    if (currentPasswordTypedWithoutPasswordChange) {
      _showMessage(l10n.newPasswordRequired);
      return;
    }

    if (passwordChangeRequested && newPassword.length < 6) {
      _showMessage(l10n.passwordMinLength);
      return;
    }

    if (sensitiveChangeRequiresPassword) {
      final currentPasswordOk = await cubit.validateCurrentPassword(
        currentPassword: currentPassword,
      );

      if (!mounted) return;

      if (!currentPasswordOk) {
        _showCubitError(cubit);
        return;
      }
    }

    if (phoneChanged) {
      _showMessage(l10n.staticPhoneCodeSent);

      final phoneVerified = await _showPhoneVerificationSheet(
        phoneNumber: normalizedPhone,
      );

      if (!mounted) return;

      if (!phoneVerified) {
        _showMessage(l10n.phoneNotUpdatedCodeNotConfirmed);
        return;
      }
    }

    if (passwordChangeRequested) {
      final sent = await cubit.sendPasswordResetCode(email: _originalEmail);

      if (!mounted) return;

      if (!sent) {
        _showCubitError(cubit);
        return;
      }

      _showMessage(l10n.passwordVerificationCodeSent);

      final passwordVerified = await _showPasswordVerificationSheet(
        email: _originalEmail,
        newPassword: newPassword,
      );

      if (!mounted) return;

      if (!passwordVerified) {
        _showMessage(l10n.passwordNotUpdatedCodeNotConfirmed);
        return;
      }

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
        _showMessage(l10n.emailVerificationRequiredBeforeUpdating);
        return;
      }

      _showMessage(l10n.verificationCodeSent);

      final verified = await _showEmailVerificationSheet(email: currentEmail);

      if (!mounted) return;

      if (!verified) {
        _emailController.text = _originalEmail;

        await cubit.loadProfile();

        if (!mounted) return;

        _showMessage(l10n.emailNotUpdatedCodeNotConfirmed);

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
      phoneNumber: normalizedPhone,
      storeAddress: _addressController.text.trim(),
      countryId: countryForSave.id,
      countryName: countryForSave.name,
      countryIso2Code: countryForSave.iso2Code,
      countryIso3Code: countryForSave.iso3Code,
      city: cityNameForSave,
      businessType: _businessTypeController.text.trim(),
      successMessage: l10n.profileUpdatedSuccessfully,
    );

    if (!mounted) return;

    if (!businessUpdated) {
      _showCubitError(cubit);
      return;
    }

    _originalPhone = normalizedPhone;
    _currentPasswordController.clear();

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
      AppToast.info(context, message);
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
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: l10n.username,
                          child: PrimaryTextField(
                            controller: _usernameController,
                            hintText: l10n.username,
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: (value) => Validators.requiredField(
                              value,
                              fieldName: l10n.username,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _LabeledField(
                                label: l10n.firstName,
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
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _LabeledField(
                                label: l10n.lastName,
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _LabeledField(
                          label: l10n.email,
                          child: PrimaryTextField(
                            controller: _emailController,
                            hintText: l10n.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _SectionTitle(title: l10n.businessInformation),
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: l10n.storeName,
                          child: PrimaryTextField(
                            controller: _storeNameController,
                            hintText: l10n.storeName,
                            prefixIcon: const Icon(Icons.storefront_outlined),
                            validator: (value) => Validators.requiredField(
                              value,
                              fieldName: l10n.storeName,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _LabeledField(
                          label: l10n.phoneNumber,
                          child: IntlPhoneField(
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
                        ),
                        const SizedBox(height: 14),
                        SearchableSelectionField<CountryModel>(
                          key: ValueKey(
                            'retailer-edit-country-${_selectedCountry?.id ?? 0}-${_selectedCountry?.name ?? ''}-${_isLoadingCountries}',
                          ),
                          label: l10n.countryLabel,
                          hintText: _isLoadingCountries
                              ? l10n.loadingCountries
                              : l10n.selectCountry,
                          searchHintText: l10n.searchCountry,
                          items: _countries,
                          value: _selectedCountry,
                          itemLabel: (country) => country.name,
                          isLoading: _isLoadingCountries,
                          emptyText: l10n.noCountriesFound,
                          onSelected: (country) {
                            setState(() {
                              _locationEditedByUser = true;
                              _selectedCountry = country;
                              _selectedCity = null;
                              _cities = [];
                              _locationError = null;

                              if (country.iso2Code.trim().isNotEmpty) {
                                _initialCountryCode = country.iso2Code
                                    .trim()
                                    .toUpperCase();
                              }
                            });

                            _loadCitiesForCountry(country);
                          },
                          validator: (value) {
                            final business = _currentBusinessProfile;
                            if (value == null && !_hasSavedCountry(business)) {
                              return l10n.countryRequiredError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        SearchableSelectionField<RegionModel>(
                          key: ValueKey(
                            'retailer-edit-city-${_selectedCountry?.id ?? 0}-${_selectedCity?.id ?? 0}-${_selectedCity?.name ?? ''}-${_isLoadingCities}',
                          ),
                          label: l10n.city,
                          hintText: _selectedCountry == null
                              ? l10n.selectCountryFirst
                              : _isLoadingCities
                              ? l10n.loadingCities
                              : l10n.selectCity,
                          searchHintText: l10n.searchCity,
                          items: _cities,
                          value: _selectedCity,
                          itemLabel: (city) => city.name,
                          enabled:
                              _selectedCountry != null && !_isLoadingCities,
                          isLoading: _isLoadingCities,
                          emptyText: l10n.noCitiesFoundForCountry,
                          onSelected: (city) {
                            setState(() {
                              _locationEditedByUser = true;
                              _selectedCity = city;
                            });
                          },
                          validator: (value) {
                            final business = _currentBusinessProfile;
                            final changedCountry =
                                _isSelectedCountryDifferentFromSaved(business);

                            if (value == null &&
                                (changedCountry || !_hasSavedCity(business))) {
                              return l10n.cityRequiredError;
                            }
                            return null;
                          },
                        ),
                        if (_locationError != null &&
                            _locationError!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              _locationError!,
                              style: const TextStyle(
                                color: AppThemeTokens.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        _LabeledField(
                          label: l10n.businessType,
                          child: PrimaryTextField(
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
                        ),
                        const SizedBox(height: 14),
                        _LabeledField(
                          label: l10n.address,
                          child: PrimaryTextField(
                            controller: _addressController,
                            hintText: l10n.address,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            validator: (value) => Validators.requiredField(
                              value,
                              fieldName: l10n.address,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _SectionTitle(title: l10n.changePasswordOptional),
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: l10n.currentPassword,
                          child: PrimaryTextField(
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
                        ),
                        const SizedBox(height: 14),
                        _LabeledField(
                          label: l10n.newPassword,
                          child: PrimaryTextField(
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
        style: const TextStyle(
          color: AppThemeTokens.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppThemeTokens.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
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
