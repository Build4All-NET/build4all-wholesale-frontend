import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/widgets/app_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/widgets/searchable_selection_field.dart';
import '../../../../../injection_container.dart';
import '../../data/models/shipping_location_model.dart';
import '../../data/services/shipping_location_api_service.dart';
import '../../domain/entities/shipping_method_entity.dart';
import '../bloc/shipping_methods_bloc.dart';
import '../bloc/shipping_methods_event.dart';
import '../bloc/shipping_methods_state.dart';

class CreateShippingMethodScreen extends StatelessWidget {
  final ShippingMethodEntity? method;

  const CreateShippingMethodScreen({
    super.key,
    this.method,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShippingMethodsBloc>(
      create: (_) => sl<ShippingMethodsBloc>(),
      child: _CreateShippingMethodView(method: method),
    );
  }
}

class _CreateShippingMethodView extends StatefulWidget {
  final ShippingMethodEntity? method;

  const _CreateShippingMethodView({
    this.method,
  });

  @override
  State<_CreateShippingMethodView> createState() =>
      _CreateShippingMethodViewState();
}

class _CreateShippingMethodViewState extends State<_CreateShippingMethodView> {
  final _formKey = GlobalKey<FormState>();

  final ApiClient _projectApiClient =
      sl<ApiClient>(instanceName: 'projectApiClient');

  late final ShippingLocationApiService _locationApiService;

  late final TextEditingController _methodNameController;
  late final TextEditingController _shippingCostController;
  late final TextEditingController _estimatedDeliveryTimeController;
  late final TextEditingController _minimumOrderAmountController;
  late final TextEditingController _freeShippingThresholdController;
  late final TextEditingController _notesController;

  ShippingMethodType _methodType = ShippingMethodType.standardDelivery;
  ShippingBranchScope _branchScope = ShippingBranchScope.allBranches;

  String? _selectedCountryId;
  String? _selectedRegionId;

  bool _active = true;

  bool _loadingCountries = true;
  bool _loadingRegions = false;
  bool _loadingBranches = true;

  String? _countryErrorMessage;
  String? _regionErrorMessage;
  String? _branchErrorMessage;

  final List<ShippingCountryModel> _countries = [];
  final List<ShippingRegionModel> _regions = [];
  final List<_ShippingBranchOption> _branches = [];

  final List<String> _selectedBranchIds = [];
  final List<String> _selectedBranchNames = [];

  bool get _isEditMode => widget.method != null;

  bool get _isPickup => _methodType == ShippingMethodType.pickup;

  ShippingCountryModel? get _selectedCountry {
    if (_selectedCountryId == null) return null;

    final matches = _countries.where(
      (country) => country.id == _selectedCountryId,
    );

    return matches.isEmpty ? null : matches.first;
  }

  bool get _selectedCountryIsLebanon {
    return _selectedCountry?.isLebanon == true;
  }

  @override
  void initState() {
    super.initState();

    _locationApiService = ShippingLocationApiService(_projectApiClient);

    final method = widget.method;

    _methodNameController = TextEditingController(text: method?.name ?? '');
    _shippingCostController = TextEditingController(
      text: method == null || method.isPickup ? '' : method.cost.toString(),
    );
    _estimatedDeliveryTimeController = TextEditingController(
      text: method?.estimatedDeliveryTime ?? '',
    );
    _minimumOrderAmountController = TextEditingController(
      text: method?.minimumOrderAmount?.toString() ?? '',
    );
    _freeShippingThresholdController = TextEditingController(
      text: method?.freeShippingThreshold?.toString() ?? '',
    );
    _notesController = TextEditingController(text: method?.notes ?? '');

    _methodType = method?.methodType ?? ShippingMethodType.standardDelivery;
    _branchScope = method?.branchScope ?? ShippingBranchScope.allBranches;

    _selectedCountryId = method?.countryId;
    _selectedRegionId = method?.regionId;

    _active = method?.active ?? true;

    _selectedBranchIds.addAll(method?.selectedBranchIds ?? []);
    _selectedBranchNames.addAll(method?.selectedBranchNames ?? []);

    if (_isPickup) {
      _shippingCostController.clear();
      _freeShippingThresholdController.clear();

      if (_estimatedDeliveryTimeController.text.trim().isEmpty) {
        _estimatedDeliveryTimeController.text = 'Pickup from branch';
      }
    }

    _loadInitialLookups();
  }

