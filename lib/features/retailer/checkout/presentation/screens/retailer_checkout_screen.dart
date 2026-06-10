import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/location/data/models/country_model.dart';
import '../../../../../core/location/data/models/region_model.dart';
import '../../../../../core/location/data/services/location_api_service.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../core/widgets/searchable_selection_field.dart';
import '../../../../../features/dashboard/presentation/widgets/retailer_product_image.dart';
import '../../../../../injection_container.dart';
import '../../data/models/retailer_checkout_model.dart';
import '../cubit/retailer_checkout_cubit.dart';
import '../cubit/retailer_checkout_state.dart';

class RetailerCheckoutScreen extends StatelessWidget {
  const RetailerCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerCheckoutCubit>(),
      child: const _RetailerCheckoutView(),
    );
  }
}

class _RetailerCheckoutView extends StatefulWidget {
  const _RetailerCheckoutView();

  @override
  State<_RetailerCheckoutView> createState() => _RetailerCheckoutViewState();
}

class _RetailerCheckoutViewState extends State<_RetailerCheckoutView> {
  static const String _retailerOrdersRoute = '/retailer-orders';

  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  late final LocationApiService _locationApiService;

  List<CountryModel> _countries = [];
  List<RegionModel> _regions = [];

  CountryModel? _selectedCountry;
  RegionModel? _selectedRegion;

  bool _isLoadingCountries = false;
  bool _isLoadingRegions = false;
  bool _navigatedAfterSuccess = false;

  @override
  void initState() {
    super.initState();

    _locationApiService = LocationApiService(
      sl(instanceName: 'projectApiClient'),
    );

    _loadCountries();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RetailerCheckoutCubit>().loadEligibleBranches();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() => _isLoadingCountries = true);

    try {
      final countries = await _locationApiService.getCountries();

      if (!mounted) return;

      setState(() {
        _countries = countries;
        _isLoadingCountries = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoadingCountries = false);
      AppToast.error(context, context.l10n.couldNotLoadCountries);
    }
  }

