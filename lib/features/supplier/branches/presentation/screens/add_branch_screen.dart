import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/location/data/models/country_model.dart';
import '../../../../../core/location/data/models/region_model.dart';
import '../../../../../core/location/data/services/location_api_service.dart';
import '../../../../../core/location/location_hint_helper.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/widgets/searchable_selection_field.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/repositories/branch_repository.dart';

class AddBranchScreen extends StatefulWidget {
  final BranchEntity? branchToEdit;

  const AddBranchScreen({
    super.key,
    this.branchToEdit,
  });

  bool get isEditMode => branchToEdit != null;

  @override
  State<AddBranchScreen> createState() => _AddBranchScreenState();
}

class _AddBranchScreenState extends State<AddBranchScreen> {
  final _formKey = GlobalKey<FormState>();
  final BranchRepository _branchRepository = sl<BranchRepository>();
  late final LocationApiService _locationApiService;

  final _branchNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  List<CountryModel> _countries = [];
  List<RegionModel> _regions = [];
  CountryModel? _selectedCountry;
  RegionModel? _selectedRegion;

  BranchStatus _selectedStatus = BranchStatus.active;
  bool _isSaving = false;
  bool _isLoadingCountries = true;
  bool _isLoadingRegions = false;
  String? _locationError;
  String _phoneIso2Code = 'LB';
  String _completePhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _locationApiService = LocationApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    );

    final branch = widget.branchToEdit;

    if (branch != null) {
      _branchNameController.text = branch.name;
      _cityController.text = branch.city;
      _addressController.text = branch.address;
      _phoneController.text = _localPhoneForEditing(branch.phoneNumber);
      _completePhoneNumber = branch.phoneNumber;
      _selectedStatus = branch.status;
      if (branch.countryCode.trim().isNotEmpty) {
        _phoneIso2Code = branch.countryCode.trim().toUpperCase();
      }
    }

    _loadCountries();
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
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

      final branchCountryCode = widget.branchToEdit?.countryCode.toUpperCase();
      CountryModel? selectedCountry;

      if (branchCountryCode != null && branchCountryCode.isNotEmpty) {
        selectedCountry = _findCountryByIso2(countries, branchCountryCode);
      }

      setState(() {
        _countries = countries;
        _selectedCountry = selectedCountry;
        _phoneIso2Code = selectedCountry?.iso2Code ?? _phoneIso2Code;
        _isLoadingCountries = false;
      });

      if (selectedCountry != null) {
        await _loadRegionsForCountry(
          selectedCountry,
          preferredRegionId: widget.branchToEdit?.regionId,
        );
      }
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

  Future<void> _loadRegionsForCountry(
    CountryModel country, {
    int? preferredRegionId,
  }) async {
    setState(() {
      _isLoadingRegions = true;
      _regions = [];
      _selectedRegion = null;
      _locationError = null;
    });

    try {
      final regions = await _locationApiService.getRegionsByCountry(country.id);
      if (!mounted) return;

      RegionModel? selectedRegion;
      if (preferredRegionId != null) {
        selectedRegion = _findRegionById(regions, preferredRegionId);
      }

      setState(() {
        _regions = regions;
        _selectedRegion = selectedRegion;
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

  CountryModel? _findCountryByIso2(
    List<CountryModel> countries,
    String iso2Code,
  ) {
    try {
      return countries.firstWhere(
        (country) => country.iso2Code.toUpperCase() == iso2Code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  RegionModel? _findRegionById(List<RegionModel> regions, int regionId) {
    try {
      return regions.firstWhere((region) => region.id == regionId);
    } catch (_) {
      return null;
    }
  }

  String _localPhoneForEditing(String phoneNumber) {
    final countryCode = widget.branchToEdit?.countryCode.toUpperCase();
    var text = phoneNumber.trim();

    if (countryCode == 'LB' && text.startsWith('+961')) {
      text = text.substring(4);
    } else if (countryCode == 'AE' && text.startsWith('+971')) {
      text = text.substring(4);
    } else if (countryCode == 'SA' && text.startsWith('+966')) {
      text = text.substring(4);
    } else if (countryCode == 'QA' && text.startsWith('+974')) {
      text = text.substring(4);
    } else if (countryCode == 'KW' && text.startsWith('+965')) {
      text = text.substring(4);
    } else if (countryCode == 'JO' && text.startsWith('+962')) {
      text = text.substring(4);
    } else if (countryCode == 'EG' && text.startsWith('+20')) {
      text = text.substring(3);
    } else if (countryCode == 'TR' && text.startsWith('+90')) {
      text = text.substring(3);
    } else if (countryCode == 'FR' && text.startsWith('+33')) {
      text = text.substring(3);
    } else if (countryCode == 'US' && text.startsWith('+1')) {
      text = text.substring(2);
    }

    return text.trim();
  }

  Future<void> _saveBranch() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final country = _selectedCountry;
    if (country == null) {
      _showSnackBar('Please select a country');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final BranchEntity branch;
      final phoneNumber = _completePhoneNumber.trim().isNotEmpty
          ? _completePhoneNumber.trim()
          : _phoneController.text.trim();

      if (widget.isEditMode) {
        branch = await _branchRepository.updateBranch(
          branchId: widget.branchToEdit!.id,
          name: _branchNameController.text,
          countryCode: country.iso2Code,
          regionId: _selectedRegion?.id,
          city: _cityController.text,
          address: _addressController.text,
          phoneNumber: phoneNumber,
          status: _selectedStatus,
        );
      } else {
        branch = await _branchRepository.createBranch(
          name: _branchNameController.text,
          countryCode: country.iso2Code,
          regionId: _selectedRegion?.id,
          city: _cityController.text,
          address: _addressController.text,
          phoneNumber: phoneNumber,
          status: _selectedStatus,
        );
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      context.pop(branch);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showError(e);
    }
  }

  String? _validatePhone(PhoneNumber? phone) {
    final country = _selectedCountry;
    final rawLocalNumber = phone?.number.trim() ?? _phoneController.text.trim();
    final localDigits = rawLocalNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneCountryIso = phone?.countryISOCode.toUpperCase();

    if (localDigits.isEmpty) {
      return 'Phone number is required';
    }

    if (country == null) {
      return 'Please select a country first';
    }

    if (phoneCountryIso != null && phoneCountryIso != country.iso2Code) {
      return 'Phone country must match the selected country';
    }

    if (country.iso2Code == 'LB' && localDigits.length != 8) {
      return 'Lebanese phone numbers must contain 8 digits after +961';
    }

    if (localDigits.length < 6 || localDigits.length > 15) {
      return 'Enter a valid phone number for the selected country';
    }

    return null;
  }

  void _showError(Object error) {
    _showSnackBar(_messageFromError(error));
  }

  String _messageFromError(Object error) {
    if (error is AppException) return error.message;
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final title = widget.isEditMode ? 'Edit Branch' : 'Add Branch';
    final buttonText = widget.isEditMode ? 'Update Branch' : 'Save Branch';

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: const BoxDecoration(
            color: AppThemeTokens.background,
            border: Border(
              top: BorderSide(color: AppThemeTokens.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeTokens.textPrimary,
                    side: const BorderSide(color: AppThemeTokens.border),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusSmall,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveBranch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusSmall,
                      ),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonText,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
          children: [
            _SectionCard(
              title: 'Branch Information',
              subtitle:
                  'Create a supplier branch or warehouse used later for inventory and stock allocation.',
              children: [
                if (_locationError != null) ...[
                  _ErrorBox(
                    message: _locationError!,
                    onRetry: _loadCountries,
                  ),
                  const SizedBox(height: 16),
                ],
                _AppTextField(
                  label: 'Branch Name *',
                  hint: 'e.g., Main Warehouse',
                  controller: _branchNameController,
                  validator: (value) {
                    final name = value?.trim() ?? '';

                    if (name.isEmpty) return 'Branch name is required';
                    if (name.length < 3) {
                      return 'Branch name must be at least 3 characters';
                    }
                    if (name.length > 80) {
                      return 'Branch name is too long';
                    }

                    return null;
                  },
                ),
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
                _AppTextField(
                  label: 'City / Area *',
                  hint: LocationHintHelper.cityAreaHint(
                    countryIso2: _selectedCountry?.iso2Code,
                    regionName: _selectedRegion?.name,
                  ),
                  controller: _cityController,
                  validator: (value) {
                    final city = value?.trim() ?? '';

                    if (city.isEmpty) return 'City / Area is required';
                    if (city.length < 2) {
                      return 'City / Area must be at least 2 characters';
                    }
                    if (city.length > 80) {
                      return 'City / Area is too long';
                    }

                    return null;
                  },
                ),
                _AppTextField(
                  label: 'Full Address *',
                  hint: 'e.g., Building, street, industrial area',
                  controller: _addressController,
                  maxLines: 3,
                  validator: (value) {
                    final address = value?.trim() ?? '';

                    if (address.isEmpty) return 'Address is required';
                    if (address.length < 8) {
                      return 'Address must be more specific';
                    }
                    if (address.length > 180) {
                      return 'Address is too long';
                    }

                    return null;
                  },
                ),
                _PhoneField(
                  controller: _phoneController,
                  initialCountryCode: _phoneIso2Code,
                  validator: _validatePhone,
                  onChanged: (phone) {
                    _completePhoneNumber = phone.completeNumber;
                  },
                ),
                _StatusSelector(
                  selectedStatus: _selectedStatus,
                  onChanged: (status) {
                    if (status == null) return;

                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppThemeTokens.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 20),
          ...children,
        ],
      ),
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
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
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
      label: 'Country *',
      hintText: isLoading ? 'Loading countries...' : 'Select country',
      searchHintText: 'Search country...',
      items: countries,
      value: selectedCountry,
      isLoading: isLoading,
      enabled: !isLoading && countries.isNotEmpty,
      emptyText: 'No countries found',
      itemLabel: (country) => country.name,
      onSelected: (country) => onChanged(country),
      validator: (value) {
        if (value == null) return 'Country is required';
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
      label: 'Region / State',
      hintText: !countrySelected
          ? 'Select country first'
          : isLoading
              ? 'Loading regions...'
              : regions.isEmpty
                  ? 'No predefined regions, continue with city/area'
                  : 'Select region / state',
      searchHintText: 'Search region / state...',
      items: regions,
      value: selectedRegion,
      isLoading: isLoading,
      enabled: !disabled,
      emptyText: 'No regions found for your search',
      itemLabel: (region) => region.name,
      onSelected: (region) => onChanged(region),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String initialCountryCode;
  final String? Function(PhoneNumber?) validator;
  final ValueChanged<PhoneNumber> onChanged;

  const _PhoneField({
    required this.controller,
    required this.initialCountryCode,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phone Number *',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          IntlPhoneField(
            key: ValueKey('branch-phone-$initialCountryCode'),
            controller: controller,
            initialCountryCode: initialCountryCode,
            keyboardType: TextInputType.phone,
            validator: validator,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              hintStyle: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w500,
              ),
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
                borderSide: const BorderSide(color: AppThemeTokens.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppThemeTokens.radiusSmall,
                ),
                borderSide: const BorderSide(color: AppThemeTokens.error),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  const _AppTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w500,
              ),
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
                borderSide: const BorderSide(color: AppThemeTokens.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppThemeTokens.radiusSmall,
                ),
                borderSide: const BorderSide(color: AppThemeTokens.error),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final BranchStatus selectedStatus;
  final ValueChanged<BranchStatus?> onChanged;

  const _StatusSelector({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Branch Status *',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<BranchStatus>(
            value: selectedStatus,
            items: const [
              DropdownMenuItem(
                value: BranchStatus.active,
                child: Text('Active'),
              ),
              DropdownMenuItem(
                value: BranchStatus.inactive,
                child: Text('Inactive'),
              ),
            ],
            onChanged: onChanged,
            decoration: _dropdownDecoration('Select status'),
          ),
        ],
      ),
    );
  }
}

InputDecoration _dropdownDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: AppThemeTokens.textSecondary,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: AppThemeTokens.inputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
      borderSide: const BorderSide(color: AppThemeTokens.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
      borderSide: const BorderSide(color: AppThemeTokens.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}
