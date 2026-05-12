import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/rfq_request_entity.dart';
import '../cubit/retailer_rfq_cubit.dart';
import '../cubit/retailer_rfq_state.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RetailerRfqCubit, RetailerRfqState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<RetailerRfqCubit>().clearMessages();
        }

        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
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
            title: const Text(
              'RFQ Details',
              style: TextStyle(
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
}

class _DetailsContent extends StatelessWidget {
  final RfqRequestEntity rfq;
  final bool isSubmitting;

  const _DetailsContent({required this.rfq, required this.isSubmitting});

  @override
  Widget build(BuildContext context) {
    final imageUrl = _buildImageUrl(rfq.imageUrl);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
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
                  : () => _confirmCancel(context, rfq.id),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel RFQ'),
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
            const Expanded(
              child: Text(
                'Supplier quotations',
                style: TextStyle(
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
          ...rfq.quotations.map(
            (quotation) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RfqQuotationCard(
                quotation: quotation,
                isSubmitting: isSubmitting,
                onAccept: rfq.isOpen || rfq.isQuoted
                    ? () => _confirmAccept(
                        context,
                        rfqId: rfq.id,
                        quotationId: quotation.id,
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  String? _buildImageUrl(String? value) {
    final clean = value?.trim();

    if (clean == null || clean.isEmpty) return null;

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

  void _confirmCancel(BuildContext context, int rfqId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel RFQ?'),
          content: const Text(
            'Suppliers will no longer be able to send quotations for this request.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Keep RFQ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<RetailerRfqCubit>().cancelRfq(rfqId);
              },
              child: const Text(
                'Cancel RFQ',
                style: TextStyle(color: AppThemeTokens.error),
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
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Accept quotation?'),
          content: const Text(
            'This will mark the selected supplier quotation as accepted and close the RFQ.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Review more'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<RetailerRfqCubit>().acceptQuotation(
                  rfqId: rfqId,
                  quotationId: quotationId,
                );
              },
              child: const Text('Accept'),
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
    final items = [
      _InfoItem(
        icon: Icons.inventory_2_outlined,
        title: 'Quantity',
        value: rfq.quantityLabel,
      ),
      _InfoItem(
        icon: Icons.local_shipping_outlined,
        title: 'Delivery',
        value: rfq.preferredDeliveryLabel,
      ),
      _InfoItem(
        icon: Icons.location_on_outlined,
        title: 'Location',
        value: rfq.deliveryLocationLabel,
      ),
      if (rfq.categoryName != null)
        _InfoItem(
          icon: Icons.category_outlined,
          title: 'Category',
          value: rfq.categoryName!,
        ),
      if (rfq.targetUnitPrice != null)
        _InfoItem(
          icon: Icons.attach_money_rounded,
          title: 'Target price',
          value: '\$${rfq.targetUnitPrice!.toStringAsFixed(2)} / ${rfq.unit}',
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            color: AppThemeTokens.textSecondary,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No supplier quotations yet. You will see offers here when suppliers respond.',
              style: TextStyle(
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
    return const Center(
      child: Text(
        'RFQ not found',
        style: TextStyle(
          color: AppThemeTokens.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