  @override
  void dispose() {
    _methodNameController.dispose();
    _shippingCostController.dispose();
    _estimatedDeliveryTimeController.dispose();
    _minimumOrderAmountController.dispose();
    _freeShippingThresholdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialLookups() async {
    await Future.wait([
      _loadCountries(),
      _loadBranches(),
    ]);
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
            _selectedRegionId = null;
            _regions.clear();
          }
        }

        _loadingCountries = false;
      });

      if (_selectedCountryId != null && _selectedCountryId!.isNotEmpty) {
        await _loadRegionsForSelectedCountry(resetRegionIfNeeded: false);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _countryErrorMessage = e.toString();
        _loadingCountries = false;
      });
    }
  }

  Future<void> _loadRegionsForSelectedCountry({
    bool resetRegionIfNeeded = true,
  }) async {
    final countryId = _selectedCountryId;

    if (countryId == null || countryId.isEmpty) {
      setState(() {
        _regions.clear();
        _selectedRegionId = null;
      });
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

        if (resetRegionIfNeeded) {
          _selectedRegionId = null;
        }

        if (_selectedRegionId != null &&
            !_regions.any((region) => region.id == _selectedRegionId)) {
          _selectedRegionId = null;
        }

        _loadingRegions = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _regionErrorMessage = e.toString();
        _loadingRegions = false;
      });
    }
  }

  Future<void> _loadBranches() async {
    setState(() {
      _loadingBranches = true;
      _branchErrorMessage = null;
    });

    try {
      final response = await _projectApiClient.dio.get(
        ApiConfig.supplierBranches,
      );

      final data = response.data;
      final branches = <_ShippingBranchOption>[];

      if (data is List) {
        for (final item in data) {
          if (item is! Map) continue;

          final json = Map<String, dynamic>.from(item);
          final status = json['status']?.toString().toUpperCase();

          if (status != null && status != 'ACTIVE') {
            continue;
          }

          final branch = _ShippingBranchOption.fromJson(json);

          if (branch.id.isNotEmpty) {
            branches.add(branch);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _branches
          ..clear()
          ..addAll(branches);
        _loadingBranches = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _branchErrorMessage = e.toString();
        _loadingBranches = false;
      });
    }
  }

  void _handleMethodTypeChanged(ShippingMethodType? value) {
    if (value == null) return;

    setState(() {
      _methodType = value;

      if (_isPickup) {
        _shippingCostController.clear();
        _freeShippingThresholdController.clear();

        if (_estimatedDeliveryTimeController.text.trim().isEmpty ||
            _estimatedDeliveryTimeController.text.trim() !=
                'Pickup from branch') {
          _estimatedDeliveryTimeController.text = 'Pickup from branch';
        }
      }
    });
  }

  Future<void> _handleCountryChanged(String? countryId) async {
    if (countryId == null || countryId.trim().isEmpty) return;

    setState(() {
      _selectedCountryId = countryId;
      _selectedRegionId = null;
      _regions.clear();
    });

    await _loadRegionsForSelectedCountry(resetRegionIfNeeded: true);
  }

  void _toggleBranch(_ShippingBranchOption branch, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedBranchIds.contains(branch.id)) {
          _selectedBranchIds.add(branch.id);
          _selectedBranchNames.add(branch.label);
        }
      } else {
        _selectedBranchIds.remove(branch.id);
        _selectedBranchNames.remove(branch.label);
      }
    });
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.supplierFieldRequired(fieldName);
    }

    return null;
  }

  String? _requiredPositiveOrZeroNumber(String? value, String fieldName) {
    final requiredError = _required(value, fieldName);
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());

    if (parsed == null || parsed < 0) {
      return context.l10n.supplierFieldGreaterThanOrEqualZero(fieldName);
    }

    return null;
  }

  String? _optionalPositiveOrZeroNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;

    final parsed = double.tryParse(value.trim());

    if (parsed == null || parsed < 0) {
      return context.l10n.supplierFieldValidNumber(fieldName);
    }

    return null;
  }

  double? _parseOptionalDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  bool _validateLocation(BuildContext context) {
    if (_selectedCountryId == null || _selectedCountryId!.trim().isEmpty) {
      AppToast.error(context, context.l10n.supplierPleaseSelectACountry);
      return false;
    }

    if (_selectedCountryIsLebanon &&
        (_selectedRegionId == null || _selectedRegionId!.trim().isEmpty)) {
      AppToast.error(context, context.l10n.supplierPleaseSelectARegionForLebanon);
      return false;
    }

    return true;
  }

  void _saveShippingMethod(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateLocation(context)) return;

    if (_branchScope == ShippingBranchScope.selectedBranches &&
        _selectedBranchIds.isEmpty) {
      AppToast.error(context, context.l10n.supplierPleaseSelectAtLeastOneBranch);
      return;
    }

    final now = DateTime.now();

    final method = ShippingMethodEntity(
      id: widget.method?.id ?? '',
      name: _methodNameController.text.trim(),
      methodType: _methodType,
      countryId: _selectedCountryId,
      countryName: _selectedCountry?.name,
      countryIso2Code: _selectedCountry?.iso2Code,
      countryIso3Code: _selectedCountry?.iso3Code,
      regionId: _selectedRegionId,
      regionName: _selectedRegionId == null
          ? null
          : _regions
              .where((region) => region.id == _selectedRegionId)
              .map((region) => region.name)
              .firstOrNull,
      regionCode: _selectedRegionId == null
          ? null
          : _regions
              .where((region) => region.id == _selectedRegionId)
              .map((region) => region.code)
              .firstOrNull,
      cost: _isPickup
          ? 0
          : double.tryParse(_shippingCostController.text.trim()) ?? 0,
      estimatedDeliveryTime: _isPickup
          ? 'Pickup from branch'
          : _estimatedDeliveryTimeController.text.trim(),
      minimumOrderAmount:
          _parseOptionalDouble(_minimumOrderAmountController.text),
      freeShippingThreshold: _isPickup
          ? null
          : _parseOptionalDouble(_freeShippingThresholdController.text),
      branchScope: _branchScope,
      selectedBranchIds: _branchScope == ShippingBranchScope.allBranches
          ? []
          : List.unmodifiable(_selectedBranchIds),
      selectedBranchNames: _branchScope == ShippingBranchScope.allBranches
          ? []
          : List.unmodifiable(_selectedBranchNames),
      active: _active,
      status: widget.method?.status,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.method?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditMode) {
      context.read<ShippingMethodsBloc>().add(
            UpdateShippingMethodRequested(method),
          );
    } else {
      context.read<ShippingMethodsBloc>().add(
            CreateShippingMethodRequested(method),
          );
    }
  }

  void _cancel() {
    if (_isEditMode) {
      context.go('/supplier-shipping');
    } else {
      context.go('/supplier-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<ShippingMethodsBloc, ShippingMethodsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);

          context.read<ShippingMethodsBloc>().add(
                const ClearShippingMethodMessageRequested(),
              );
          return;
        }

        if (state.successMessage != null) {
          AppToast.success(context, state.successMessage!);

          context.read<ShippingMethodsBloc>().add(
                const ClearShippingMethodMessageRequested(),
              );

          if (_isEditMode) {
            context.go('/supplier-shipping');
          } else {
            context.go('/supplier-dashboard');
          }
        }
      },
      child: BlocBuilder<ShippingMethodsBloc, ShippingMethodsState>(
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
                _isEditMode
                    ? context.l10n.supplierEditShippingMethod
                    : context.l10n.supplierCreateShippingMethod,
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
                              : () => _saveShippingMethod(context),
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
                                        ? context.l10n.supplierUpdateMethod
                                        : context.l10n.supplierCreateMethod,
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
                        title: context.l10n.supplierMethodInformation,
                        children: [
                          _FieldLabel(context.l10n.supplierMethodName),
                          _InputField(
                            controller: _methodNameController,
                            hintText: context.l10n.supplierShippingNameHint,
                            validator: (value) {
                              return _required(value, context.l10n.supplierMethodNamePlain);
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierMethodType),
                          _MethodTypeDropdown(
                            value: _methodType,
                            onChanged: _handleMethodTypeChanged,
                          ),
                          const SizedBox(height: 8),
                          _HelpText(text: _methodType.description),
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
                            text:
                                context.l10n.supplierCountryAndRegionAreUsedLaterByRetailerCheckoutToShowTheCorrectShippingOptions,
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppThemeTokens.border),
                          const SizedBox(height: 8),
                          _CompactRefreshAction(
                            onPressed: _selectedCountryId == null || _loadingRegions
                                ? null
                                : () => _loadRegionsForSelectedCountry(
                                      resetRegionIfNeeded: false,
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
                              selectedRegionId: _selectedRegionId,
                              required: true,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRegionId = value;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierPricingTiming,
                        children: [
                          _FieldLabel(context.l10n.supplierShippingCost),
                          _InputField(
                            controller: _shippingCostController,
                            hintText: _isPickup ? context.l10n.supplierPickupIsFree : '5',
                            enabled: !_isPickup,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (_isPickup) return null;

                              return _requiredPositiveOrZeroNumber(
                                value,
                                context.l10n.supplierShippingCostPlain,
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierEstimatedDeliveryTime),
                          _InputField(
                            controller: _estimatedDeliveryTimeController,
                            hintText: _isPickup
                                ? context.l10n.supplierPickupFromBranch
                                : context.l10n.supplierBusinessDaysHint,
                            enabled: !_isPickup,
                            validator: (value) {
                              if (_isPickup) return null;

                              return _required(
                                value,
                                context.l10n.supplierEstimatedDeliveryTimePlain,
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierMinimumOrderAmount),
                          _InputField(
                            controller: _minimumOrderAmountController,
                            hintText: '50',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _optionalPositiveOrZeroNumber(
                                value,
                                context.l10n.supplierMinimumOrderAmountPlain,
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierFreeShippingThreshold),
                          _InputField(
                            controller: _freeShippingThresholdController,
                            hintText:
                                _isPickup ? context.l10n.supplierPickupOnly : '200',
                            enabled: !_isPickup,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (_isPickup) return null;

                              return _optionalPositiveOrZeroNumber(
                                value,
                                context.l10n.supplierFreeShippingThresholdPlain,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierBranchApplicability,
                        children: [
                          _FieldLabel(context.l10n.supplierAppliesTo),
                          _BranchScopeDropdown(
                            value: _branchScope,
                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                _branchScope = value;

                                if (_branchScope ==
                                    ShippingBranchScope.allBranches) {
                                  _selectedBranchIds.clear();
                                  _selectedBranchNames.clear();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          _HelpText(
                            text:
                                context.l10n.supplierBranchesDefineWhereThisShippingMethodIsValidRetailerCheckoutWillLaterMatchShippingWithFulfillmentBranch,
                          ),
                          if (_branchScope ==
                              ShippingBranchScope.selectedBranches) ...[
                            const _DividerSpace(),
                            Row(
                              children: [
                                Expanded(
                                  child: _FieldLabel(context.l10n.supplierSelectBranches),
                                ),
                                TextButton(
                                  onPressed:
                                      _loadingBranches ? null : _loadBranches,
                                  child: Text(
                                    context.l10n.refreshButton,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_loadingBranches)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_branchErrorMessage != null)
                              _ErrorText(message: _branchErrorMessage!)
                            else if (_branches.isEmpty)
                              Text(
                                context.l10n.supplierNoActiveBranchesAvailableAddBranchesFirst,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppThemeTokens.textSecondary,
                                ),
                              )
                            else
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _branches.map((branch) {
                                  final selected =
                                      _selectedBranchIds.contains(branch.id);

                                  return FilterChip(
                                    selected: selected,
                                    label: Text(branch.label),
                                    selectedColor:
                                        primary.withValues(alpha: 0.15),
                                    checkmarkColor: primary,
                                    onSelected: (isSelected) {
                                      _toggleBranch(branch, isSelected);
                                    },
                                  );
                                }).toList(),
                              ),
                          ],
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
                          _FieldLabel(context.l10n.notesLabel),
                          _InputField(
                            controller: _notesController,
                            hintText:
                                context.l10n.supplierOptionalNotesAboutThisShippingMethod,
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

  _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
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

class _MethodTypeDropdown extends StatelessWidget {
  final ShippingMethodType value;
  final ValueChanged<ShippingMethodType?> onChanged;

  const _MethodTypeDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ShippingMethodType>(
      initialValue: value,
      items: ShippingMethodType.values
          .map(
            (type) => DropdownMenuItem<ShippingMethodType>(
              value: type,
              child: Text(_localizedEnumLabel(context, type.label)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
      decoration: _dropdownDecoration(context),
    );
  }
}

class _BranchScopeDropdown extends StatelessWidget {
  final ShippingBranchScope value;
  final ValueChanged<ShippingBranchScope?> onChanged;

  const _BranchScopeDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ShippingBranchScope>(
      initialValue: value,
      items: ShippingBranchScope.values
          .map(
            (scope) => DropdownMenuItem<ShippingBranchScope>(
              value: scope,
              child: Text(_localizedEnumLabel(context, scope.label)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
      decoration: _dropdownDecoration(context),
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  final List<ShippingCountryModel> countries;
  final String? selectedCountryId;
  final ValueChanged<String?> onChanged;

  const _CountryDropdown({
    required this.countries,
    required this.selectedCountryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    ShippingCountryModel? selectedCountry;
    for (final country in countries) {
      if (country.id == selectedCountryId) {
        selectedCountry = country;
        break;
      }
    }

    return SearchableSelectionField<ShippingCountryModel>(
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

class _RegionDropdown extends StatelessWidget {
  final List<ShippingRegionModel> regions;
  final String? selectedRegionId;
  final bool required;
  final ValueChanged<String?> onChanged;

  const _RegionDropdown({
    required this.regions,
    required this.selectedRegionId,
    required this.required,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    ShippingRegionModel? selectedRegion;
    for (final region in regions) {
      if (region.id == selectedRegionId) {
        selectedRegion = region;
        break;
      }
    }

    return SearchableSelectionField<ShippingRegionModel>(
      label: required ? context.l10n.regionRequiredLabel : context.l10n.regionLabel,
      hintText: context.l10n.selectRegionHint,
      searchHintText: context.l10n.searchRegionHint,
      items: regions,
      itemLabel: (region) => region.name,
      value: selectedRegion,
      onSelected: (region) => onChanged(region.id),
      validator: (region) {
        if (!required) return null;
        if (region == null || region.id.trim().isEmpty) {
          return context.l10n.supplierRegionIsRequiredForLebanon;
        }
        return null;
      },
      emptyText: context.l10n.noRegionsFound,
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
    return SearchableSelectionField<ShippingRegionModel>(
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

String _localizedEnumLabel(BuildContext context, String label) {
  switch (label) {
    case 'Pickup from Branch':
      return context.l10n.supplierPickupFromBranch;
    case 'Express Delivery':
      return context.l10n.supplierExpressDelivery;
    case 'Standard Delivery':
      return context.l10n.supplierStandardDelivery;
    case 'All Branches':
      return context.l10n.supplierAllBranches;
    case 'Selected Branches':
      return context.l10n.supplierSelectedBranches;
    case 'Percent':
      return context.l10n.supplierPercent;
    case 'Fixed Amount':
      return context.l10n.supplierFixedAmount;
    case 'Fixed':
      return context.l10n.supplierFixed;
    case 'Free Shipping':
      return context.l10n.supplierFreeShipping;
    case 'All Products':
      return context.l10n.supplierAllProducts;
    case 'Product':
      return context.l10n.productLabel;
    case 'Category':
      return context.l10n.categoryLabel;
    case 'SubCategory':
      return context.l10n.subCategoryLabel;
    case 'Subcategory':
      return context.l10n.subcategoryLabel;
    case 'None':
      return context.l10n.noneLabel;
    case 'URL':
      return context.l10n.urlLabel;
    default:
      return label;
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

class _ShippingBranchOption {
  final String id;
  final String label;

  const _ShippingBranchOption({
    required this.id,
    required this.label,
  });

  factory _ShippingBranchOption.fromJson(Map<String, dynamic> json) {
    final id = _firstNonEmpty(json, ['id', 'branchId']);
    final name = _firstNonEmpty(json, ['name', 'branchName', 'title']);
    final city = _firstNonEmpty(json, ['city']);

    final label = city.isEmpty ? name : '$name • $city';

    return _ShippingBranchOption(
      id: id,
      label: label.trim().isEmpty ? 'Branch #$id' : label,
    );
  }

  static String _firstNonEmpty(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }
}