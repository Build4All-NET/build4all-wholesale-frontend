import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/supplier_rfq_request_entity.dart';
import '../../domain/entities/supplier_rfq_quotation_entity.dart';
import '../../domain/repositories/supplier_rfq_repository.dart';
import '../cubit/supplier_rfq_cubit.dart';
import '../cubit/supplier_rfq_state.dart';
import '../utils/supplier_rfq_i18n.dart';
import '../utils/supplier_rfq_image_url_helper.dart';
import '../widgets/supplier_quotation_form_dialog.dart';
import '../widgets/supplier_rfq_quotation_card.dart';
import '../widgets/supplier_rfq_status_chip.dart';

class SupplierRfqDetailsScreen extends StatelessWidget {
  final int rfqId;

  const SupplierRfqDetailsScreen({super.key, required this.rfqId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupplierRfqCubit>()..loadDetails(rfqId),
      child: _SupplierRfqDetailsView(rfqId: rfqId),
    );
  }
}

class _SupplierRfqDetailsView extends StatelessWidget {
  final int rfqId;

  const _SupplierRfqDetailsView({required this.rfqId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupplierRfqCubit, SupplierRfqState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<SupplierRfqCubit>().clearMessages();
        }

        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(SupplierRfqI18n(context).t(state.successMessage!))));
          context.read<SupplierRfqCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            title: Text(
              SupplierRfqI18n(context).t('rfqDetails'),
              style: const TextStyle(color: AppThemeTokens.textPrimary, fontWeight: FontWeight.w900),
            ),
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/supplier-rfqs');
                }
              },
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            actions: [
              IconButton(
                onPressed: () => context.read<SupplierRfqCubit>().loadDetails(rfqId),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          bottomNavigationBar: state.selectedRfq == null
              ? null
              : _BottomActionBar(
                  rfq: state.selectedRfq!,
                  isSubmitting: state.isSubmitting,
                  onSubmit: () => _openQuotationDialog(context, state.selectedRfq!),
                ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SupplierRfqState state) {
    if (state.isLoading && state.selectedRfq == null) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    final rfq = state.selectedRfq;
    if (rfq == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppThemeTokens.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppThemeTokens.border),
            ),
            child: Text(SupplierRfqI18n(context).t('rfqNotOpened')),
          ),
        ],
      );
    }

    final imageUrl = buildSupplierRfqPublicImageUrl(rfq.imageUrl);
    final quotation = rfq.myQuotation;

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => context.read<SupplierRfqCubit>().loadDetails(rfqId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
        children: [
          _ImageHeader(imageUrl: imageUrl),
          const SizedBox(height: 16),
          _MainInfoCard(rfq: rfq),
          const SizedBox(height: 14),
          _SectionCard(
            title: SupplierRfqI18n(context).t('requirements'),
            icon: Icons.description_outlined,
            child: Text(
              rfq.requirements.isEmpty ? SupplierRfqI18n(context).t('noRequirementsAdded') : rfq.requirements,
              style: const TextStyle(color: AppThemeTokens.textSecondary, fontWeight: FontWeight.w600, height: 1.5),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: SupplierRfqI18n(context).t('deliveryInformation'),
            icon: Icons.local_shipping_outlined,
            child: Column(
              children: [
                _DetailRow(label: SupplierRfqI18n(context).t('preferredDelivery'), value: rfq.preferredDeliveryLabel),
                _DetailRow(label: SupplierRfqI18n(context).t('deadline'), value: _dateOrDash(rfq.deadlineDate)),
                _DetailRow(label: SupplierRfqI18n(context).t('country'), value: rfq.deliveryCountryName ?? '-'),
                _DetailRow(label: SupplierRfqI18n(context).t('region'), value: rfq.deliveryRegionName ?? '-'),
                _DetailRow(label: SupplierRfqI18n(context).t('city'), value: rfq.deliveryCity ?? '-'),
                _DetailRow(label: SupplierRfqI18n(context).t('address'), value: rfq.deliveryAddress ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (quotation != null)
            SupplierRfqQuotationCard(
              quotation: quotation,
              onEdit: quotation.canEdit ? () => _openQuotationDialog(context, rfq, quotation: quotation) : null,
              onWithdraw: quotation.canWithdraw ? () => _confirmWithdraw(context, quotation) : null,
            )
          else
            _NoQuotationCard(rfq: rfq),
        ],
      ),
    );
  }

  Future<void> _openQuotationDialog(
    BuildContext context,
    SupplierRfqRequestEntity rfq, {
    SupplierRfqQuotationEntity? quotation,
  }) async {
    final params = await showModalBottomSheet<SupplierQuotationParams>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SupplierQuotationFormDialog(quotation: quotation),
    );

    if (params == null || !context.mounted) return;

    if (quotation == null) {
      await context.read<SupplierRfqCubit>().submitQuotation(rfqId: rfq.id, params: params);
    } else {
      await context.read<SupplierRfqCubit>().updateQuotation(quotationId: quotation.id, params: params);
    }
  }

  void _confirmWithdraw(BuildContext context, SupplierRfqQuotationEntity quotation) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(SupplierRfqI18n(context).t('withdrawQuotationQuestion')),
          content: Text(SupplierRfqI18n(context).t('withdrawQuotationMessage')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(SupplierRfqI18n(context).t('keepQuotation')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<SupplierRfqCubit>().withdrawQuotation(quotation.id);
              },
              child: Text(SupplierRfqI18n(context).t('withdraw'), style: const TextStyle(color: AppThemeTokens.error)),
            ),
          ],
        );
      },
    );
  }

  String _dateOrDash(DateTime? date) {
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _ImageHeader extends StatelessWidget {
  final String? imageUrl;

  const _ImageHeader({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 190,
        width: double.infinity,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        child: imageUrl == null
            ? Icon(Icons.inventory_2_outlined, size: 56, color: Theme.of(context).colorScheme.primary)
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.broken_image_outlined,
                  size: 46,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ),
    );
  }
}

