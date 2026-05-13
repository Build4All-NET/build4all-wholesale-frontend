import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../data/models/tax_location_model.dart';
import '../../data/services/tax_location_api_service.dart';
import '../../domain/entities/tax_rule_entity.dart';
import '../bloc/tax_rules_bloc.dart';
import '../bloc/tax_rules_event.dart';
import '../bloc/tax_rules_state.dart';

enum TaxRulePreset {
  custom,
  lebanonVat,
}

extension TaxRulePresetX on TaxRulePreset {
  String get label {
    switch (this) {
      case TaxRulePreset.custom:
        return 'Custom';
      case TaxRulePreset.lebanonVat:
        return 'Lebanon VAT';
    }
  }

  String? get defaultRate {
    switch (this) {
      case TaxRulePreset.custom:
        return null;
      case TaxRulePreset.lebanonVat:
        return '11';
    }
  }
}

class CreateTaxRuleScreen extends StatelessWidget {
  final TaxRuleEntity? rule;

  const CreateTaxRuleScreen({
    super.key,
    this.rule,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaxRulesBloc>(
      create: (_) => sl<TaxRulesBloc>(),
      child: _CreateTaxRuleView(rule: rule),
    );
  }
}

class _CreateTaxRuleView extends StatefulWidget {
  final TaxRuleEntity? rule;

  const _CreateTaxRuleView({
    this.rule,
  });

  @override
  State<_CreateTaxRuleView> createState() => _CreateTaxRuleViewState();
}

class _CreateTaxRuleViewState extends State<_CreateTaxRuleView> {
  final _formKey = GlobalKey<FormState>();

  final ApiClient _projectApiClient =
      sl<ApiClient>(instanceName: 'projectApiClient');

  late final TaxLocationApiService _locationApiService;

  late final TextEditingController _ruleNameController;
  late final TextEditingController _rateController;
  late final TextEditingController _notesController;

  TaxRulePreset _selectedPreset = TaxRulePreset.custom;

  String? _selectedCountryId;
  String? _selectedRegionId;

  bool _autoGenerateName = true;
  bool _appliesToShipping = false;
  bool _active = true;

  bool _loadingCountries = true;
  bool _loadingRegions = false;

  String? _countryErrorMessage;
  String? _regionErrorMessage;

  final List<TaxCountryModel> _countries = [];
  final List<TaxRegionModel> _regions = [];

  bool get _isEditMode => widget.rule != null;

  TaxCountryModel? get _selectedCountry {
    if (_selectedCountryId == null) return null;

    final matches = _countries.where(
      (country) => country.id == _selectedCountryId,
    );

    return matches.isEmpty ? null : matches.first;
  }

  TaxRegionModel? get _selectedRegion {
    if (_selectedRegionId == null || _selectedRegionId!.trim().isEmpty) {
      return null;
    }

    final matches = _regions.where(
      (region) => region.id == _selectedRegionId,
    );

    return matches.isEmpty ? null : matches.first;
  }

  @override
  void initState() {
    super.initState();

    _locationApiService = TaxLocationApiService(_projectApiClient);

    final rule = widget.rule;

    _ruleNameController = TextEditingController(text: rule?.ruleName ?? '');
    _rateController = TextEditingController(
      text: rule == null ? '' : rule.rate.toString(),
    );
    _notesController = TextEditingController(text: rule?.notes ?? '');

    _selectedCountryId = rule?.countryId;
    _selectedRegionId = rule?.regionId;

    _appliesToShipping = rule?.appliesToShipping ?? false;
    _active = rule?.active ?? true;

    _autoGenerateName = rule == null;

    if (rule != null &&
        rule.countryIso2Code?.toUpperCase() == 'LB' &&
        rule.rate == 11) {
      _selectedPreset = TaxRulePreset.lebanonVat;
    }

    _loadCountries();
  }

  @override
  void dispose() {
    _ruleNameController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _loadingCountries = true;
      _countryErrorMessage = null;
    });

