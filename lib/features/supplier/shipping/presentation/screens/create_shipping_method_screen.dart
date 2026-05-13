import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
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

  ShippingRegionModel? get _selectedRegion {
    if (_selectedRegionId == null) return null;

    final matches = _regions.where(
      (region) => region.id == _selectedRegionId,
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

        if (_selectedCountryIsLebanon &&
            _selectedRegionId == null &&
            _regions.isNotEmpty) {
          _selectedRegionId = _regions.first.id;
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
      return '$fieldName is required';
    }

    return null;
  }

  String? _requiredPositiveOrZeroNumber(String? value, String fieldName) {
    final requiredError = _required(value, fieldName);
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());

    if (parsed == null || parsed < 0) {
      return '$fieldName must be greater than or equal to 0';
    }

    return null;
  }

  String? _optionalPositiveOrZeroNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;

    final parsed = double.tryParse(value.trim());

    if (parsed == null || parsed < 0) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  double? _parseOptionalDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  bool _validateLocation(BuildContext context) {
    if (_selectedCountryId == null || _selectedCountryId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country')),
      );
      return false;
    }

    if (_selectedCountryIsLebanon &&
        (_selectedRegionId == null || _selectedRegionId!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a region for Lebanon')),
      );
      return false;
    }

    return true;
  }

  void _saveShippingMethod(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateLocation(context)) return;

    if (_branchScope == ShippingBranchScope.selectedBranches &&
        _selectedBranchIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one branch')),
      );
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
      regionName: _selectedRegion?.name,
      regionCode: _selectedRegion?.code,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );

          context.read<ShippingMethodsBloc>().add(
                const ClearShippingMethodMessageRequested(),
              );
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );

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
                    ? 'Edit Shipping Method'
                    : 'Create Shipping Method',
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
                              : Text(
                                  _isEditMode
                                      ? 'Update Method'
                                      : 'Create Method',
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
                        title: 'Method Information',
                        children: [
                          _FieldLabel('Method Name *'),
                          _InputField(
                            controller: _methodNameController,
                            hintText: 'Beirut Standard Delivery',
                            validator: (value) {
                              return _required(value, 'Method Name');
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Method Type *'),
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
                            _CountrySearchField(
                              countries: _countries,
                              selectedCountryId: _selectedCountryId,
                              onChanged: _handleCountryChanged,
                            ),
                          const SizedBox(height: 8),
                          const _HelpText(
                            text:
                                'Country and region are used later by retailer checkout to show the correct shipping options.',
                          ),
                          const _DividerSpace(),
                          Row(
                            children: [
                              Expanded(
                                child: _FieldLabel(
                                  _selectedCountryIsLebanon
                                      ? 'Region *'
                                      : 'Region',
                                ),
                              ),
                              TextButton(
                                onPressed: _selectedCountryId == null ||
                                        _loadingRegions
                                    ? null
                                    : () => _loadRegionsForSelectedCountry(
                                          resetRegionIfNeeded: false,
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
                          else if (_regions.isEmpty)
                            const Text(
                              'No regions available for this country.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppThemeTokens.textSecondary,
                              ),
                            )
                          else
                            _RegionSearchField(
                              regions: _regions,
                              selectedRegionId: _selectedRegionId,
                              required: _selectedCountryIsLebanon,
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
                        title: 'Pricing & Timing',
                        children: [
                          _FieldLabel('Shipping Cost'),
                          _InputField(
                            controller: _shippingCostController,
                            hintText: _isPickup ? 'Pickup is free' : '5',
                            enabled: !_isPickup,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (_isPickup) return null;

                              return _requiredPositiveOrZeroNumber(
                                value,
                                'Shipping Cost',
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Estimated Delivery Time'),
                          _InputField(
                            controller: _estimatedDeliveryTimeController,
                            hintText: _isPickup
                                ? 'Pickup from branch'
                                : '2-3 business days',
                            enabled: !_isPickup,
                            validator: (value) {
                              if (_isPickup) return null;

                              return _required(
                                value,
                                'Estimated Delivery Time',
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Minimum Order Amount'),
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
                                'Minimum Order Amount',
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Free Shipping Threshold'),
                          _InputField(
                            controller: _freeShippingThresholdController,
                            hintText: _isPickup ? 'Pickup only' : '200',
                            enabled: !_isPickup,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (_isPickup) return null;

                              return _optionalPositiveOrZeroNumber(
                                value,
                                'Free Shipping Threshold',
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Branch Applicability',
                        children: [
                          _FieldLabel('Applies To *'),
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
                          const _HelpText(
                            text:
                                'Branches define where this shipping method is valid. Retailer checkout will later match shipping with fulfillment branch.',
                          ),
                          if (_branchScope ==
                              ShippingBranchScope.selectedBranches) ...[
                            const _DividerSpace(),
                            Row(
                              children: [
                                const Expanded(
                                  child: _FieldLabel('Select Branches'),
                                ),
                                TextButton(
                                  onPressed:
                                      _loadingBranches ? null : _loadBranches,
                                  child: const Text(
                                    'Refresh',
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
                              const Text(
                                'No active branches available. Add branches from Branch Management first.',
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
                            hintText:
                                'Optional notes about this shipping method',
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

  const _InputField({
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
      borderRadius: BorderRadius.circular(6),
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
      isExpanded: true,
      initialValue: value,
      selectedItemBuilder: (context) {
        return ShippingMethodType.values.map((type) {
          return _DropdownText(type.label);
        }).toList();
      },
      items: ShippingMethodType.values.map((type) {
        return DropdownMenuItem<ShippingMethodType>(
          value: type,
          child: _DropdownText(type.label),
        );
      }).toList(),
      onChanged: onChanged,
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
      isExpanded: true,
      initialValue: value,
      selectedItemBuilder: (context) {
        return ShippingBranchScope.values.map((scope) {
          return _DropdownText(scope.label);
        }).toList();
      },
      items: ShippingBranchScope.values.map((scope) {
        return DropdownMenuItem<ShippingBranchScope>(
          value: scope,
          child: _DropdownText(scope.label),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: _dropdownDecoration(context),
    );
  }
}

class _CountrySearchField extends StatelessWidget {
  final List<ShippingCountryModel> countries;
  final String? selectedCountryId;
  final ValueChanged<String?> onChanged;

  const _CountrySearchField({
    required this.countries,
    required this.selectedCountryId,
    required this.onChanged,
  });

  ShippingCountryModel? get _selectedCountry {
    if (selectedCountryId == null) return null;

    final matches = countries.where(
      (country) => country.id == selectedCountryId,
    );

    return matches.isEmpty ? null : matches.first;
  }

  Future<void> _openCountryPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<ShippingCountryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _CountryPickerSheet(
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
      value: _selectedCountry?.name,
      hintText: 'Search and select country',
      onTap: () => _openCountryPicker(context),
      validator: () {
        if (selectedCountryId == null || selectedCountryId!.trim().isEmpty) {
          return 'Country is required';
        }

        return null;
      },
    );
  }
}

class _RegionSearchField extends StatelessWidget {
  final List<ShippingRegionModel> regions;
  final String? selectedRegionId;
  final bool required;
  final ValueChanged<String?> onChanged;

  const _RegionSearchField({
    required this.regions,
    required this.selectedRegionId,
    required this.required,
    required this.onChanged,
  });

  ShippingRegionModel? get _selectedRegion {
    if (selectedRegionId == null) return null;

    final matches = regions.where(
      (region) => region.id == selectedRegionId,
    );

    return matches.isEmpty ? null : matches.first;
  }

  Future<void> _openRegionPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<ShippingRegionModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _RegionPickerSheet(
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
    return _SearchableSelectionField(
      value: _selectedRegion?.name,
      hintText: 'Search and select region',
      onTap: () => _openRegionPicker(context),
      validator: () {
        if (!required) return null;

        if (selectedRegionId == null || selectedRegionId!.trim().isEmpty) {
          return 'Region is required for Lebanon';
        }

        return null;
      },
    );
  }
}

class _SearchableSelectionField extends FormField<String> {
  _SearchableSelectionField({
    required String? value,
    required String hintText,
    required VoidCallback onTap,
    required String? Function() validator,
  }) : super(
          initialValue: value,
          validator: (_) => validator(),
          builder: (field) {
            final hasValue = value != null && value.trim().isNotEmpty;
            final hasError = field.hasError;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(6),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppThemeTokens.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      border: _fieldBorder(),
                      enabledBorder: _fieldBorder(),
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
                        const Icon(
                          Icons.search,
                          size: 20,
                          color: AppThemeTokens.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 24,
                          color: AppThemeTokens.textSecondary,
                        ),
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

class _CountryPickerSheet extends StatefulWidget {
  final List<ShippingCountryModel> countries;
  final String? selectedCountryId;

  const _CountryPickerSheet({
    required this.countries,
    required this.selectedCountryId,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  List<ShippingCountryModel> get _filteredCountries {
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
          title: country.name,
          subtitle: _countrySubtitle(country),
          selected: selected,
          onTap: () => Navigator.of(context).pop(country),
        );
      },
    );
  }

  String _countrySubtitle(ShippingCountryModel country) {
    final codes = [
      country.iso2Code.trim(),
      country.iso3Code.trim(),
    ].where((code) => code.isNotEmpty).join(' • ');

    return codes.isEmpty ? 'Country' : codes;
  }
}

class _RegionPickerSheet extends StatefulWidget {
  final List<ShippingRegionModel> regions;
  final String? selectedRegionId;

  const _RegionPickerSheet({
    required this.regions,
    required this.selectedRegionId,
  });

  @override
  State<_RegionPickerSheet> createState() => _RegionPickerSheetState();
}

class _RegionPickerSheetState extends State<_RegionPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  List<ShippingRegionModel> get _filteredRegions {
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

  String _regionSubtitle(ShippingRegionModel region) {
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