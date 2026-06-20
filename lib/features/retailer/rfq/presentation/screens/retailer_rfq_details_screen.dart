import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/currency/currency_formatter.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/rfq_request_entity.dart';
import '../cubit/retailer_rfq_cubit.dart';
import '../cubit/retailer_rfq_state.dart';
import '../widgets/rfq_info_banner.dart';
import '../widgets/rfq_quotation_card.dart';
import '../widgets/rfq_status_chip.dart';

class RetailerRfqDetailsScreen extends StatelessWidget {
  final int rfqId;

  const RetailerRfqDetailsScreen({super.key, required this.rfqId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerRfqCubit>()..loadDetails(rfqId),
      child: _RetailerRfqDetailsView(rfqId: rfqId),
    );
  }
}

class _RetailerRfqDetailsView extends StatelessWidget {
  final int rfqId;

  const _RetailerRfqDetailsView({required this.rfqId});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/retailer-rfqs');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<RetailerRfqCubit, RetailerRfqState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          AppToast.error(context, state.errorMessage!);
          context.read<RetailerRfqCubit>().clearMessages();
        }

        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          AppToast.success(context, _successMessage(l10n, state.successMessage!));
          context.read<RetailerRfqCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        final rfq = state.selectedRfq;

        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => _goBack(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: Text(
              l10n.rfqDetails,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              IconButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.read<RetailerRfqCubit>().loadDetails(rfqId),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: rfq == null && state.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : rfq == null
              ? const _NotFoundView()
              : RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: () =>
                      context.read<RetailerRfqCubit>().loadDetails(rfqId),
                  child: _DetailsContent(
                    rfq: rfq,
                    isSubmitting: state.isSubmitting,
                  ),
                ),
        );
      },
    );
  }

  String _successMessage(AppLocalizations l10n, String message) {
    return switch (message) {
      'RFQ posted successfully' => l10n.rfqPostedSuccessfully,
      'RFQ updated successfully' => l10n.rfqUpdatedSuccessfully,
      'RFQ cancelled successfully' => l10n.rfqCancelledSuccessfully,
      'RFQ deleted successfully' => l10n.rfqDeletedSuccessfully,
      'Quotation accepted successfully' =>
        l10n.rfqQuotationAcceptedSuccessfully,
      'AI requirements generated successfully' =>
        l10n.rfqAiGeneratedSuccessfully,
      _ => message,
    };
  }
}

class _DetailsContent extends StatelessWidget {
  final RfqRequestEntity rfq;
  final bool isSubmitting;