  Future<void> _loadRegionsForCountry(CountryModel country) async {
    setState(() {
      _isLoadingRegions = true;
      _regions = [];
      _selectedRegion = null;
    });

    try {
      final regions = await _locationApiService.getRegionsByCountry(country.id);

      if (!mounted) return;

      setState(() {
        _regions = regions;
        _isLoadingRegions = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoadingRegions = false);
      AppToast.error(context, context.l10n.supplierCouldNotLoadTaxRules);
    }
  }

  Future<void> _preview({int? shippingMethodId}) async {
    if (!_formKey.currentState!.validate()) return;

    final branchId = context
        .read<RetailerCheckoutCubit>()
        .state
        .selectedBranch
        ?.id;
    final country = _selectedCountry;

    if (branchId == null) {
      AppToast.info(context, context.l10n.checkoutBranchRequired);
      return;
    }

    if (country == null) return;

    await context.read<RetailerCheckoutCubit>().previewCheckout(
      branchId: branchId,
      countryId: country.id,
      regionId: _selectedRegion?.id,
      selectedShippingMethodId: shippingMethodId,
    );
  }

  Future<void> _placeOrder(RetailerCheckoutState state) async {
    if (!_formKey.currentState!.validate()) return;

    final branchId = state.selectedBranch?.id;
    final country = _selectedCountry;
    final paymentMethod = state.selectedPaymentMethod;

    if (branchId == null) {
      AppToast.info(context, context.l10n.checkoutBranchRequired);
      return;
    }

    if (country == null) return;

    if (state.preview == null) {
      AppToast.info(context, context.l10n.checkoutPreviewRequired);
      return;
    }

    if (paymentMethod == null || paymentMethod.trim().isEmpty) {
      AppToast.info(context, context.l10n.checkoutSelectPaymentMethod);
      return;
    }

    await context.read<RetailerCheckoutCubit>().placeOrder(
      branchId: branchId,
      deliveryAddress: _addressController.text.trim(),
      deliveryCountryId: country.id,
      deliveryRegionId: _selectedRegion?.id,
      shippingMethodId: state.selectedShippingMethodId,
      paymentMethod: paymentMethod,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  void _navigateToOrdersAfterSuccess() {
    if (_navigatedAfterSuccess) return;

    _navigatedAfterSuccess = true;

    Future.microtask(() {
      if (!mounted) return;

      context.pushReplacement(_retailerOrdersRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<RetailerCheckoutCubit, RetailerCheckoutState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          AppToast.error(context, state.errorMessage!);
          context.read<RetailerCheckoutCubit>().clearMessages();
        }

        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          AppToast.success(context, state.successMessage!);
          context.read<RetailerCheckoutCubit>().clearMessages();
          _navigateToOrdersAfterSuccess();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            title: Text(
              l10n.checkoutTitle,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          bottomNavigationBar: _CheckoutBottomBar(
            state: state,
            onPlaceOrder: () => _placeOrder(state),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppThemeTokens.screenHorizontalPadding,
                  12,
                  AppThemeTokens.screenHorizontalPadding,
                  120,
                ),
                children: [
                  _DeliveryDetailsCard(
                    addressController: _addressController,
                    notesController: _notesController,
                    eligibleBranches: state.eligibleBranches,
                    selectedBranch: state.selectedBranch,
                    isLoadingBranches: state.isLoadingBranches,
                    onBranchSelected: (branch) {
                      context.read<RetailerCheckoutCubit>().selectBranch(
                        branch,
                      );
                    },
                    countries: _countries,
                    regions: _regions,
                    selectedCountry: _selectedCountry,
                    selectedRegion: _selectedRegion,
                    isLoadingCountries: _isLoadingCountries,
                    isLoadingRegions: _isLoadingRegions,
                    onCountrySelected: (country) {
                      setState(() {
                        _selectedCountry = country;
                        _selectedRegion = null;
                      });
                      _loadRegionsForCountry(country);
                    },
                    onRegionSelected: (region) {
                      setState(() => _selectedRegion = region);
                    },
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: state.isLoadingPreview || state.isLoadingBranches
                        ? null
                        : () => _preview(),
                    icon: state.isLoadingPreview
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.receipt_long_rounded),
                    label: Text(
                      state.isLoadingPreview
                          ? l10n.checkoutLoadingPreview
                          : l10n.checkoutPreviewOrder,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (state.preview != null) ...[
                    _CheckoutItemsCard(preview: state.preview!),
                    const SizedBox(height: 14),
                    _ShippingMethodsCard(
                      preview: state.preview!,
                      selectedShippingMethodId: state.selectedShippingMethodId,
                      onSelected: (method) {
                        final branchId = context
                            .read<RetailerCheckoutCubit>()
                            .state
                            .selectedBranch
                            ?.id;
                        final country = _selectedCountry;

                        if (branchId == null || country == null) return;

                        context
                            .read<RetailerCheckoutCubit>()
                            .selectShippingMethod(
                              branchId: branchId,
                              countryId: country.id,
                              regionId: _selectedRegion?.id,
                              shippingMethodId: method.id,
                            );
                      },
                    ),
                    const SizedBox(height: 14),
                    _PaymentMethodsCard(
                      methods: state.preview!.paymentMethods,
                      selectedPaymentMethod: state.selectedPaymentMethod,
                      onSelected: (methodName) {
                        context
                            .read<RetailerCheckoutCubit>()
                            .selectPaymentMethod(methodName);
                      },
                    ),
                    const SizedBox(height: 14),
                    _CheckoutSummaryCard(preview: state.preview!),
                    if (state.paymentResult != null) ...[
                      const SizedBox(height: 14),
                      _PaymentResultCard(payment: state.paymentResult!),
                    ],
                  ] else
                    _PreviewPlaceholderCard(onBackToCart: () => context.pop()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DeliveryDetailsCard extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController notesController;

  final List<RetailerEligibleCheckoutBranchModel> eligibleBranches;
  final RetailerEligibleCheckoutBranchModel? selectedBranch;
  final bool isLoadingBranches;
  final ValueChanged<RetailerEligibleCheckoutBranchModel> onBranchSelected;

  final List<CountryModel> countries;
  final List<RegionModel> regions;
  final CountryModel? selectedCountry;
  final RegionModel? selectedRegion;
  final bool isLoadingCountries;
  final bool isLoadingRegions;
  final ValueChanged<CountryModel> onCountrySelected;
  final ValueChanged<RegionModel> onRegionSelected;

  const _DeliveryDetailsCard({
    required this.addressController,
    required this.notesController,
    required this.eligibleBranches,
    required this.selectedBranch,
    required this.isLoadingBranches,
    required this.onBranchSelected,
    required this.countries,
    required this.regions,
    required this.selectedCountry,
    required this.selectedRegion,
    required this.isLoadingCountries,
    required this.isLoadingRegions,
    required this.onCountrySelected,
    required this.onRegionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.local_shipping_outlined,
            title: l10n.deliveryInformationTitle,
          ),
          const SizedBox(height: 16),
          SearchableSelectionField<RetailerEligibleCheckoutBranchModel>(
            label: l10n.checkoutFulfillmentBranch,
            hintText: l10n.checkoutSelectBranch,
            searchHintText: l10n.checkoutSearchBranch,
            items: eligibleBranches,
            itemLabel: (branch) => branch.displayLabel,
            value: selectedBranch,
            isLoading: isLoadingBranches,
            enabled: !isLoadingBranches && eligibleBranches.isNotEmpty,
            emptyText: l10n.checkoutNoEligibleBranches,
            onSelected: onBranchSelected,
            validator: (value) {
              if (value == null) return l10n.checkoutBranchRequired;
              return null;
            },
          ),
          const SizedBox(height: 14),
          SearchableSelectionField<CountryModel>(
            label: l10n.countryRequiredLabel,
            hintText: l10n.selectCountryHint,
            searchHintText: l10n.searchCountryHint,
            items: countries,
            itemLabel: (country) => country.name,
            value: selectedCountry,
            isLoading: isLoadingCountries,
            enabled: !isLoadingCountries && countries.isNotEmpty,
            emptyText: l10n.noCountriesFound,
            onSelected: onCountrySelected,
            validator: (value) {
              if (value == null) return l10n.countryRequiredError;
              return null;
            },
          ),
          const SizedBox(height: 14),
          SearchableSelectionField<RegionModel>(
            label: l10n.regionStateLabel,
            hintText: selectedCountry == null
                ? l10n.selectCountryFirst
                : l10n.selectRegionState,
            searchHintText: l10n.searchRegionHint,
            items: regions,
            itemLabel: (region) => region.name,
            value: selectedRegion,
            isLoading: isLoadingRegions,
            enabled:
                selectedCountry != null &&
                !isLoadingRegions &&
                regions.isNotEmpty,
            emptyText: l10n.noRegionsFound,
            onSelected: onRegionSelected,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: addressController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.deliveryAddressLabel,
              hintText: l10n.rfqDeliveryAddressHint,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.rfqDeliveryAddressRequired;
              }
              if (value.trim().length < 5) {
                return l10n.addressSpecificError;
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: notesController,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.checkoutNotes,
              hintText: l10n.checkoutNotesHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutItemsCard extends StatelessWidget {
  final RetailerCheckoutPreviewModel preview;

  const _CheckoutItemsCard({required this.preview});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.shopping_bag_outlined,
            title: context.l10n.checkoutItems,
          ),
          const SizedBox(height: 14),
          ...preview.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CheckoutItemTile(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  final RetailerCheckoutItemModel item;

  const _CheckoutItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RetailerProductImage(
          imageUrl: item.imageUrl,
          width: 64,
          height: 64,
          borderRadius: 14,
          iconSize: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.quantityLabel}: ${item.quantity}',
                style: const TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (item.hasActivePromotion) ...[
                const SizedBox(height: 4),
                Text(
                  item.promotionLabel ?? l10n.promotions,
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (item.shouldShowOriginalPrice)
              Text(
                _money(item.currency, item.originalLineTotal),
                style: const TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(
              _money(item.currency, item.lineTotal),
              style: TextStyle(
                color: primary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShippingMethodsCard extends StatelessWidget {
  final RetailerCheckoutPreviewModel preview;
  final int? selectedShippingMethodId;
  final ValueChanged<RetailerCheckoutShippingMethodModel> onSelected;

  const _ShippingMethodsCard({
    required this.preview,
    required this.selectedShippingMethodId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.delivery_dining_rounded,
            title: l10n.checkoutShippingMethod,
          ),
          const SizedBox(height: 12),
          if (preview.availableShippingMethods.isEmpty)
            Text(
              l10n.checkoutNoShippingMethods,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...preview.availableShippingMethods.map(
              (method) => _SelectableTile(
                title: method.methodName,
                subtitle: _shippingSubtitle(context, preview.currency, method),
                trailing:
                    method.freeShippingApplied ||
                        method.appliedShippingCost == 0
                    ? l10n.supplierFreeShipping
                    : _money(preview.currency, method.appliedShippingCost),
                selected: selectedShippingMethodId == method.id,
                onTap: () => onSelected(method),
              ),
            ),
        ],
      ),
    );
  }

  String _shippingSubtitle(
    BuildContext context,
    String currency,
    RetailerCheckoutShippingMethodModel method,
  ) {
    final l10n = context.l10n;
    final parts = <String>[];

    if (method.methodType.isNotEmpty) {
      parts.add(_shippingTypeLabel(context, method.methodType));
    }

    if (method.estimatedDeliveryTime != null &&
        method.estimatedDeliveryTime!.trim().isNotEmpty) {
      parts.add(method.estimatedDeliveryTime!.trim());
    }

    if (method.minimumOrderAmount > 0) {
      parts.add(
        '${l10n.checkoutMinimumOrder}: ${_money(currency, method.minimumOrderAmount)}',
      );
    }

    if (method.freeShippingThreshold > 0) {
      parts.add(
        '${l10n.supplierFreeShippingThresholdPlain}: ${_money(currency, method.freeShippingThreshold)}',
      );
    }

    if (parts.isEmpty) return l10n.shipping;
    return parts.join(' • ');
  }

  String _shippingTypeLabel(BuildContext context, String type) {
    final l10n = context.l10n;

    switch (type.toUpperCase()) {
      case 'STANDARD_DELIVERY':
        return l10n.supplierStandardDelivery;
      case 'EXPRESS_DELIVERY':
        return l10n.supplierExpressDelivery;
      case 'PICKUP':
      case 'PICKUP_FROM_BRANCH':
        return l10n.supplierPickupFromBranch;
      default:
        return type;
    }
  }
}

class _PaymentMethodsCard extends StatelessWidget {
  final List<RetailerCheckoutPaymentMethodModel> methods;
  final String? selectedPaymentMethod;
  final ValueChanged<String> onSelected;

  const _PaymentMethodsCard({
    required this.methods,
    required this.selectedPaymentMethod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sorted = [...methods]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.payments_outlined,
            title: l10n.paymentMethods,
          ),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            Text(
              l10n.paymentMethodsEmpty,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...sorted.map(
              (method) => _SelectableTile(
                title: _paymentLabel(context, method),
                subtitle: method.comingSoon
                    ? l10n.paymentMethodComingSoon
                    : method.description,
                trailing: method.enabled
                    ? l10n.paymentMethodEnabled
                    : l10n.paymentMethodDisabled,
                selected: selectedPaymentMethod == method.methodName,
                enabled: method.enabled && !method.comingSoon,
                onTap: () => onSelected(method.methodName),
              ),
            ),
        ],
      ),
    );
  }

  String _paymentLabel(
    BuildContext context,
    RetailerCheckoutPaymentMethodModel method,
  ) {
    final l10n = context.l10n;

    switch (method.methodName.toUpperCase()) {
      case 'CASH':
        return l10n.paymentCashOnDelivery;
      case 'STRIPE':
        return 'Stripe';
      case 'MPGS':
        return l10n.paymentMethodCreditDebitCardTitle;
      case 'PAYPAL':
        return 'PayPal';
      default:
        return method.displayName;
    }
  }
}

class _CheckoutSummaryCard extends StatelessWidget {
  final RetailerCheckoutPreviewModel preview;

  const _CheckoutSummaryCard({required this.preview});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = preview.currency;
    final primary = Theme.of(context).colorScheme.primary;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.summarize_outlined,
            title: l10n.orderSummary,
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: l10n.subtotal,
            value: _money(currency, preview.itemsSubtotal),
          ),
          _SummaryRow(
            label: l10n.checkoutPromotionDiscount,
            value: '- ${_money(currency, preview.promotionDiscount)}',
          ),
          _SummaryRow(
            label: l10n.shipping,
            value: _money(currency, preview.shippingCost),
          ),
          _SummaryRow(
            label: l10n.checkoutTax,
            value: _money(currency, preview.taxAmount),
          ),
          const Divider(height: 26),
          _SummaryRow(
            label: l10n.total,
            value: _money(currency, preview.finalTotal),
            isTotal: true,
            color: primary,
          ),
        ],
      ),
    );
  }
}

class _PaymentResultCard extends StatelessWidget {
  final RetailerCheckoutPaymentStartModel payment;

  const _PaymentResultCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final method = payment.paymentMethod.toUpperCase();

    String message;
    if (method == 'CASH') {
      message = l10n.checkoutCashPendingMessage;
    } else if (method == 'STRIPE') {
      message = l10n.checkoutStripeReadyMessage;
    } else if (method == 'MPGS') {
      message = payment.redirectUrl == null || payment.redirectUrl!.isEmpty
          ? l10n.checkoutMpgsReadyMessage
          : '${l10n.checkoutMpgsReadyMessage}\n${payment.redirectUrl}';
    } else {
      message = l10n.checkoutPaymentPreparedMessage;
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.check_circle_outline_rounded,
            title: l10n.checkoutOrderCreated,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPlaceholderCard extends StatelessWidget {
  final VoidCallback onBackToCart;

  const _PreviewPlaceholderCard({required this.onBackToCart});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _Card(
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.checkoutPreviewPlaceholderTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.checkoutPreviewPlaceholderMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onBackToCart,
            child: Text(l10n.shoppingCart),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final RetailerCheckoutState state;
  final VoidCallback onPlaceOrder;

  const _CheckoutBottomBar({required this.state, required this.onPlaceOrder});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = state.preview;
    final currency = preview?.currency ?? r'$';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: const BoxDecoration(
        color: AppThemeTokens.surface,
        border: Border(top: BorderSide(color: AppThemeTokens.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: preview == null
                  ? Text(
                      l10n.checkoutPreviewRequired,
                      style: const TextStyle(
                        color: AppThemeTokens.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.total,
                          style: const TextStyle(
                            color: AppThemeTokens.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _money(currency, preview.finalTotal),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 14),
            ElevatedButton(
              onPressed: preview == null || state.isPlacingOrder
                  ? null
                  : onPlaceOrder,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 52),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: state.isPlacingOrder
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.checkoutPlaceOrder,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: 0.08)
                : AppThemeTokens.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? primary : AppThemeTokens.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? primary : AppThemeTokens.textSecondary,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Opacity(
                  opacity: enabled ? 1 : 0.55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeTokens.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeTokens.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trailing,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: selected ? primary : AppThemeTokens.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        border: Border.all(color: AppThemeTokens.border),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(icon, color: primary, size: 22),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTotal ? 0 : 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isTotal
                    ? AppThemeTokens.textPrimary
                    : AppThemeTokens.textSecondary,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
                fontSize: isTotal ? 17 : 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

String _money(String currency, double amount) {
  return '$currency${amount.toStringAsFixed(2)}';
}