    try {
      final countries = await _locationApiService.getCountries();

      if (!mounted) return;

      setState(() {
        _countries
          ..clear()
          ..addAll(countries);

        if (_selectedCountryId == null || _selectedCountryId!.isEmpty) {
          final lebanon = countries.where((country) => country.isLebanon);

          if (lebanon.isNotEmpty) {
            _selectedCountryId = lebanon.first.id;
          } else if (countries.isNotEmpty) {
            _selectedCountryId = countries.first.id;
          }
        } else {
          final exists = countries.any(
            (country) => country.id == _selectedCountryId,
          );

          if (!exists) {
            _selectedCountryId = null;
            _selectedRegionId = null;
          }
        }

        _loadingCountries = false;
      });

      if (_selectedCountryId != null) {
        await _loadRegionsForSelectedCountry(resetRegion: false);
      }

      _syncGeneratedNameIfNeeded();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _countryErrorMessage = e.toString();
        _loadingCountries = false;
      });
    }
  }

  Future<void> _loadRegionsForSelectedCountry({
    bool resetRegion = true,
  }) async {
    final countryId = _selectedCountryId;

    if (countryId == null || countryId.isEmpty) {
      setState(() {
        _regions.clear();
        _selectedRegionId = null;
      });
      _syncGeneratedNameIfNeeded();
      return;
    }

    setState(() {
      _loadingRegions = true;
      _regionErrorMessage = null;
    });

    try {
      final regions = await _locationApiService.getRegionsByCountry(countryId);

      if (!mounted) return;

      setState(() {
        _regions
          ..clear()
          ..addAll(regions);

        if (resetRegion) {
          _selectedRegionId = null;
        }

        if (_selectedRegionId != null &&
            !_regions.any((region) => region.id == _selectedRegionId)) {
          _selectedRegionId = null;
        }

        _loadingRegions = false;
      });

      _syncGeneratedNameIfNeeded();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _regionErrorMessage = e.toString();
        _loadingRegions = false;
      });
    }
  }

  Future<void> _handleCountryChanged(String? countryId) async {
    if (countryId == null || countryId.trim().isEmpty) return;

    setState(() {
      _selectedCountryId = countryId;
      _selectedRegionId = null;
      _regions.clear();
    });

    await _loadRegionsForSelectedCountry(resetRegion: true);
    _syncGeneratedNameIfNeeded();
  }

  void _handlePresetChanged(TaxRulePreset? preset) {
    if (preset == null) return;

    setState(() {
      _selectedPreset = preset;

      if (preset.defaultRate != null) {
        _rateController.text = preset.defaultRate!;
      }

      if (preset == TaxRulePreset.lebanonVat) {
        final lebanonMatches = _countries.where((country) => country.isLebanon);

        if (lebanonMatches.isNotEmpty) {
          _selectedCountryId = lebanonMatches.first.id;
          _selectedRegionId = null;
        }
      }
    });

    if (_selectedPreset == TaxRulePreset.lebanonVat &&
        _selectedCountryId != null) {
      _loadRegionsForSelectedCountry(resetRegion: true);
    }

    _syncGeneratedNameIfNeeded(force: true);
  }

  void _handleAutoGenerateChanged(bool value) {
    setState(() {
      _autoGenerateName = value;
    });

    if (value) {
      _syncGeneratedNameIfNeeded(force: true);
    }
  }

  void _syncGeneratedNameIfNeeded({bool force = false}) {
    if (!_autoGenerateName && !force) return;

    final generatedName = _buildGeneratedRuleName();

    if (generatedName.trim().isEmpty) return;

    _ruleNameController.text = generatedName;
  }

  String _buildGeneratedRuleName() {
    final country = _selectedCountry;
    final region = _selectedRegion;
    final rate = _rateController.text.trim();

    if (_selectedPreset == TaxRulePreset.lebanonVat) {
      if (region != null && region.name.trim().isNotEmpty) {
        return 'Lebanon VAT - ${region.name.trim()}';
      }

      return 'Lebanon VAT';
    }

    final locationName = region?.name.trim().isNotEmpty == true
        ? region!.name.trim()
        : country?.name.trim();

    if (locationName == null || locationName.isEmpty) {
      if (rate.isEmpty) return 'Custom Tax Rule';
      return 'Custom Tax Rule $rate%';
    }

    if (rate.isEmpty) {
      return '$locationName Tax';
    }

    return '$locationName Tax $rate%';
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _rateValidator(String? value) {
    final requiredError = _required(value, 'Tax Rate');
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());

    if (parsed == null || parsed <= 0) {
      return 'Tax rate must be greater than 0';
    }

    if (parsed > 100) {
      return 'Tax rate cannot be greater than 100';
    }

    return null;
  }

  bool _validateLocation(BuildContext context) {
    if (_selectedCountryId == null || _selectedCountryId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country')),
      );
      return false;
    }

    return true;
  }

  void _saveTaxRule(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateLocation(context)) return;

    final now = DateTime.now();
    final selectedCountry = _selectedCountry;
    final selectedRegion = _selectedRegion;

    final rule = TaxRuleEntity(
      id: widget.rule?.id ?? '',
      ruleName: _ruleNameController.text.trim(),
      rate: double.tryParse(_rateController.text.trim()) ?? 0,
      countryId: _selectedCountryId ?? '',
      countryName: selectedCountry?.name ?? widget.rule?.countryName ?? '',
      countryIso2Code:
          selectedCountry?.iso2Code ?? widget.rule?.countryIso2Code,
      countryIso3Code:
          selectedCountry?.iso3Code ?? widget.rule?.countryIso3Code,
      regionId: _selectedRegionId,
      regionName: selectedRegion?.name,
      regionCode: selectedRegion?.code,
      appliesToShipping: _appliesToShipping,
      active: _active,
      status: widget.rule?.status,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.rule?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditMode) {
      context.read<TaxRulesBloc>().add(UpdateTaxRuleRequested(rule));
    } else {
      context.read<TaxRulesBloc>().add(CreateTaxRuleRequested(rule));
    }
  }

  void _cancel() {
    if (_isEditMode) {
      context.go('/supplier-tax-rules');
    } else {
      context.go('/supplier-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<TaxRulesBloc, TaxRulesState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );

          context.read<TaxRulesBloc>().add(
                const ClearTaxRuleMessageRequested(),
              );
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );

          context.read<TaxRulesBloc>().add(
                const ClearTaxRuleMessageRequested(),
              );

          if (_isEditMode) {
            context.go('/supplier-tax-rules');
          } else {
            context.go('/supplier-dashboard');
          }
        }
      },
      child: BlocBuilder<TaxRulesBloc, TaxRulesState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppThemeTokens.background,
            appBar: AppBar(
              backgroundColor: AppThemeTokens.background,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                onPressed: state.saving ? null : _cancel,
                icon: const Icon(Icons.arrow_back, size: 28),
              ),
              title: Text(
                _isEditMode ? 'Edit Tax Rule' : 'Create Tax Rule',
                style: const TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: const BoxDecoration(
                  color: AppThemeTokens.surface,
                  border: Border(top: BorderSide(color: AppThemeTokens.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: state.saving ? null : _cancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppThemeTokens.textPrimary,
                            backgroundColor: AppThemeTokens.surface,
                            side: const BorderSide(
                              color: AppThemeTokens.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: state.saving
                              ? null
                              : () => _saveTaxRule(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: state.saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isEditMode ? 'Update Rule' : 'Create Rule',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _SectionCard(
                        title: 'Tax Rule Information',
                        children: [
                          _FieldLabel('Rule Preset'),
                          _TaxRulePresetDropdown(
                            value: _selectedPreset,
                            onChanged: _handlePresetChanged,
                          ),
                          const SizedBox(height: 8),
                          const _HelpText(
                            text:
                                'Choose a preset or keep Custom and enter your own order-level tax rule.',
                          ),
                          const _DividerSpace(),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Auto-generate name',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppThemeTokens.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _autoGenerateName,
                                activeThumbColor: Colors.white,
                                activeTrackColor: primary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: const Color(0xFFD1D5DB),
                                onChanged: _handleAutoGenerateChanged,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _FieldLabel('Rule Name *'),
                          _InputField(
                            controller: _ruleNameController,
                            hintText: 'Lebanon VAT',
                            enabled: !_autoGenerateName,
                            validator: (value) {
                              return _required(value, 'Rule Name');
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Tax Rate % *'),
                          _InputField(
                            controller: _rateController,
                            hintText: '11',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: _rateValidator,
                            onChanged: (_) => _syncGeneratedNameIfNeeded(),
                          ),
                          const SizedBox(height: 8),
                          const _HelpText(
                            text:
                                'Example: enter 11 for 11%. Tax is applied to the whole order based on country and optional region.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Location',
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: _FieldLabel('Country *'),
                              ),
                              TextButton(
                                onPressed:
                                    _loadingCountries ? null : _loadCountries,
                                child: const Text(
                                  'Refresh',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_loadingCountries)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_countryErrorMessage != null)
                            _ErrorText(message: _countryErrorMessage!)
                          else
                            _TaxCountrySearchField(
                              countries: _countries,
                              selectedCountryId: _selectedCountryId,
                              onChanged: _handleCountryChanged,
                            ),
                          const SizedBox(height: 8),
                          const _HelpText(
                            text:
                                'Country is required because tax is calculated from the retailer delivery country.',
                          ),
                          const _DividerSpace(),
                          Row(
                            children: [
                              const Expanded(
                                child: _FieldLabel('Region (Optional)'),
                              ),
                              TextButton(
                                onPressed: _selectedCountryId == null ||
                                        _loadingRegions
                                    ? null
                                    : () => _loadRegionsForSelectedCountry(
                                          resetRegion: false,
                                        ),
                                child: const Text(
                                  'Refresh',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_loadingRegions)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_regionErrorMessage != null)
                            _ErrorText(message: _regionErrorMessage!)
                          else
                            _TaxRegionSearchField(
                              regions: _regions,
                              selectedRegionId: _selectedRegionId,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRegionId = value;
                                });

                                _syncGeneratedNameIfNeeded();
                              },
                            ),
                          const SizedBox(height: 8),
                          const _HelpText(
                            text:
                                'Choose a specific region only when needed. Leave it empty to apply this tax rule to the whole country.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Tax Applicability',
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Apply tax to shipping cost',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppThemeTokens.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _appliesToShipping,
                                activeThumbColor: Colors.white,
                                activeTrackColor: primary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: const Color(0xFFD1D5DB),
                                onChanged: (value) {
                                  setState(() {
                                    _appliesToShipping = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const _HelpText(
                            text:
                                'If enabled, checkout tax will include shipping cost. If disabled, tax applies only to items after promotion discount.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Status & Notes',
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppThemeTokens.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _active,
                                activeThumbColor: Colors.white,
                                activeTrackColor: primary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: const Color(0xFFD1D5DB),
                                onChanged: (value) {
                                  setState(() {
                                    _active = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Notes'),
                          _InputField(
                            controller: _notesController,
                            hintText: 'Optional notes about this tax rule',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ],
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

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppThemeTokens.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppThemeTokens.textPrimary,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool enabled;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppThemeTokens.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: enabled ? AppThemeTokens.surface : const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: _border(),
        enabledBorder: _border(),
        disabledBorder: _border(color: const Color(0xFFE5E7EB)),
        focusedBorder: _border(
          color: Theme.of(context).colorScheme.primary,
        ),
        errorBorder: _border(color: Colors.red),
        focusedErrorBorder: _border(color: Colors.red),
      ),
    );
  }

  OutlineInputBorder _border({Color color = AppThemeTokens.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}

class _TaxRulePresetDropdown extends StatelessWidget {
  final TaxRulePreset value;
  final ValueChanged<TaxRulePreset?> onChanged;

  const _TaxRulePresetDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TaxRulePreset>(
      isExpanded: true,
      initialValue: value,
      items: TaxRulePreset.values.map((preset) {
        return DropdownMenuItem<TaxRulePreset>(
          value: preset,
          child: _DropdownText(preset.label),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: _dropdownDecoration(context),
    );
  }
}

class _TaxCountrySearchField extends StatelessWidget {
  final List<TaxCountryModel> countries;
  final String? selectedCountryId;
  final ValueChanged<String?> onChanged;

  const _TaxCountrySearchField({
    required this.countries,
    required this.selectedCountryId,
    required this.onChanged,
  });

  TaxCountryModel? get _selectedCountry {
    if (selectedCountryId == null) return null;

    final matches = countries.where(
      (country) => country.id == selectedCountryId,
    );

    return matches.isEmpty ? null : matches.first;
  }

  Future<void> _openCountryPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<TaxCountryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _TaxCountryPickerSheet(
          countries: countries,
          selectedCountryId: selectedCountryId,
        );
      },
    );

    if (selected == null) return;

    onChanged(selected.id);
  }

  @override
  Widget build(BuildContext context) {
    return _SearchableSelectionField(
      value: _selectedCountry == null ? null : _countryDisplay(_selectedCountry!),
      hintText: 'Search and select country',
      onTap: countries.isEmpty ? null : () => _openCountryPicker(context),
      validator: () {
        if (selectedCountryId == null || selectedCountryId!.trim().isEmpty) {
          return 'Country is required';
        }

        return null;
      },
    );
  }

  String _countryDisplay(TaxCountryModel country) {
    final code = country.iso2Code.trim();
    if (code.isEmpty) return country.name;
    return '${country.name} ($code)';
  }
}

class _TaxRegionSearchField extends StatelessWidget {
  final List<TaxRegionModel> regions;
  final String? selectedRegionId;
  final ValueChanged<String?> onChanged;

  const _TaxRegionSearchField({
    required this.regions,
    required this.selectedRegionId,
    required this.onChanged,
  });

  TaxRegionModel? get _selectedRegion {
    if (selectedRegionId == null || selectedRegionId!.trim().isEmpty) {
      return null;
    }

    final matches = regions.where(
      (region) => region.id == selectedRegionId,
    );

    return matches.isEmpty ? null : matches.first;
  }

  Future<void> _openRegionPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<TaxRegionModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _TaxRegionPickerSheet(
          regions: regions,
          selectedRegionId: selectedRegionId,
        );
      },
    );

    if (selected == null) return;

    onChanged(selected.id);
  }

  @override
  Widget build(BuildContext context) {
    if (regions.isEmpty) {
      return _SearchableSelectionField(
        value: null,
        hintText: 'Select region (No region found)',
        onTap: null,
        validator: () => null,
      );
    }

    return _SearchableSelectionField(
      value: _selectedRegion?.name,
      hintText: 'Search and select region',
      onTap: () => _openRegionPicker(context),
      validator: () => null,
    );
  }
}

class _SearchableSelectionField extends FormField<String> {
  _SearchableSelectionField({
    required String? value,
    required String hintText,
    required VoidCallback? onTap,
    required String? Function() validator,
  }) : super(
          initialValue: value,
          validator: (_) => validator(),
          builder: (field) {
            final hasValue = value != null && value.trim().isNotEmpty;
            final hasError = field.hasError;
            final enabled = onTap != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(6),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: enabled
                          ? AppThemeTokens.surface
                          : const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      border: _fieldBorder(),
                      enabledBorder: _fieldBorder(),
                      disabledBorder: _fieldBorder(
                        color: const Color(0xFFE5E7EB),
                      ),
                      focusedBorder: _fieldBorder(
                        color: Theme.of(field.context).colorScheme.primary,
                      ),
                      errorBorder: _fieldBorder(color: Colors.red),
                      focusedErrorBorder: _fieldBorder(color: Colors.red),
                      errorText: hasError ? field.errorText : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            hasValue ? value.trim() : hintText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  hasValue ? FontWeight.w700 : FontWeight.w600,
                              color: hasValue
                                  ? AppThemeTokens.textPrimary
                                  : AppThemeTokens.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.search,
                          size: 20,
                          color: enabled
                              ? AppThemeTokens.textSecondary
                              : const Color(0xFF9CA3AF),
                        ),
                        if (enabled) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 24,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );

  static OutlineInputBorder _fieldBorder({
    Color color = AppThemeTokens.border,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}

class _TaxCountryPickerSheet extends StatefulWidget {
  final List<TaxCountryModel> countries;
  final String? selectedCountryId;

  const _TaxCountryPickerSheet({
    required this.countries,
    required this.selectedCountryId,
  });

  @override
  State<_TaxCountryPickerSheet> createState() => _TaxCountryPickerSheetState();
}

class _TaxCountryPickerSheetState extends State<_TaxCountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  List<TaxCountryModel> get _filteredCountries {
    final normalizedQuery = _query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return widget.countries;
    }

    return widget.countries.where((country) {
      return country.name.toLowerCase().contains(normalizedQuery) ||
          country.iso2Code.toLowerCase().contains(normalizedQuery) ||
          country.iso3Code.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SearchBottomSheetContainer(
      title: 'Select Country',
      searchHint: 'Search country...',
      searchController: _searchController,
      onSearchChanged: (value) {
        setState(() {
          _query = value;
        });
      },
      emptyMessage: 'No country found',
      itemCount: _filteredCountries.length,
      itemBuilder: (context, index) {
        final country = _filteredCountries[index];
        final selected = country.id == widget.selectedCountryId;

        return _PickerTile(
          title: _countryTitle(country),
          subtitle: _countrySubtitle(country),
          selected: selected,
          onTap: () => Navigator.of(context).pop(country),
        );
      },
    );
  }

  String _countryTitle(TaxCountryModel country) {
    final code = country.iso2Code.trim();
    if (code.isEmpty) return country.name;
    return '${country.name} ($code)';
  }

  String _countrySubtitle(TaxCountryModel country) {
    final codes = [
      country.iso2Code.trim(),
      country.iso3Code.trim(),
    ].where((code) => code.isNotEmpty).join(' • ');

    return codes.isEmpty ? 'Country' : codes;
  }
}

class _TaxRegionPickerSheet extends StatefulWidget {
  final List<TaxRegionModel> regions;
  final String? selectedRegionId;

  const _TaxRegionPickerSheet({
    required this.regions,
    required this.selectedRegionId,
  });

  @override
  State<_TaxRegionPickerSheet> createState() => _TaxRegionPickerSheetState();
}

class _TaxRegionPickerSheetState extends State<_TaxRegionPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  List<TaxRegionModel> get _filteredRegions {
    final normalizedQuery = _query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return widget.regions;
    }

    return widget.regions.where((region) {
      return region.name.toLowerCase().contains(normalizedQuery) ||
          region.code.toLowerCase().contains(normalizedQuery) ||
          region.countryName.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SearchBottomSheetContainer(
      title: 'Select Region',
      searchHint: 'Search region...',
      searchController: _searchController,
      onSearchChanged: (value) {
        setState(() {
          _query = value;
        });
      },
      emptyMessage: 'No region found',
      itemCount: _filteredRegions.length,
      itemBuilder: (context, index) {
        final region = _filteredRegions[index];
        final selected = region.id == widget.selectedRegionId;

        return _PickerTile(
          title: region.name,
          subtitle: _regionSubtitle(region),
          selected: selected,
          onTap: () => Navigator.of(context).pop(region),
        );
      },
    );
  }

  String _regionSubtitle(TaxRegionModel region) {
    final parts = [
      region.code.trim(),
      region.countryName.trim(),
    ].where((part) => part.isNotEmpty).join(' • ');

    return parts.isEmpty ? 'Region' : parts;
  }
}

class _SearchBottomSheetContainer extends StatelessWidget {
  final String title;
  final String searchHint;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String emptyMessage;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  const _SearchBottomSheetContainer({
    required this.title,
    required this.searchHint,
    required this.searchController,
    required this.onSearchChanged,
    required this.emptyMessage,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final height = MediaQuery.of(context).size.height * 0.78;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: AppThemeTokens.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppThemeTokens.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: searchHint,
                    hintStyle: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    border: _border(),
                    enabledBorder: _border(),
                    focusedBorder: _border(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: AppThemeTokens.border),
              Expanded(
                child: itemCount == 0
                    ? Center(
                        child: Text(
                          emptyMessage,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                        itemCount: itemCount,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 4);
                        },
                        itemBuilder: itemBuilder,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color color = AppThemeTokens.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PickerTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: selected ? primary.withValues(alpha: 0.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        subtitle: subtitle.trim().isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
        trailing: selected
            ? Icon(
                Icons.check_circle,
                color: primary,
              )
            : const Icon(
                Icons.chevron_right,
                color: AppThemeTokens.textSecondary,
              ),
      ),
    );
  }
}

class _DropdownText extends StatelessWidget {
  final String text;

  const _DropdownText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
    );
  }
}

class _HelpText extends StatelessWidget {
  final String text;

  const _HelpText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: AppThemeTokens.textSecondary,
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;

  const _ErrorText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.red,
      ),
    );
  }
}

class _DividerSpace extends StatelessWidget {
  const _DividerSpace();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, color: AppThemeTokens.border),
    );
  }
}

InputDecoration _dropdownDecoration(BuildContext context) {
  OutlineInputBorder border({Color color = AppThemeTokens.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }

  return InputDecoration(
    filled: true,
    fillColor: AppThemeTokens.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 13,
    ),
    border: border(),
    enabledBorder: border(),
    focusedBorder: border(
      color: Theme.of(context).colorScheme.primary,
    ),
    errorBorder: border(color: Colors.red),
    focusedErrorBorder: border(color: Colors.red),
  );
}