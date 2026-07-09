import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../injection_container.dart';
import '../../../shared/utils/supplier_success_message_localizer.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../data/repositories/supplier_payment_method_repository_impl.dart';
import '../../data/services/supplier_payment_method_api_service.dart';
import '../../domain/usecases/get_supplier_payment_methods_usecase.dart';
import '../../domain/usecases/save_supplier_payment_method_usecase.dart';
import '../../domain/usecases/test_supplier_payment_method_usecase.dart';
import '../bloc/supplier_payment_methods_bloc.dart';
import '../bloc/supplier_payment_methods_event.dart';
import '../bloc/supplier_payment_methods_state.dart';
import '../widgets/supplier_payment_method_card.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

class SupplierPaymentMethodsScreen extends StatelessWidget {
  const SupplierPaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = sl<ApiClient>(instanceName: 'projectApiClient');
    final apiService = SupplierPaymentMethodApiService(apiClient);
    final repository =
        SupplierPaymentMethodRepositoryImpl(apiService: apiService);

    return BlocProvider(
      create: (_) => SupplierPaymentMethodsBloc(
        getPaymentMethods: GetSupplierPaymentMethodsUsecase(repository),
        savePaymentMethod: SaveSupplierPaymentMethodUsecase(repository),
        testPaymentMethod: TestSupplierPaymentMethodUsecase(repository),
      )..add(const SupplierPaymentMethodsStarted()),
      child: const _SupplierPaymentMethodsView(),
    );
  }
}

class _SupplierPaymentMethodsView extends StatefulWidget {
  const _SupplierPaymentMethodsView();

  @override
  State<_SupplierPaymentMethodsView> createState() =>
      _SupplierPaymentMethodsViewState();
}

class _SupplierPaymentMethodsViewState
    extends State<_SupplierPaymentMethodsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final background = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final outline = theme.colorScheme.outline;

    return Scaffold(
      backgroundColor: background,
      drawer: const SupplierAppDrawer(),
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: primary, size: 30),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          l10n.paymentMethods,
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w900,
            fontSize: 21,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.refreshButton,
            onPressed: () => context
                .read<SupplierPaymentMethodsBloc>()
                .add(const SupplierPaymentMethodsRefreshed()),
            icon: Icon(Icons.refresh_rounded, color: primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<SupplierPaymentMethodsBloc,
          SupplierPaymentMethodsState>(
        listenWhen: (prev, cur) =>
            prev.errorMessage != cur.errorMessage ||
            prev.successMessage != cur.successMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppToast.error(context, localizeSupplierPaymentMessage(context, state.errorMessage!));
          }
          if (state.successMessage != null) {
            AppToast.success(context, localizeSupplierSuccessMessage(context, state.successMessage!));
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          final query = _searchQuery.trim().toLowerCase();
          final filteredMethods = state.methods.where((method) {
            if (query.isEmpty) return true;

            final searchableText = [
              method.code,
              method.displayName,
              method.helperText,
              method.projectEnabled ? 'enabled active' : 'disabled inactive',
              method.supportedNow ? 'supported' : 'coming soon unsupported',
              method.requiresCredentials ? 'credentials required' : 'no credentials',
            ].join(' ').toLowerCase();

            return searchableText.contains(query);
          }).toList();
          final hasSearchQuery = query.isNotEmpty;

          return RefreshIndicator(
            onRefresh: () async => context
                .read<SupplierPaymentMethodsBloc>()
                .add(const SupplierPaymentMethodsRefreshed()),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                // ── Header card ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withOpacity(0.18)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tune_rounded, color: primary, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.paymentMethodsHeaderTitle,
                              style: TextStyle(
                                color: onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.paymentMethodsHeaderSubtitle,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 14,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _PaymentMethodSearchField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 18),

                // ── Method cards ──
                if (state.methods.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: outline.withOpacity(0.3)),
                    ),
                    child: Text(
                      l10n.paymentMethodsEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else if (filteredMethods.isEmpty && hasSearchQuery)
                  _PaymentMethodsSearchEmptyCard(primary: primary)
                else
                  ...filteredMethods.map((method) {
                    final code = method.code.toUpperCase();
                    final isSaving = state.savingMethodCode == code;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SupplierPaymentMethodCard(
                        method: method,
                        isSaving: isSaving,
                        onChanged: (enabled) {
                          context
                              .read<SupplierPaymentMethodsBloc>()
                              .add(SupplierPaymentMethodToggled(
                                methodCode: method.code,
                                enabled: enabled,
                              ));
                        },
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentMethodSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PaymentMethodSearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search payment methods',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: controller.text.trim().isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.55)),
        ),
      ),
    );
  }
}

class _PaymentMethodsSearchEmptyCard extends StatelessWidget {
  final Color primary;

  const _PaymentMethodsSearchEmptyCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: primary, size: 34),
          const SizedBox(height: 10),
          Text(
            'No matching payment methods',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
