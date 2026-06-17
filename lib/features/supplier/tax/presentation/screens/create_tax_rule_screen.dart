import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/widgets/app_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/widgets/searchable_selection_field.dart';
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
  static const String _noRegionValue = '__NO_REGION__';

  final _formKey = GlobalKey<FormState>();

  final ApiClient _projectApiClient =
      sl<ApiClient>(instanceName: 'projectApiClient');

  late final TaxLocationApiService _locationApiService;

  late final TextEditingController _ruleNameController;
  late final TextEditingController _rateController;
  late final TextEditingController _notesController;

  TaxRulePreset _selectedPreset = TaxRulePreset.custom;

  String? _selectedCountryId;
  String? _selectedRegionValue;

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

  bool get _selectedCountryIsLebanon {
    return _selectedCountry?.isLebanon == true;
  }

  TaxRegionModel? get _selectedRegion {
    if (_selectedRegionValue == null ||
        _selectedRegionValue == _noRegionValue) {
      return null;
    }

    final matches = _regions.where(
      (region) => region.id == _selectedRegionValue,
    );

    return matches.isEmpty ? null : matches.first;
  }

  String? get _requestRegionId {
    if (_selectedRegionValue == null ||
        _selectedRegionValue == _noRegionValue) {
      return null;
    }

    return _selectedRegionValue;
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
    _selectedRegionValue = rule?.regionId ?? _noRegionValue;

    _appliesToShipping = rule?.appliesToShipping ?? false;
    _active = rule?.active ?? true;

    // In create mode, generate name automatically.
    // In edit mode, preserve saved name unless supplier turns it on.
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

        if (_selectedCountryId != null && _selectedCountryId!.isNotEmpty) {
          final exists = countries.any(
            (country) => country.id == _selectedCountryId,
          );

          if (!exists) {
            _selectedCountryId = null;
            _selectedRegionValue = _noRegionValue;
            _regions.clear();
          }
        } else {
          _selectedCountryId = null;
          _selectedRegionValue = _noRegionValue;
          _regions.clear();
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
        _selectedRegionValue = _noRegionValue;
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
          _selectedRegionValue = _noRegionValue;
        }

        if (_selectedRegionValue != null &&
            _selectedRegionValue != _noRegionValue &&
            !_regions.any((region) => region.id == _selectedRegionValue)) {
          _selectedRegionValue = _noRegionValue;
        }

        _selectedRegionValue ??= _noRegionValue;

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
      _selectedRegionValue = _noRegionValue;
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
          _selectedRegionValue = _noRegionValue;
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
      return context.l10n.supplierFieldRequired(fieldName);
    }

    return null;
  }

  String? _rateValidator(String? value) {
    final requiredError = _required(value, context.l10n.supplierTaxRatePlain);
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());

    if (parsed == null || parsed <= 0) {
      return context.l10n.supplierTaxRateMustBeGreaterThan0;
    }

    if (parsed > 100) {
      return context.l10n.supplierTaxRateCannotBeGreaterThan100;
    }

    return null;
  }

  bool _validateLocation(BuildContext context) {
    if (_selectedCountryId == null || _selectedCountryId!.trim().isEmpty) {
      AppToast.error(context, context.l10n.supplierPleaseSelectACountry);
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
      regionId: _requestRegionId,
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
          AppToast.error(context, state.errorMessage!);

          context.read<TaxRulesBloc>().add(
                const ClearTaxRuleMessageRequested(),
              );
          return;
        }

        if (state.successMessage != null) {
          AppToast.success(context, state.successMessage!);

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
                _isEditMode ? context.l10n.supplierEditTaxRule : context.l10n.supplierCreateTaxRule,
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
                          child: Text(
                            context.l10n.cancelButton,
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
                                  : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _isEditMode
                                        ? context.l10n.supplierUpdateRule
                                        : context.l10n.supplierCreateRule,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.visible,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
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
                        title: context.l10n.supplierTaxRuleInformation,
                        children: [
                          _FieldLabel(context.l10n.supplierRulePreset),
                          _TaxRulePresetDropdown(
                            value: _selectedPreset,
                            onChanged: _handlePresetChanged,
                          ),
                          const SizedBox(height: 8),
                          _HelpText(
                            text:
                                context.l10n.supplierChooseAPresetOrKeepCustomAndEnterYourOwnOrderLevelTaxRule,
                          ),
                          const _DividerSpace(),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.supplierAutoGenerateName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppThemeTokens.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _autoGenerateName,
                                thumbColor: WidgetStateProperty.all(Colors.white),
                                activeTrackColor: primary,
                                inactiveTrackColor: const Color(0xFFD1D5DB),
                                onChanged: _handleAutoGenerateChanged,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _FieldLabel(context.l10n.supplierRuleName),
                          _InputField(
                            controller: _ruleNameController,
                            hintText: context.l10n.supplierLebanonVat,
                            enabled: !_autoGenerateName,
                            validator: (value) {
                              return _required(value, context.l10n.supplierRuleNamePlain);
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierTaxRate),
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
                          _HelpText(
                            text:
                                context.l10n.supplierExampleEnter11For11TaxIsAppliedToTheWholeOrderBasedOnCountryAndRegion,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierLocation,
                        children: [
                          _CompactRefreshAction(
                            onPressed: _loadingCountries ? null : _loadCountries,
                          ),
                          const SizedBox(height: 4),
                          if (_loadingCountries)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_countryErrorMessage != null)
                            _ErrorText(message: _countryErrorMessage!)
                          else
                            _CountryDropdown(
                              countries: _countries,
                              selectedCountryId: _selectedCountryId,
                              onChanged: _handleCountryChanged,
                            ),
                          const SizedBox(height: 8),
                          _HelpText(
                            text: context.l10n
                                .supplierCountryIsRequiredBecauseTaxIsCalculatedFromTheRetailerDeliveryCountry,
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppThemeTokens.border),
                          const SizedBox(height: 8),
                          _CompactRefreshAction(
                            onPressed: _selectedCountryId == null ||
                                    _loadingRegions ||
                                    !_selectedCountryIsLebanon
                                ? null
                                : () => _loadRegionsForSelectedCountry(
                                      resetRegion: false,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          if (_loadingRegions)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_regionErrorMessage != null)
                            _ErrorText(message: _regionErrorMessage!)
                          else if (_selectedCountryId == null ||
                              _selectedCountryId!.trim().isEmpty)
                            _DisabledRegionField(
                              label: context.l10n.regionLabel,
                              hintText: context.l10n.selectCountryFirst,
                            )
                          else if (!_selectedCountryIsLebanon)
                            _DisabledRegionField(
                              label: context.l10n.regionLabel,
                              hintText: context
                                  .l10n
                                  .supplierNoRegionsAvailableForCountry,
                            )
                          else
                            _RegionDropdown(
                              regions: _regions,
                              selectedRegionValue:
                                  _selectedRegionValue ?? _noRegionValue,
                              noRegionValue: _noRegionValue,
                              enabled: _regions.isNotEmpty,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRegionValue =
                                      value ?? _noRegionValue;
                                });

                                _syncGeneratedNameIfNeeded();
                              },
                            ),
                          const SizedBox(height: 8),
                          _HelpText(
                            text: context.l10n
                                .supplierChooseNoRegionForACountryLevelRuleOrChooseASpecificRegionForAMoreSpecificRule,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierTaxApplicability,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.supplierApplyTaxToShippingCost,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppThemeTokens.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _appliesToShipping,
                                thumbColor: WidgetStateProperty.all(Colors.white),
                                activeTrackColor: primary,
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
                          _HelpText(
                            text:
                                context.l10n.supplierIfEnabledCheckoutTaxWillIncludeShippingCostIfDisabledTaxAppliesOnlyToItemsAfterPromotionDiscount,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierStatusNotes,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.activeStatus,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppThemeTokens.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _active,
                                thumbColor: WidgetStateProperty.all(Colors.white),
                                activeTrackColor: primary,
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
                          _FieldLabel(context.l10n.notesLabel),
                          _InputField(
                            controller: _notesController,
                            hintText: context.l10n.supplierOptionalNotesAboutThisTaxRule,
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

  _SectionCard({
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

  _FieldLabel(this.text);

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

  _InputField({
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
      borderRadius: BorderRadius.circular(14),
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
      value: value,
      items: TaxRulePreset.values.map((preset) {
        return DropdownMenuItem<TaxRulePreset>(
          value: preset,
          child: _DropdownText(_localizedTaxRulePresetLabel(context, preset)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: _dropdownDecoration(context),
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  final List<TaxCountryModel> countries;
  final String? selectedCountryId;
  final ValueChanged<String?> onChanged;

  const _CountryDropdown({
    required this.countries,
    required this.selectedCountryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    TaxCountryModel? selectedCountry;
    for (final country in countries) {
      if (country.id == selectedCountryId) {
        selectedCountry = country;
        break;
      }
    }

    return SearchableSelectionField<TaxCountryModel>(
      label: context.l10n.countryRequiredLabel,
      hintText: context.l10n.selectCountryHint,
      searchHintText: context.l10n.searchCountryHint,
      items: countries,
      itemLabel: (country) => country.name,
      value: selectedCountry,
      onSelected: (country) => onChanged(country.id),
      validator: (country) {
        if (country == null || country.id.trim().isEmpty) {
          return context.l10n.supplierCountryIsRequired;
        }
        return null;
      },
      emptyText: context.l10n.noCountriesFound,
    );
  }
}


class _DisabledRegionField extends StatelessWidget {
  final String label;
  final String hintText;

  const _DisabledRegionField({
    required this.label,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return SearchableSelectionField<TaxRegionModel>(
      label: label,
      hintText: hintText,
      searchHintText: context.l10n.searchRegionHint,
      items: const [],
      itemLabel: (region) => region.name,
      value: null,
      enabled: false,
      onSelected: (_) {},
      emptyText: context.l10n.noRegionsFound,
    );
  }
}

class _CompactRefreshAction extends StatelessWidget {
  final VoidCallback? onPressed;

  const _CompactRefreshAction({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: SizedBox(
        height: 32,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            context.l10n.refreshButton,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionDropdown extends StatelessWidget {
  final List<TaxRegionModel> regions;
  final String selectedRegionValue;
  final String noRegionValue;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const _RegionDropdown({
    required this.regions,
    required this.selectedRegionValue,
    required this.noRegionValue,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <_TaxRegionOption>[
      _TaxRegionOption(
        id: noRegionValue,
        name: context.l10n.noRegionLabel,
      ),
      ...regions.map(
        (region) => _TaxRegionOption(
          id: region.id,
          name: region.name,
        ),
      ),
    ];

    final selectedOption = options.firstWhere(
      (option) => option.id == selectedRegionValue,
      orElse: () => options.first,
    );

    return SearchableSelectionField<_TaxRegionOption>(
      label: context.l10n.regionLabel,
      hintText: context.l10n.selectRegionHint,
      searchHintText: context.l10n.searchRegionHint,
      items: options,
      itemLabel: (option) => option.name,
      value: selectedOption,
      enabled: enabled,
      onSelected: (option) => onChanged(option.id),
      emptyText: context.l10n.noRegionsFound,
    );
  }
}

class _TaxRegionOption {
  final String id;
  final String name;

  const _TaxRegionOption({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    return other is _TaxRegionOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class _DropdownText extends StatelessWidget {
  final String text;

  _DropdownText(this.text);

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

  _HelpText({required this.text});

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


String _localizedTaxRulePresetLabel(BuildContext context, TaxRulePreset preset) {
  switch (preset) {
    case TaxRulePreset.custom:
      return 'Custom';
    case TaxRulePreset.lebanonVat:
      return 'Lebanon VAT';
  }
}

InputDecoration _dropdownDecoration(BuildContext context) {
  OutlineInputBorder border({Color color = AppThemeTokens.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
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