import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/rfq_request_entity.dart';
import '../cubit/retailer_rfq_cubit.dart';
import '../cubit/retailer_rfq_state.dart';
import '../widgets/rfq_card.dart';
import '../widgets/rfq_info_banner.dart';

class RetailerRfqListScreen extends StatelessWidget {
  const RetailerRfqListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerRfqCubit>()..loadMyRfqs(),
      child: const _RetailerRfqListView(),
    );
  }
}

class _RetailerRfqListView extends StatefulWidget {
  const _RetailerRfqListView();

  @override
  State<_RetailerRfqListView> createState() => _RetailerRfqListViewState();
}

class _RetailerRfqListViewState extends State<_RetailerRfqListView> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RfqRequestEntity> _filteredRfqs(List<RfqRequestEntity> source) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((rfq) {
      final text = [
        rfq.productName,
        rfq.requirements,
        rfq.categoryName ?? '',
        rfq.subCategoryName ?? '',
        rfq.status,
        rfq.quantityLabel,
        rfq.targetUnitPrice?.toString() ?? '',
        rfq.deliveryLocationLabel,
        rfq.deliveryAddress ?? '',
      ].join(' ').toLowerCase();

      return text.contains(query);
    }).toList(growable: false);
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
        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            title: Text(
              l10n.rfqMyRfqs,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/retailer-dashboard');
                }
              },
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await context.push('/retailer-rfqs/create');
              if (!context.mounted) return;
              context.read<RetailerRfqCubit>().loadMyRfqs();
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              l10n.rfqCreate,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () => context.read<RetailerRfqCubit>().loadMyRfqs(),
            child: _buildBody(context, state, l10n),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    RetailerRfqState state,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.rfqs.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    final visibleRfqs = _filteredRfqs(state.rfqs);
    final hasSearch = _searchQuery.trim().isNotEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        const RfqInfoBanner(),
        const SizedBox(height: 18),
        _RfqSearchBox(
          controller: _searchController,
          hintText: '${l10n.searchLabel} ${l10n.rfq}',
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.rfqRequestsYouPosted,
                style: const TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (state.isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.rfqs.isEmpty)
          _EmptyRfqsView(onCreate: () => context.push('/retailer-rfqs/create'))
        else if (visibleRfqs.isEmpty)
          _EmptySearchRfqsView(
            message: hasSearch ? 'No matching RFQs found.' : l10n.rfqNoRfqsYet,
          )
        else
          ...visibleRfqs.map(
            (rfq) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RfqCard(
                rfq: rfq,
                onTap: () => context.push('/retailer-rfqs/${rfq.id}'),
                onEdit: rfq.canEdit
                    ? () async {
                        await context.push('/retailer-rfqs/${rfq.id}/edit');
                        if (!context.mounted) return;
                        context.read<RetailerRfqCubit>().loadMyRfqs();
                      }
                    : null,
                onCancel: rfq.canCancel
                    ? () => _confirmCancel(context, rfq, l10n)
                    : null,
                onDelete: rfq.canDelete
                    ? () => _confirmDelete(context, rfq, l10n)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  void _confirmCancel(
    BuildContext context,
    RfqRequestEntity rfq,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.rfqCancelQuestion),
          content: Text(
            rfq.hasSupplierQuotations
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
                context.read<RetailerRfqCubit>().cancelRfq(rfq.id);
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

  void _confirmDelete(
    BuildContext context,
    RfqRequestEntity rfq,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.rfqDeleteQuestion),
          content: Text(l10n.rfqDeleteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.rfqKeep),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<RetailerRfqCubit>().deleteRfq(rfq.id);
              },
              child: Text(
                l10n.rfqDelete,
                style: const TextStyle(color: AppThemeTokens.error),
              ),
            ),
          ],
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

class _RfqSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _RfqSearchBox({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppThemeTokens.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();

              return IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppThemeTokens.textSecondary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptySearchRfqsView extends StatelessWidget {
  final String message;

  const _EmptySearchRfqsView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 54,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
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

class _EmptyRfqsView extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyRfqsView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.request_quote_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.rfqNoRfqsYet,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.rfqNoRfqsYetMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.rfqCreate),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
