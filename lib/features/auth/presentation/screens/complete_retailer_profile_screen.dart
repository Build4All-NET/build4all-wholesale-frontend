import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_dropdown_field.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/select_option_l10n_extension.dart';
import '../../../../core/location/data/models/country_model.dart';
import '../../../../core/location/data/models/region_model.dart';
import '../../../../core/location/data/services/location_api_service.dart';
import '../../../../core/location/phone_countries.dart';
import '../../../../core/models/select_option.dart';
import '../../../../core/network/api_client.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/searchable_selection_field.dart';
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
  late final LocationApiService _locationApiService;

  /// Full international phone number (e.g. +9613123456) captured from the
  /// country-code phone field.
  String _fullPhone = '';

  List<CountryModel> _countries = [];
  List<RegionModel> _cities = [];

  CountryModel? _selectedCountry;
  RegionModel? _selectedCity;
  String? _selectedBusinessType;

  bool _isLoading = false;
  bool _isLoadingCountries = true;
  bool _isLoadingCities = false;
  String? _locationError;

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

    _locationApiService = LocationApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    );

    _loadCountries();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _storeNameController.dispose();
    _phoneNumberController.dispose();
    _storeAddressController.dispose();

    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoadingCountries = true;
      _locationError = null;
    });

    try {
      final countries = await _locationApiService.getCountries();

      if (!mounted) return;

      setState(() {
        _countries = countries;
        _isLoadingCountries = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingCountries = false;
        _locationError = AppErrorMapper.toMessage(e);
      });
    }
  }

  Future<void> _loadCitiesForCountry(CountryModel country) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _selectedCity = null;
      _locationError = null;
    });

    try {
      final cities = await _locationApiService.getRegionsByCountry(country.id);

      if (!mounted) return;

      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingCities = false;
        _locationError = AppErrorMapper.toMessage(e);
      });
    }
  }

  String? _validatePhone(String? value) {
    final l10n = context.l10n;

    if (value == null || value.trim().isEmpty) {
      return '${l10n.phoneNumber} is required';
    }

    final cleaned = value.trim();

    if (cleaned.length < 6) {
      return l10n.validPhoneForSelectedCountryError;
    }

    return null;
  }

  Future<void> _submit() async {
    final l10n = context.l10n;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCountry == null) {
      AppToast.error(context, l10n.countryRequiredError);
      return;
    }

    if (_selectedCity == null) {
      AppToast.error(context, '${l10n.city} is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await sl<AuthService>().updateRetailerProfile(
        fullName: _fullNameController.text.trim(),
        storeName: _storeNameController.text.trim(),
        phoneNumber: _fullPhone.trim().isNotEmpty
            ? _fullPhone.trim()
            : _phoneNumberController.text.trim(),
        storeAddress: _storeAddressController.text.trim(),
        countryId: _selectedCountry!.id,
        countryName: _selectedCountry!.name,
        countryIso2Code: _selectedCountry!.iso2Code,
        countryIso3Code: _selectedCountry!.iso3Code,
        city: _selectedCity!.name,
        businessType: _selectedBusinessType!,
      );

      if (!mounted) return;

      AppToast.success(context, l10n.retailerProfileSavedSuccessfully);

      sl<SessionManager>().markProfileCompleted();
      context.go('/retailer-dashboard');
    } catch (e) {
      if (!mounted) return;

      AppToast.error(context, e);
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
        title: Text(l10n.completeRetailerProfileTitle),
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
                        Center(
                          child: Text(
                            l10n.completeRetailerProfileTitle,
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
                            l10n.completeRetailerProfileSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppThemeTokens.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        Text(l10n.fullName),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _fullNameController,
                          hintText: l10n.enterFullName,
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: l10n.fullName,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(l10n.storeName),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _storeNameController,
                          hintText: l10n.enterStoreName,
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: l10n.storeName,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(l10n.phoneNumber),
                        const SizedBox(height: 8),
                        IntlPhoneField(
                          controller: _phoneNumberController,
                          initialCountryCode: 'LB',
                          countries: allowedPhoneCountries,
                          disableLengthCheck: false,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: l10n.enterPhoneNumber,
                            helperText: l10n.phoneLebanonHint,
                          ),
                          validator: (phone) =>
                              _validatePhone(phone?.completeNumber),
                          onChanged: (phone) {
                            _fullPhone = phone.number.trim().isEmpty
                                ? ''
                                : phone.completeNumber;
                          },
                        ),

                        const SizedBox(height: 16),

                        SearchableSelectionField<CountryModel>(
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
                              _selectedCountry = country;
                              _selectedCity = null;
                              _cities = [];
                            });

                            _loadCitiesForCountry(country);
                          },
                          validator: (value) {
                            if (value == null) {
                              return l10n.countryRequiredError;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        SearchableSelectionField<RegionModel>(
                          label: l10n.city,
                          hintText: _selectedCountry == null
                              ? l10n.selectCountryFirst
                              : _isLoadingCities
                              ? l10n.loadingCities
                              : l10n.selectCity,
                          searchHintText: l10n.selectCity,
                          items: _cities,
                          value: _selectedCity,
                          itemLabel: (city) => city.name,
                          enabled:
                              _selectedCountry != null && !_isLoadingCities,
                          isLoading: _isLoadingCities,
                          emptyText: l10n.noCitiesFoundForCountry,
                          onSelected: (city) {
                            setState(() => _selectedCity = city);
                          },
                          validator: (value) {
                            if (value == null) {
                              return '${l10n.city} is required';
                            }
                            return null;
                          },
                        ),

                        if (_locationError != null &&
                            _locationError!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _locationError!,
                            style: const TextStyle(
                              color: AppThemeTokens.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        Text(l10n.storeAddress),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _storeAddressController,
                          hintText: l10n.enterStoreAddress,
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: l10n.storeAddress,
                          ),
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
