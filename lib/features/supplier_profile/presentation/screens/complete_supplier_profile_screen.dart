import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_dropdown_field.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/select_option_l10n_extension.dart';
import '../../../../core/location/data/models/country_model.dart';
import '../../../../core/location/data/models/region_model.dart';
import '../../../../core/location/location_hint_helper.dart';
import '../../../../core/location/data/services/location_api_service.dart';
import '../../../../core/models/select_option.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/location/phone_countries.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/searchable_selection_field.dart';
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
  late final TextEditingController _cityController;
  late final TextEditingController _descriptionController;
  late final LocationApiService _locationApiService;

  List<CountryModel> _countries = [];
  List<RegionModel> _regions = [];
  CountryModel? _selectedCountry;
  RegionModel? _selectedRegion;
  String? _selectedBusinessType;
  String? _selectedLogoImagePath;

  bool _isLoadingCountries = true;
  bool _isLoadingRegions = false;
  String? _locationError;
  String _phoneIso2Code = 'LB';
  String _completePhoneNumber = '';

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
    _cityController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationApiService = LocationApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    );
    _loadCountries();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
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
        _countries = [];
        _regions = [];
        _selectedCountry = null;
        _selectedRegion = null;
        _isLoadingCountries = false;
        _locationError = _messageFromError(e);
      });
    }
  }

  Future<void> _loadRegionsForCountry(CountryModel country) async {
    setState(() {
      _isLoadingRegions = true;
      _regions = [];
      _selectedRegion = null;
      _locationError = null;
    });

    try {
      final regions = await _locationApiService.getRegionsByCountry(country.id);
      if (!mounted) return;
      setState(() {
        _regions = regions;
        _isLoadingRegions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _regions = [];
        _selectedRegion = null;
        _isLoadingRegions = false;
        _locationError = _messageFromError(e);
      });
    }
  }

  String _messageFromError(Object error) {
    if (error is AppException) return error.message;
    return error.toString().replaceFirst('Exception: ', '');
  }


  Future<void> _pickLogoImage() async {
    // Do not pass maxWidth/maxHeight/imageQuality: image_picker's native
    // resize bakes a green cast into wide-gamut (Display P3) iOS photos.
    // The backend downscales and re-encodes the image to clean sRGB instead.
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedLogoImagePath = pickedImage.path;
    });
  }

  void _removeLogoImage() {
    setState(() {
      _selectedLogoImagePath = null;
    });
  }

  String? _validatePhone(PhoneNumber? phone) {
    final country = _selectedCountry;
    final rawLocalNumber = phone?.number.trim() ?? _phoneNumberController.text.trim();
    final localDigits = rawLocalNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneCountryIso = phone?.countryISOCode.toUpperCase();

    if (localDigits.isEmpty) {
      return context.l10n.phoneNumberRequiredError;
    }

    if (country == null) {
      return context.l10n.selectCountryFirstError;
    }

    if (phoneCountryIso != null && phoneCountryIso != country.iso2Code) {
      return context.l10n.phoneCountryMustMatchSelectedCountry;
    }

    if (country.iso2Code == 'LB' && localDigits.length != 8) {
      return context.l10n.lebanesePhoneDigitsError;
    }

    if (localDigits.length < 6 || localDigits.length > 15) {
      return context.l10n.validPhoneForSelectedCountryError;
    }

    return null;
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      AppToast.error(context, context.l10n.completeRequiredFieldsCorrectly);
      return;
    }

    final country = _selectedCountry;
    if (country == null) {
      AppToast.error(context, context.l10n.pleaseSelectCountry);
      return;
    }

    final phoneNumber = _completePhoneNumber.trim().isNotEmpty
        ? _completePhoneNumber.trim()
        : _phoneNumberController.text.trim();


    if (_selectedLogoImagePath == null || _selectedLogoImagePath!.trim().isEmpty) {
      AppToast.error(context, context.l10n.supplierLogoRequiredError);
      return;
    }

    context.read<SupplierProfileCubit>().createSupplierProfile(
          userId: 0,
          companyName: _companyNameController.text.trim(),
          companyAddress: _companyAddressController.text.trim(),
          phoneNumber: phoneNumber,
          countryCode: country.iso2Code,
          regionId: _selectedRegion?.id,
          city: _cityController.text.trim(),
          businessType: _selectedBusinessType!,
          description: _descriptionController.text.trim(),
          logoImagePath: _selectedLogoImagePath!,
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
            AppToast.error(context, state.errorMessage!);
            context.read<SupplierProfileCubit>().clearMessages();
          }

          if (state.success && state.profile != null) {
            AppToast.success(context, l10n.supplierProfileSavedSuccessfully);
            context.read<SupplierProfileCubit>().clearMessages();
            sl<SessionManager>().markProfileCompleted();
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

                              if (_locationError != null) ...[
                                _ErrorBox(
                                  message: _locationError!,
                                  onRetry: _loadCountries,
                                ),
                                const SizedBox(height: 16),
                              ],

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

                              _CountryDropdown(
                                isLoading: _isLoadingCountries,
                                countries: _countries,
                                selectedCountry: _selectedCountry,
                                onChanged: (country) {
                                  if (country == null) return;
                                  setState(() {
                                    _selectedCountry = country;
                                    _selectedRegion = null;
                                    _regions = [];
                                    _phoneIso2Code = country.iso2Code;
                                    _completePhoneNumber = '';
                                  });
                                  _loadRegionsForCountry(country);
                                },
                              ),

                              const SizedBox(height: 16),

                              _RegionDropdown(
                                isLoading: _isLoadingRegions,
                                regions: _regions,
                                selectedRegion: _selectedRegion,
                                countrySelected: _selectedCountry != null,
                                onChanged: (region) {
                                  setState(() {
                                    _selectedRegion = region;
                                  });
                                },
                              ),

                              const SizedBox(height: 16),

                              Text(l10n.cityAreaLabel),
                              const SizedBox(height: 8),
                              PrimaryTextField(
                                controller: _cityController,
                                hintText: LocationHintHelper.cityAreaHint(
                                  countryIso2: _selectedCountry?.iso2Code,
                                  regionName: _selectedRegion?.name,
                                  genericHint: l10n.cityAreaHintGeneric,
                                  leBeirutHint: l10n.cityAreaHintLebanonBeirut,
                                  leMountHint: l10n.cityAreaHintLebanonMount,
                                  leNorthHint: l10n.cityAreaHintLebanonNorth,
                                  leSouthHint: l10n.cityAreaHintLebanonSouth,
                                  leBekaaHint: l10n.cityAreaHintLebanonBekaa,
                                  leGenericHint: l10n.cityAreaHintLebanonGeneric,
                                ),
                                validator: (value) => Validators.requiredField(
                                  value,
                                  fieldName: l10n.cityAreaLabel,
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(l10n.phoneNumber),
                              const SizedBox(height: 8),
                              IntlPhoneField(
                                key: ValueKey('profile-phone-$_phoneIso2Code'),
                                controller: _phoneNumberController,
                                initialCountryCode: _phoneIso2Code,
                                countries: allowedPhoneCountries,
                                keyboardType: TextInputType.phone,
                                validator: _validatePhone,
                                onChanged: (phone) {
                                  _completePhoneNumber = phone.completeNumber;
                                },
                                decoration: InputDecoration(
                                  hintText: l10n.enterPhoneNumber,
                                  helperText: l10n.phoneLebanonHint,
                                  filled: true,
                                  fillColor: AppThemeTokens.inputFill,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppThemeTokens.radiusSmall,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppThemeTokens.radiusSmall,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppThemeTokens.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppThemeTokens.radiusSmall,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppThemeTokens.error,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
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
                                    return l10n.businessTypeRequiredError;
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

                              Text(l10n.supplierLogo),
                              const SizedBox(height: 8),
                              _LogoUploadBox(
                                imagePath: _selectedLogoImagePath,
                                onPick: _pickLogoImage,
                                onRemove: _removeLogoImage,
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


class _LogoUploadBox extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _LogoUploadBox({
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.trim().isNotEmpty;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeTokens.inputFill,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: hasImage
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusLarge,
                      ),
                      child: Image.file(
                        File(imagePath!),
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onPick,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(context.l10n.changeLogo),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.close_rounded),
                        color: AppThemeTokens.error,
                        tooltip: context.l10n.removeLogo,
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: primaryColor.withValues(alpha: 0.10),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      color: primaryColor,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.uploadSupplierLogo,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppThemeTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.tapToUploadLogoImage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  final bool isLoading;
  final List<CountryModel> countries;
  final CountryModel? selectedCountry;
  final ValueChanged<CountryModel?> onChanged;

  const _CountryDropdown({
    required this.isLoading,
    required this.countries,
    required this.selectedCountry,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SearchableSelectionField<CountryModel>(
      label: context.l10n.countryRequiredLabel,
      hintText: isLoading ? context.l10n.loadingCountries : context.l10n.selectCountry,
      searchHintText: context.l10n.searchCountry,
      items: countries,
      value: selectedCountry,
      isLoading: isLoading,
      enabled: !isLoading && countries.isNotEmpty,
      emptyText: context.l10n.noCountriesFound,
      itemLabel: (country) => country.name,
      onSelected: (country) => onChanged(country),
      validator: (value) {
        if (value == null) return context.l10n.countryRequiredError;
        return null;
      },
    );
  }
}

class _RegionDropdown extends StatelessWidget {
  final bool isLoading;
  final List<RegionModel> regions;
  final RegionModel? selectedRegion;
  final bool countrySelected;
  final ValueChanged<RegionModel?> onChanged;

  const _RegionDropdown({
    required this.isLoading,
    required this.regions,
    required this.selectedRegion,
    required this.countrySelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !countrySelected || isLoading || regions.isEmpty;

    return SearchableSelectionField<RegionModel>(
      label: context.l10n.regionStateLabel,
      hintText: !countrySelected
          ? context.l10n.selectCountryFirst
          : isLoading
              ? context.l10n.loadingRegions
              : regions.isEmpty
                  ? context.l10n.noPredefinedRegionsContinueWithCity
                  : context.l10n.selectRegionState,
      searchHintText: context.l10n.searchRegionState,
      items: regions,
      value: selectedRegion,
      isLoading: isLoading,
      enabled: !disabled,
      emptyText: context.l10n.noRegionsFoundForSearch,
      itemLabel: (region) => region.name,
      onSelected: (region) => onChanged(region),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
        border: Border.all(color: AppThemeTokens.error.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppThemeTokens.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppThemeTokens.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(context.l10n.retryButton)),
        ],
      ),
    );
  }
}
