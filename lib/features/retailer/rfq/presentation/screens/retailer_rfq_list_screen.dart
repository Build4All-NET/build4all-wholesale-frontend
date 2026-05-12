import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
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

class _RetailerRfqListView extends StatelessWidget {
  const _RetailerRfqListView();

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
        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            title: const Text(
              'My RFQs',
              style: TextStyle(
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
            label: const Text(
              'Create RFQ',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () => context.read<RetailerRfqCubit>().loadMyRfqs(),
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RetailerRfqState state) {
    if (state.isLoading && state.rfqs.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        const RfqInfoBanner(),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Requests you posted',
                style: TextStyle(
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
        else
          ...state.rfqs.map(
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
                    ? () => _confirmCancel(context, rfq)
                    : null,
                onDelete: rfq.canDelete
                    ? () => _confirmDelete(context, rfq)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  void _confirmCancel(BuildContext context, RfqRequestEntity rfq) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel RFQ?'),
          content: Text(
            rfq.hasSupplierQuotations
                ? 'This RFQ already has supplier quotations. Cancelling keeps the history but prevents new supplier actions.'
                : 'This will cancel your RFQ and suppliers will not be able to quote it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Keep RFQ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<RetailerRfqCubit>().cancelRfq(rfq.id);
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

  void _confirmDelete(BuildContext context, RfqRequestEntity rfq) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete RFQ?'),
          content: const Text(
            'This RFQ has no supplier quotations yet, so it can be safely deleted. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Keep RFQ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<RetailerRfqCubit>().deleteRfq(rfq.id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppThemeTokens.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyRfqsView extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyRfqsView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No RFQs yet',
            style: TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first request and let suppliers send you quotations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create RFQ'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
