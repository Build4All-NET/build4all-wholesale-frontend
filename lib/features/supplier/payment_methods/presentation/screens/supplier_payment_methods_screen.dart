import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../data/repositories/supplier_payment_method_repository_impl.dart';
import '../../data/services/supplier_payment_method_api_service.dart';
import '../../domain/usecases/get_supplier_payment_methods_usecase.dart';
import '../../domain/usecases/save_supplier_payment_method_usecase.dart';
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
    final repository = SupplierPaymentMethodRepositoryImpl(apiService: apiService);

    return BlocProvider(
      create: (_) => SupplierPaymentMethodsBloc(
        getPaymentMethods: GetSupplierPaymentMethodsUsecase(repository),
        savePaymentMethod: SaveSupplierPaymentMethodUsecase(repository),
      )..add(const SupplierPaymentMethodsStarted()),
      child: const _SupplierPaymentMethodsView(),
    );
  }
}

class _SupplierPaymentMethodsView extends StatelessWidget {
  const _SupplierPaymentMethodsView();

  @override
  Widget build(BuildContext context) {
    final strings = _PaymentStrings.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      drawer: const SupplierAppDrawer(),
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: primary, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          strings.title,
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w900,
            fontSize: 21,
          ),
        ),
        actions: [
          IconButton(
            tooltip: strings.refresh,
            onPressed: () => context
                .read<SupplierPaymentMethodsBloc>()
                .add(const SupplierPaymentMethodsRefreshed()),
            icon: Icon(Icons.refresh_rounded, color: primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<SupplierPaymentMethodsBloc, SupplierPaymentMethodsState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppToast.error(context, state.errorMessage!);
          }
          if (state.successMessage != null) {
            AppToast.success(context, state.successMessage!);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<SupplierPaymentMethodsBloc>()
                  .add(const SupplierPaymentMethodsRefreshed());
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppThemeTokens.screenHorizontalPadding),
              children: [
                _HeaderCard(strings: strings),
                const SizedBox(height: 18),
                if (state.methods.isEmpty)
                  _EmptyCard(message: strings.empty)
                else
                  ...state.methods.map((method) {
                    final isSaving =
                        state.savingMethodCode == method.code.toUpperCase();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SupplierPaymentMethodCard(
                        method: method,
                        isSaving: isSaving,
                        enabledLabel: strings.enabled,
                        disabledLabel: strings.disabled,
                        comingSoonLabel: strings.comingSoon,
                        credentialsRequiredLabel: strings.credentialsRequired,
                        onChanged: (enabled) {
                          context.read<SupplierPaymentMethodsBloc>().add(
                                SupplierPaymentMethodToggled(
                                  methodCode: method.code,
                                  enabled: enabled,
                                ),
                              );
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

class _HeaderCard extends StatelessWidget {
  final _PaymentStrings strings;

  const _HeaderCard({required this.strings});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
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
                  strings.headerTitle,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.headerSubtitle,
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
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
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppThemeTokens.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PaymentStrings {
  final String title;
  final String refresh;
  final String headerTitle;
  final String headerSubtitle;
  final String enabled;
  final String disabled;
  final String comingSoon;
  final String credentialsRequired;
  final String empty;

  const _PaymentStrings({
    required this.title,
    required this.refresh,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.enabled,
    required this.disabled,
    required this.comingSoon,
    required this.credentialsRequired,
    required this.empty,
  });

  static _PaymentStrings of(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    if (languageCode == 'ar') {
      return const _PaymentStrings(
        title: 'طرق الدفع',
        refresh: 'تحديث',
        headerTitle: 'طرق الدفع المعروضة للمتاجر',
        headerSubtitle:
            'فعّلي طرق الدفع التي يمكن للمتجر اختيارها عند الطلب. حاليًا الكاش جاهز بالكامل، وطرق الدفع الإلكترونية تحتاج إعدادات اعتماد وربط لاحق.',
        enabled: 'مفعّل',
        disabled: 'غير مفعّل',
        comingSoon: 'لاحقًا',
        credentialsRequired: 'تحتاج بيانات',
        empty: 'لا توجد طرق دفع متاحة حاليًا.',
      );
    }

    if (languageCode == 'fr') {
      return const _PaymentStrings(
        title: 'Méthodes de paiement',
        refresh: 'Actualiser',
        headerTitle: 'Méthodes disponibles pour les détaillants',
        headerSubtitle:
            'Activez les méthodes que le détaillant pourra choisir pendant la commande. Le paiement en espèces est prêt; les paiements en ligne nécessitent des identifiants et une intégration ultérieure.',
        enabled: 'Activé',
        disabled: 'Désactivé',
        comingSoon: 'Plus tard',
        credentialsRequired: 'Identifiants requis',
        empty: 'Aucune méthode de paiement disponible.',
      );
    }

    return const _PaymentStrings(
      title: 'Payment Methods',
      refresh: 'Refresh',
      headerTitle: 'Payment methods offered to retailers',
      headerSubtitle:
          'Enable the methods retailers can choose when placing an order. Cash is fully ready now; online payments need credentials and later checkout integration.',
      enabled: 'Enabled',
      disabled: 'Disabled',
      comingSoon: 'Later',
      credentialsRequired: 'Credentials required',
      empty: 'No payment methods are available yet.',
    );
  }
}