class _MainInfoCard extends StatelessWidget {
  final SupplierRfqRequestEntity rfq;

  const _MainInfoCard({required this.rfq});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  rfq.productName.isEmpty ? SupplierRfqI18n(context).t('unnamedProduct') : rfq.productName,
                  style: const TextStyle(color: AppThemeTokens.textPrimary, fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              SupplierRfqStatusChip(status: rfq.status),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniInfo(icon: Icons.inventory_2_outlined, label: SupplierRfqI18n(context).t('quantity'), value: rfq.quantityLabel),
              _MiniInfo(icon: Icons.category_outlined, label: SupplierRfqI18n(context).t('category'), value: rfq.categoryName ?? '-'),
              _MiniInfo(icon: Icons.account_tree_outlined, label: SupplierRfqI18n(context).t('subcategory'), value: rfq.subCategoryName ?? '-'),
              _MiniInfo(
                icon: Icons.payments_outlined,
                label: SupplierRfqI18n(context).t('targetUnitPrice'),
                value: rfq.targetUnitPrice == null ? '-' : rfq.targetUnitPrice!.toStringAsFixed(2),
              ),
              _MiniInfo(icon: Icons.request_quote_outlined, label: SupplierRfqI18n(context).t('quotes'), value: rfq.quotationsCount.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: AppThemeTokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: AppThemeTokens.textSecondary, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppThemeTokens.textPrimary, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniInfo({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppThemeTokens.textSecondary, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppThemeTokens.textPrimary, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _NoQuotationCard extends StatelessWidget {
  final SupplierRfqRequestEntity rfq;

  const _NoQuotationCard({required this.rfq});

  @override
  Widget build(BuildContext context) {
    final available = rfq.canQuote;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.request_quote_outlined : Icons.lock_outline_rounded,
            color: available ? Theme.of(context).colorScheme.primary : AppThemeTokens.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              available
                  ? SupplierRfqI18n(context).t('submitQuotationSmall')
                  : SupplierRfqI18n(context).t('notAvailableForQuotations'),
              style: const TextStyle(color: AppThemeTokens.textSecondary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final SupplierRfqRequestEntity rfq;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _BottomActionBar({required this.rfq, required this.isSubmitting, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    if (!rfq.canSubmitQuotation) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: AppThemeTokens.surface,
          border: Border(top: BorderSide(color: AppThemeTokens.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isSubmitting ? null : onSubmit,
            icon: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(isSubmitting ? SupplierRfqI18n(context).t('submitting') : SupplierRfqI18n(context).t('submitQuotation')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}
