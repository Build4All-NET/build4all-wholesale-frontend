import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/location/data/models/country_model.dart';
import '../../../../../core/location/data/models/region_model.dart';
import '../../../../../core/location/data/services/location_api_service.dart';
import '../../../../../core/payments/hosted_checkout_flow.dart';
import '../../../../../core/payments/wholesale_stripe_payment_sheet.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../core/widgets/searchable_selection_field.dart';
import '../../../../../features/dashboard/presentation/widgets/retailer_product_image.dart';
import '../../../../../injection_container.dart';
import '../../data/models/retailer_checkout_model.dart';
import '../../data/models/retailer_split_checkout_model.dart';
import '../cubit/retailer_checkout_cubit.dart';
import '../cubit/retailer_checkout_state.dart';


class _CheckoutBlockingIssue {
  final String title;
  final String description;
  final String action;

  const _CheckoutBlockingIssue({
    required this.title,
    required this.description,
    required this.action,
  });
}

class RetailerCheckoutScreen extends StatelessWidget {
  const RetailerCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerCheckoutCubit>(),
      child: const _RetailerSplitCheckoutView(),
    );
  }
}

class _RetailerSplitCheckoutView extends StatefulWidget {
  const _RetailerSplitCheckoutView();

  @override
  State<_RetailerSplitCheckoutView> createState() =>
      _RetailerSplitCheckoutViewState();
}