  const _DetailsContent({required this.rfq, required this.isSubmitting});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = _buildImageUrl(rfq.imageUrl);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const RfqInfoBanner(),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppThemeTokens.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppThemeTokens.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const _ImageFallback();
                    },
                  ),
                )
              else
                const _ImageFallback(),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RfqStatusChip(status: rfq.status),
                    const SizedBox(height: 12),
                    Text(
                      rfq.productName,
                      style: const TextStyle(
                        color: AppThemeTokens.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rfq.requirements,
                      style: const TextStyle(
                        color: AppThemeTokens.textSecondary,
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _InfoGrid(rfq: rfq),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (rfq.canCancel)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isSubmitting
                  ? null
                  : () => _confirmCancel(
                      context,
                      rfqId: rfq.id,
                      hasSupplierQuotations: rfq.hasSupplierQuotations,
                    ),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(l10n.rfqCancel),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeTokens.error,
                side: const BorderSide(color: AppThemeTokens.error),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.rfqSupplierQuotations,
                style: const TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${rfq.quotations.length}',
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (rfq.quotations.isEmpty)
          const _NoQuotesYet()
        else
          ...rfq.quotations.map((quotation) {
            final canAcceptQuotation =
                (rfq.isOpen || rfq.isQuoted) &&
                quotation.status.toUpperCase() == 'PENDING';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RfqQuotationCard(
                quotation: quotation,
                isSubmitting: isSubmitting,
                onAccept: canAcceptQuotation
                    ? () => _confirmAccept(
                        context,
                        rfqId: rfq.id,
                        quotationId: quotation.id,
                      )
                    : null,
              ),
            );
          }),
      ],
    );
  }

  String? _buildImageUrl(String? value) {
    final clean = value?.trim();

    if (clean == null || clean.isEmpty) {
      return null;
    }

    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }

    final base = AppConfig.projectApiBaseUrl.replaceFirst(
      RegExp(r'/api/?$'),
      '',
    );

    if (clean.startsWith('/')) {
      return '$base$clean';
    }

    return '$base/$clean';
  }

  void _confirmCancel(
    BuildContext context, {
    required int rfqId,
    required bool hasSupplierQuotations,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.rfqCancelQuestion),
          content: Text(
            hasSupplierQuotations
                ? l10n.rfqCancelWithQuotesMessage
                : l10n.rfqCancelMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.rfqKeep),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<RetailerRfqCubit>().cancelRfq(rfqId);
              },
              child: Text(
                l10n.rfqCancel,
                style: const TextStyle(color: AppThemeTokens.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmAccept(
    BuildContext context, {
    required int rfqId,
    required int quotationId,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.rfqAcceptQuotationQuestion),
          content: Text(l10n.rfqAcceptQuotationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.rfqReviewMore),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<RetailerRfqCubit>().acceptQuotation(
                  rfqId: rfqId,
                  quotationId: quotationId,
                );
              },
              child: Text(l10n.rfqAccept),
            ),
          ],
        );
      },
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final RfqRequestEntity rfq;

  const _InfoGrid({required this.rfq});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = <_InfoItem>[
      _InfoItem(
        icon: Icons.inventory_2_outlined,
        title: l10n.rfqQuantity,
        value: l10n.rfqQuantityLabel(rfq.quantity, rfq.unit),
      ),
      _InfoItem(
        icon: Icons.local_shipping_outlined,
        title: l10n.rfqDelivery,
        value: _deliveryLabel(l10n, rfq.preferredDeliveryLabel),
      ),
      _InfoItem(
        icon: Icons.location_on_outlined,
        title: l10n.rfqLocation,
        value: _locationLabel(l10n, rfq),
      ),
      if (rfq.categoryName != null && rfq.categoryName!.trim().isNotEmpty)
        _InfoItem(
          icon: Icons.category_outlined,
          title: l10n.rfqCategory,
          value: rfq.categoryName!,
        ),
      if (rfq.subCategoryName != null && rfq.subCategoryName!.trim().isNotEmpty)
        _InfoItem(
          icon: Icons.account_tree_outlined,
          title: l10n.rfqSubcategory,
          value: rfq.subCategoryName!,
        ),
      if (rfq.targetUnitPrice != null)
        _InfoItem(
          icon: Icons.attach_money_rounded,
          title: l10n.rfqTargetPrice,
          value: '${CurrencyFormatter.format(context, rfq.targetUnitPrice)} / ${rfq.unit}',
        ),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: item,
            ),
          )
          .toList(),
    );
  }

  String _deliveryLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'Within 24 hours' => l10n.rfqDeliveryWithin24Hours,
      'Within 2-3 days' => l10n.rfqDelivery2To3Days,
      'Within 1 week' => l10n.rfqDeliveryWithin1Week,
      'Within 2 weeks' => l10n.rfqDeliveryWithin2Weeks,
      'Flexible' => l10n.rfqDeliveryFlexible,
      _ => value,
    };
  }

  String _locationLabel(AppLocalizations l10n, RfqRequestEntity rfq) {
    final parts = [
      rfq.deliveryCity,
      rfq.deliveryRegionName,
      rfq.deliveryCountryName,
    ].where((value) => value != null && value.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return l10n.rfqNoDeliveryLocation;
    }

    return parts.join(', ');
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppThemeTokens.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: AppThemeTokens.background,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppThemeTokens.textSecondary,
        ),
      ),
    );
  }
}

class _NoQuotesYet extends StatelessWidget {
  const _NoQuotesYet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.hourglass_empty_rounded,
            color: AppThemeTokens.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.rfqNoQuotesYet,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Text(
        l10n.rfqNotFound,
        style: const TextStyle(
          color: AppThemeTokens.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