class _RetailerSplitCheckoutViewState
    extends State<_RetailerSplitCheckoutView> {
  static const String _retailerDashboardRoute = '/retailer-dashboard';
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
  bool _isCheckoutIssueDialogOpen = false;
  int? _handledOnlinePaymentSessionId;

  @override
  void initState() {
    super.initState();
    _locationApiService = LocationApiService(
      sl(instanceName: 'projectApiClient'),
    );
    _loadCountries();
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

  Future<void> _previewSplitCheckout({
    bool resetShippingSelections = false,
  }) async {
    final country = _selectedCountry;
    if (country == null) {
      _formKey.currentState?.validate();
      return;
    }

    await context.read<RetailerCheckoutCubit>().previewSplitCheckout(
          deliveryCountryId: country.id,
          deliveryRegionId: _selectedRegion?.id,
          resetShippingSelections: resetShippingSelections,
        );
  }

  Future<void> _placeSplitCheckout(RetailerCheckoutState state) async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final blockingIssues = _collectCheckoutBlockingIssues(
      state,
      formValid: formValid,
    );

    if (blockingIssues.isNotEmpty) {
      await _showCheckoutIssuesDialog(blockingIssues);
      return;
    }

    final country = _selectedCountry;
    final paymentMethod = state.selectedPaymentMethod;

    if (country == null || paymentMethod == null || paymentMethod.trim().isEmpty) {
      await _showCheckoutIssuesDialog([
        const _CheckoutBlockingIssue(
          title: 'Checkout information is incomplete',
          description: 'Some required checkout information is missing.',
          action: 'Review the delivery details, shipping method and payment method, then try again.',
        ),
      ]);
      return;
    }

    await context.read<RetailerCheckoutCubit>().placeSplitCheckout(
          deliveryAddress: _addressController.text.trim(),
          deliveryCountryId: country.id,
          deliveryRegionId: _selectedRegion?.id,
          paymentMethod: paymentMethod,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
  }

  List<_CheckoutBlockingIssue> _collectCheckoutBlockingIssues(
    RetailerCheckoutState state, {
    required bool formValid,
  }) {
    final issues = <_CheckoutBlockingIssue>[];
    final preview = state.splitPreview;

    if (state.isLoadingSplitPreview) {
      issues.add(
        const _CheckoutBlockingIssue(
          title: 'Order preview is still updating',
          description: 'The checkout totals, shipping, tax and promotions are being recalculated.',
          action: 'Wait a few seconds until the preview finishes loading, then press Place Order again.',
        ),
      );
    }

    if (!formValid) {
      issues.add(
        const _CheckoutBlockingIssue(
          title: 'Delivery information is incomplete',
          description: 'A required delivery field is missing or invalid.',
          action: 'Fill the required delivery country and address fields. The address should be specific enough for delivery.',
        ),
      );
    }

    if (_selectedCountry == null) {
      issues.add(
        const _CheckoutBlockingIssue(
          title: 'Delivery country is required',
          description: 'The system cannot calculate shipping and tax without a delivery country.',
          action: 'Select the delivery country, then preview the order again.',
        ),
      );
    }

    if (preview == null) {
      issues.add(
        const _CheckoutBlockingIssue(
          title: 'Order preview is required',
          description: 'Checkout must calculate current prices, promotions, shipping and tax before creating the order.',
          action: 'Press Preview Order first. After the preview appears, choose shipping and payment, then place the order.',
        ),
      );
      return _deduplicateCheckoutIssues(issues);
    }

    if (preview.groups.isEmpty || preview.totalItems <= 0) {
      issues.add(
        const _CheckoutBlockingIssue(
          title: 'Cart is empty',
          description: 'There are no products available to checkout.',
          action: 'Return to the cart and add products before placing an order.',
        ),
      );
    }

    if (!preview.canCheckout &&
        preview.validationMessage != null &&
        preview.validationMessage!.trim().isNotEmpty) {
      issues.add(_checkoutIssueFromBackendMessage(preview.validationMessage!));
    }

    for (final group in preview.groups) {
      final branchName = group.branchName.trim().isEmpty
          ? 'branch #${group.branchId}'
          : group.branchName.trim();

      if (!group.canCheckout &&
          group.validationMessage != null &&
          group.validationMessage!.trim().isNotEmpty) {
        issues.add(_checkoutIssueFromBackendMessage(group.validationMessage!));
      }

      if (group.availableShippingMethods.isEmpty) {
        issues.add(
          _CheckoutBlockingIssue(
            title: 'No shipping method is available for $branchName',
            description: 'This branch has no active shipping method matching the selected country, region, branch and order amount.',
            action: 'Choose another country or region, adjust the cart amount, or ask the supplier to configure an active shipping method for this branch.',
          ),
        );
      } else if (group.selectedShippingMethod == null) {
        issues.add(
          _CheckoutBlockingIssue(
            title: 'Shipping method is required for $branchName',
            description: 'The order cannot be created until a valid shipping method is selected for every fulfillment branch.',
            action: 'Select one of the available shipping methods under $branchName, then press Place Order again.',
          ),
        );
      }
    }

    final enabledPaymentMethods = preview.paymentMethods
        .where((method) => method.enabled && !method.comingSoon)
        .toList();
    final paymentMethod = state.selectedPaymentMethod?.trim();

    if (enabledPaymentMethods.isEmpty) {
      issues.add(
        const _CheckoutBlockingIssue(
          title: 'No payment method is available',
          description: 'The supplier has not enabled an available payment method for checkout.',
          action: 'Ask the supplier to enable Cash, Stripe or Credit / Debit Card from payment settings, then preview the order again.',
        ),
      );
    } else if (paymentMethod == null || paymentMethod.isEmpty) {
      issues.add(
        const _CheckoutBlockingIssue(
          title: 'Payment method is required',
          description: 'Checkout needs a payment method before creating the order.',
          action: 'Select Cash, Stripe or Credit / Debit Card, then place the order.',
        ),
      );
    } else {
      final paymentStillAvailable = enabledPaymentMethods.any(
        (method) => method.methodName.toUpperCase() == paymentMethod.toUpperCase(),
      );

      if (!paymentStillAvailable) {
        issues.add(
          const _CheckoutBlockingIssue(
            title: 'Selected payment method is no longer available',
            description: 'The selected payment method was disabled or is no longer valid for this checkout.',
            action: 'Select another available payment method and try again.',
          ),
        );
      }
    }

    return _deduplicateCheckoutIssues(issues);
  }

  List<_CheckoutBlockingIssue> _deduplicateCheckoutIssues(
    List<_CheckoutBlockingIssue> issues,
  ) {
    final seen = <String>{};
    final unique = <_CheckoutBlockingIssue>[];

    for (final issue in issues) {
      final key = '${issue.title}|${issue.description}|${issue.action}';
      if (seen.add(key)) unique.add(issue);
    }

    return unique;
  }

  _CheckoutBlockingIssue _checkoutIssueFromBackendMessage(String message) {
    final cleaned = message.trim();
    final lower = cleaned.toLowerCase();

    if (lower.contains('cart is empty')) {
      return const _CheckoutBlockingIssue(
        title: 'Cart is empty',
        description: 'There are no products available to checkout.',
        action: 'Return to products, add items to the cart, then preview the order again.',
      );
    }

    if (lower.contains('no shipping method') ||
        lower.contains('shipping method is required') ||
        lower.contains('selected shipping method')) {
      return _CheckoutBlockingIssue(
        title: 'Shipping method problem',
        description: cleaned,
        action: 'Select a valid shipping method. If none appears, change the country/region or ask the supplier to activate a shipping method for this branch and order amount.',
      );
    }

    if (lower.contains('country')) {
      return _CheckoutBlockingIssue(
        title: 'Delivery country problem',
        description: cleaned,
        action: 'Select a valid active country, then preview the order again.',
      );
    }

    if (lower.contains('region')) {
      return _CheckoutBlockingIssue(
        title: 'Delivery region problem',
        description: cleaned,
        action: 'Select a region that belongs to the selected country, then preview the order again.',
      );
    }

    if (lower.contains('address')) {
      return _CheckoutBlockingIssue(
        title: 'Delivery address problem',
        description: cleaned,
        action: 'Enter a clear delivery address, then place the order again.',
      );
    }

    if (lower.contains('stock') ||
        lower.contains('fulfill') ||
        lower.contains('branch can') ||
        lower.contains('selected branch')) {
      return _CheckoutBlockingIssue(
        title: 'Stock or fulfillment problem',
        description: cleaned,
        action: 'Reduce the quantity, remove unavailable products, or ask the supplier to update branch inventory.',
      );
    }

    if (lower.contains('product')) {
      return _CheckoutBlockingIssue(
        title: 'Product availability problem',
        description: cleaned,
        action: 'Remove unavailable or inactive products from the cart, then preview checkout again.',
      );
    }

    if (lower.contains('payment') ||
        lower.contains('stripe') ||
        lower.contains('mpgs') ||
        lower.contains('card') ||
        lower.contains('paypal')) {
      return _CheckoutBlockingIssue(
        title: 'Payment problem',
        description: cleaned,
        action: 'Choose an enabled payment method. For online payment, make sure the supplier payment credentials are configured correctly.',
      );
    }

    if (lower.contains('tax')) {
      return _CheckoutBlockingIssue(
        title: 'Tax calculation problem',
        description: cleaned,
        action: 'Preview the order again. If the problem remains, check that the supplier tax configuration matches the selected country and region.',
      );
    }

    if (lower.contains('promotion') || lower.contains('discount')) {
      return _CheckoutBlockingIssue(
        title: 'Promotion calculation problem',
        description: cleaned,
        action: 'Preview the order again so current product prices and promotions are recalculated.',
      );
    }

    if (lower.contains('server') || lower.contains('connection') || lower.contains('timeout')) {
      return _CheckoutBlockingIssue(
        title: 'Server connection problem',
        description: cleaned,
        action: 'Check the internet connection and server address, then try again.',
      );
    }

    return _CheckoutBlockingIssue(
      title: 'Checkout could not be completed',
      description: cleaned.isEmpty
          ? 'The order could not be created because checkout validation failed.'
          : cleaned,
      action: 'Review delivery details, shipping, payment, cart items and preview totals, then try again.',
    );
  }

  Future<void> _showCheckoutIssuesDialog(
    List<_CheckoutBlockingIssue> issues,
  ) async {
    if (!mounted || issues.isEmpty || _isCheckoutIssueDialogOpen) return;

    _isCheckoutIssueDialogOpen = true;

    try {
      await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final primary = Theme.of(dialogContext).colorScheme.primary;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
          contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Complete checkout requirements',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Place Order is blocked for your protection. Please fix the following item(s):',
                  style: TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                ...issues.asMap().entries.map((entry) {
                  final issue = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppThemeTokens.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppThemeTokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}. ${issue.title}',
                          style: const TextStyle(
                            color: AppThemeTokens.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          issue.description,
                          style: const TextStyle(
                            color: AppThemeTokens.textSecondary,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'What to do: ${issue.action}',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
      );
    } finally {
      _isCheckoutIssueDialogOpen = false;
    }
  }

  Future<void> _selectSplitShippingMethod({
    required int branchId,
    required int? shippingMethodId,
  }) async {
    final country = _selectedCountry;
    if (country == null) return;

    await context.read<RetailerCheckoutCubit>().selectSplitShippingMethod(
          branchId: branchId,
          shippingMethodId: shippingMethodId,
          deliveryCountryId: country.id,
          deliveryRegionId: _selectedRegion?.id,
        );
  }

  void _handleDeliveryCountrySelected(CountryModel country) {
    setState(() {
      _selectedCountry = country;
      _selectedRegion = null;
    });

    _loadRegionsForCountry(country);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshSplitPreviewAfterDeliveryChange();
    });
  }

  void _handleDeliveryRegionSelected(RegionModel region) {
    setState(() => _selectedRegion = region);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshSplitPreviewAfterDeliveryChange();
    });
  }

  Future<void> _refreshSplitPreviewAfterDeliveryChange() async {
    final checkoutCubit = context.read<RetailerCheckoutCubit>();
    final hadPreview = checkoutCubit.state.splitPreview != null;

    checkoutCubit.resetSplitDeliverySelections();

    if (!hadPreview) return;

    final country = _selectedCountry;
    if (country == null) return;

    await checkoutCubit.previewSplitCheckout(
      deliveryCountryId: country.id,
      deliveryRegionId: _selectedRegion?.id,
      resetShippingSelections: true,
    );
  }

  void _navigateToOrdersAfterSuccess() {
    if (_navigatedAfterSuccess) return;
    _navigatedAfterSuccess = true;

    Future.microtask(() {
      if (!mounted) return;

      final router = GoRouter.of(context);
      router.go(_retailerDashboardRoute);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.push(_retailerOrdersRoute);
      });
    });
  }

  Future<void> _handleOnlinePaymentIfNeeded(
    RetailerCheckoutState state,
  ) async {
    final payment = state.paymentResult;
    final sessionId = state.splitCheckoutResult?.sessionId ?? payment?.orderId;

    if (payment == null || sessionId == null) return;
    if (!payment.onlinePaymentActionRequired) return;
    if (_handledOnlinePaymentSessionId == sessionId) return;

    final method = payment.paymentMethod.toUpperCase();
    if (method != 'STRIPE' && method != 'MPGS') return;

    _handledOnlinePaymentSessionId = sessionId;

    if (method == 'STRIPE') {
      await _runStripePayment(sessionId, payment);
      return;
    }

    await _runMpgsPayment(sessionId, payment);
  }

  Future<void> _runStripePayment(
    int sessionId,
    RetailerCheckoutPaymentStartModel payment,
  ) async {
    final result = await WholesaleStripePaymentSheet.present(
      publishableKey: payment.publishableKey ?? '',
      clientSecret: payment.clientSecret ?? '',
      merchantDisplayName: AppConfig.appName,
    );

    if (!mounted) return;

    if (result.cancelled) {
      AppToast.info(
        context,
        result.message ?? 'Payment was cancelled. Your cart is still available.',
      );
      return;
    }

    if (!result.completed) {
      AppToast.error(context, result.message ?? 'Stripe payment failed.');
      return;
    }

    await context.read<RetailerCheckoutCubit>().confirmSplitStripePayment(
          sessionId: sessionId,
        );
  }

  Future<void> _runMpgsPayment(
    int sessionId,
    RetailerCheckoutPaymentStartModel payment,
  ) async {
    final redirectUrl = payment.redirectUrl;

    if (redirectUrl == null || redirectUrl.trim().isEmpty) {
      AppToast.error(context, context.l10n.cardCheckoutUrlMissing);
      return;
    }

    final completed = await HostedCheckoutFlow.openAndAskForCompletion(
      context: context,
      redirectUrl: redirectUrl,
      title: context.l10n.completeCardPayment,
      message: context.l10n.hostedCheckoutMessage,
      paidButtonLabel: context.l10n.ivePaid,
      cancelButtonLabel: context.l10n.cancel,
    );

    if (!mounted) return;

    if (!completed) {
      AppToast.info(
        context,
        'Payment was cancelled. Your cart is still available.',
      );
      return;
    }

    await context.read<RetailerCheckoutCubit>().confirmSplitMpgsPayment(
          sessionId: sessionId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<RetailerCheckoutCubit, RetailerCheckoutState>(
      listener: (context, state) {
        _handleOnlinePaymentIfNeeded(state);

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          final issue = _checkoutIssueFromBackendMessage(state.errorMessage!);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showCheckoutIssuesDialog([issue]);
          });
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
          bottomNavigationBar: _SplitCheckoutBottomBar(
            state: state,
            onPlaceOrder: () => _placeSplitCheckout(state),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                // Dragging the form closes the keyboard so the (bottom) Place
                // Order button is reachable again after typing the address.
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                    countries: _countries,
                    regions: _regions,
                    selectedCountry: _selectedCountry,
                    selectedRegion: _selectedRegion,
                    isLoadingCountries: _isLoadingCountries,
                    isLoadingRegions: _isLoadingRegions,
                    onCountrySelected: _handleDeliveryCountrySelected,
                    onRegionSelected: _handleDeliveryRegionSelected,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: state.isLoadingSplitPreview
                        ? null
                        : () => _previewSplitCheckout(),
                    icon: state.isLoadingSplitPreview
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
                      state.isLoadingSplitPreview
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
                  if (state.splitPreview != null) ...[
                    _SplitFulfillmentGroupsCard(
                      preview: state.splitPreview!,
                      onShippingSelected: _selectSplitShippingMethod,
                    ),
                    const SizedBox(height: 14),
                    _PaymentMethodsCard(
                      methods: state.splitPreview!.paymentMethods,
                      selectedPaymentMethod: state.selectedPaymentMethod,
                      onSelected: (methodName) {
                        context
                            .read<RetailerCheckoutCubit>()
                            .selectPaymentMethod(methodName);
                      },
                    ),
                    const SizedBox(height: 14),
                    _SplitCheckoutSummaryCard(preview: state.splitPreview!),
                    if (state.splitCheckoutResult != null) ...[
                      const SizedBox(height: 14),
                      _SplitCheckoutResultCard(result: state.splitCheckoutResult!),
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
            enabled: selectedCountry != null &&
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
              if (value.trim().length < 5) return l10n.addressSpecificError;
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

class _SplitFulfillmentGroupsCard extends StatelessWidget {
  final RetailerSplitCheckoutPreviewModel preview;
  final Future<void> Function({required int branchId, required int? shippingMethodId})
      onShippingSelected;

  const _SplitFulfillmentGroupsCard({
    required this.preview,
    required this.onShippingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.account_tree_outlined,
            title: context.l10n.checkoutFulfillmentBranch,
          ),
          const SizedBox(height: 12),
          ...preview.groups.asMap().entries.map(
                (entry) => _SplitFulfillmentGroupTile(
                  index: entry.key,
                  group: entry.value,
                  currency: preview.currency,
                  onShippingSelected: onShippingSelected,
                ),
              ),
        ],
      ),
    );
  }
}

class _SplitFulfillmentGroupTile extends StatelessWidget {
  final int index;
  final RetailerSplitCheckoutGroupModel group;
  final String currency;
  final Future<void> Function({required int branchId, required int? shippingMethodId})
      onShippingSelected;

  const _SplitFulfillmentGroupTile({
    required this.index,
    required this.group,
    required this.currency,
    required this.onShippingSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: primary.withValues(alpha: 0.12),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: primary, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.branchName,
                      style: const TextStyle(
                        color: AppThemeTokens.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    if (group.displayBranchLabel != group.branchName)
                      Text(
                        group.displayBranchLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeTokens.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                _money(currency, group.finalTotal),
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...group.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CheckoutItemTile(item: item),
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 22),
          Text(
            l10n.checkoutShippingMethod,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          if (group.availableShippingMethods.isEmpty)
            Text(
              l10n.checkoutNoShippingMethods,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...group.availableShippingMethods.map(
              (method) => _SelectableTile(
                title: method.methodName,
                subtitle: _shippingSubtitle(context, currency, method),
                trailing: _shippingTrailing(context, currency, method),
                subtitleMaxLines: null,
                selected: group.selectedShippingMethod?.id == method.id,
                onTap: () => onShippingSelected(
                  branchId: group.branchId,
                  shippingMethodId: method.id,
                ),
              ),
            ),
          const Divider(height: 22),
          _SummaryRow(
            label: l10n.subtotal,
            value: _money(currency, group.itemsSubtotal),
          ),
          if (group.promotionDiscount > 0)
            _SummaryRow(
              label: l10n.checkoutPromotionDiscount,
              value: '- ${_money(currency, group.promotionDiscount)}',
            ),
          _SummaryRow(
            label: l10n.shipping,
            value: _money(currency, group.shippingCost),
          ),
          _SummaryRow(
            label: l10n.checkoutTax,
            value: _money(currency, group.taxAmount),
          ),
          _SummaryRow(
            label: l10n.total,
            value: _money(currency, group.finalTotal),
            isTotal: true,
            color: primary,
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
          width: 52,
          height: 52,
          borderRadius: 12,
          iconSize: 24,
        ),
        const SizedBox(width: 10),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${l10n.quantityLabel}: ${item.quantity}',
                style: const TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (item.hasActivePromotion) ...[
                const SizedBox(height: 3),
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
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (item.shouldShowOriginalPrice)
              Text(
                _money(item.currency, item.originalLineTotal),
                style: const TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(
              _money(item.currency, item.lineTotal),
              style: TextStyle(
                color: primary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
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
          _SectionTitle(icon: Icons.payments_outlined, title: l10n.paymentMethods),
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

class _SplitCheckoutSummaryCard extends StatelessWidget {
  final RetailerSplitCheckoutPreviewModel preview;

  const _SplitCheckoutSummaryCard({required this.preview});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = preview.currency;
    final primary = Theme.of(context).colorScheme.primary;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.summarize_outlined, title: l10n.orderSummary),
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

class _SplitCheckoutResultCard extends StatelessWidget {
  final RetailerSplitCheckoutPlaceModel result;

  const _SplitCheckoutResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final currency = r'$';
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.check_circle_outline_rounded,
            title: context.l10n.checkoutOrderCreated,
          ),
          const SizedBox(height: 12),
          Text(
            result.sessionNumber,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...result.orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${order.branchName} • ${order.orderNumber}',
                      style: const TextStyle(
                        color: AppThemeTokens.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    _money(currency, order.orderTotal),
                    style: const TextStyle(
                      color: AppThemeTokens.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
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
          OutlinedButton(onPressed: onBackToCart, child: Text(l10n.shoppingCart)),
        ],
      ),
    );
  }
}

class _SplitCheckoutBottomBar extends StatelessWidget {
  final RetailerCheckoutState state;
  final VoidCallback onPlaceOrder;

  const _SplitCheckoutBottomBar({
    required this.state,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = state.splitPreview;
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
              onPressed: state.isPlacingOrder ? null : onPlaceOrder,
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
  final int? subtitleMaxLines;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.selected,
    this.enabled = true,
    this.subtitleMaxLines = 2,
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
                        maxLines: subtitleMaxLines,
                        overflow: subtitleMaxLines == null
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeTokens.textSecondary,
                          fontSize: 12,
                          height: 1.35,
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
      padding: EdgeInsets.only(bottom: isTotal ? 0 : 10),
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
                fontSize: isTotal ? 16 : 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: isTotal ? 17 : 13,
            ),
          ),
        ],
      ),
    );
  }
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

  final locationParts = <String>[];
  final countryName = method.countryName?.trim();
  final regionName = method.regionName?.trim();
  if (countryName != null && countryName.isNotEmpty) {
    locationParts.add(countryName);
  }
  if (regionName != null && regionName.isNotEmpty) {
    locationParts.add(regionName);
  }
  if (locationParts.isNotEmpty) {
    parts.add(locationParts.join(' / '));
  }

  if (method.appliesToAllBranches) {
    parts.add(l10n.supplierAllBranches);
  }

  final estimatedDeliveryTime = method.estimatedDeliveryTime?.trim();
  if (estimatedDeliveryTime != null && estimatedDeliveryTime.isNotEmpty) {
    parts.add(estimatedDeliveryTime);
  }

  if (method.freeShippingApplied && method.shippingCost > 0) {
    parts.add(
      '${l10n.shipping}: ${_money(currency, method.shippingCost)} → ${l10n.supplierFreeShipping}',
    );
  } else if (method.appliedShippingCost == 0) {
    parts.add('${l10n.shipping}: ${l10n.supplierFreeShipping}');
  } else {
    parts.add('${l10n.shipping}: ${_money(currency, method.appliedShippingCost)}');
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

  final notes = method.notes?.trim();
  if (notes != null && notes.isNotEmpty) {
    parts.add('${l10n.checkoutNotes}: $notes');
  }

  if (parts.isEmpty) return l10n.shipping;
  return parts.join('\n');
}

String _shippingTrailing(
  BuildContext context,
  String currency,
  RetailerCheckoutShippingMethodModel method,
) {
  final l10n = context.l10n;

  if (method.freeShippingApplied || method.appliedShippingCost == 0) {
    return l10n.supplierFreeShipping;
  }

  return _money(currency, method.appliedShippingCost);
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

String _money(String currency, double amount) {
  return '$currency${amount.toStringAsFixed(2)}';
}
