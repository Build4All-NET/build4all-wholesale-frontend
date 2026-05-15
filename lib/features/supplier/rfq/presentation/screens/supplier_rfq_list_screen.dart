import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/supplier_rfq_request_entity.dart';
import '../cubit/supplier_rfq_cubit.dart';
import '../cubit/supplier_rfq_state.dart';
import '../utils/supplier_rfq_i18n.dart';
import '../widgets/supplier_rfq_card.dart';

class SupplierRfqListScreen extends StatelessWidget {
  const SupplierRfqListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupplierRfqCubit>()..loadOpenRfqs(),
      child: const _SupplierRfqListView(),
    );
  }
}

class _SupplierRfqListView extends StatefulWidget {
  const _SupplierRfqListView();

  @override
  State<_SupplierRfqListView> createState() => _SupplierRfqListViewState();
}

class _SupplierRfqListViewState extends State<_SupplierRfqListView> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'ALL';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = SupplierRfqI18n(context);

    return BlocConsumer<SupplierRfqCubit, SupplierRfqState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<SupplierRfqCubit>().clearMessages();
        }

        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
          context.read<SupplierRfqCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          drawer: const SupplierAppDrawer(),
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            title: Text(
              l.t('rfqRequests'),
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.read<SupplierRfqCubit>().loadOpenRfqs(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () => context.read<SupplierRfqCubit>().loadOpenRfqs(),
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SupplierRfqState state) {
    final l = SupplierRfqI18n(context);

    if (state.isLoading && state.rfqs.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      );
    }

    final rfqs = _filterRfqs(state.rfqs);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _HeaderCard(isLoading: state.isLoading),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: l.t('searchHint'),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: AppThemeTokens.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppThemeTokens.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppThemeTokens.border),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            _FilterChip(label: l.t('all'), selected: _filter == 'ALL', onTap: () => setState(() => _filter = 'ALL')),
            _FilterChip(label: l.t('open'), selected: _filter == 'OPEN', onTap: () => setState(() => _filter = 'OPEN')),
            _FilterChip(label: l.t('quoted'), selected: _filter == 'QUOTED', onTap: () => setState(() => _filter = 'QUOTED')),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                l.countRequests(rfqs.length),
                style: const TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 18,
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
        if (rfqs.isEmpty)
          _EmptyRfqsView(onRefresh: () => context.read<SupplierRfqCubit>().loadOpenRfqs())
        else
          ...rfqs.map(
            (rfq) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SupplierRfqCard(
                rfq: rfq,
                onTap: () async {
                  await context.push('/supplier-rfqs/${rfq.id}');
                  if (!context.mounted) return;
                  context.read<SupplierRfqCubit>().loadOpenRfqs();
                },
              ),
            ),
          ),
      ],
    );
  }

  List<SupplierRfqRequestEntity> _filterRfqs(List<SupplierRfqRequestEntity> rfqs) {
    return rfqs.where((rfq) {
      final matchesFilter = _filter == 'ALL' || rfq.normalizedStatus == _filter;
      if (!matchesFilter) return false;
      if (_query.isEmpty) return true;

      final searchable = [
        rfq.productName,
        rfq.requirements,
        rfq.categoryName,
        rfq.subCategoryName,
        rfq.deliveryCity,
        rfq.deliveryRegionName,
        rfq.deliveryCountryName,
      ].whereType<String>().join(' ').toLowerCase();

      return searchable.contains(_query);
    }).toList();
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isLoading;

  const _HeaderCard({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final l = SupplierRfqI18n(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.request_quote_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t('openRfqsFromRetailers'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  l.t('reviewRequests'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).colorScheme.primary : AppThemeTokens.textSecondary,
        fontWeight: FontWeight.w900,
      ),
      side: BorderSide(
        color: selected ? Theme.of(context).colorScheme.primary : AppThemeTokens.border,
      ),
    );
  }
}

class _EmptyRfqsView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyRfqsView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l = SupplierRfqI18n(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 44, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            l.t('noOpenRfqs'),
            style: const TextStyle(color: AppThemeTokens.textPrimary, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            l.t('noOpenRfqsMessage'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppThemeTokens.textSecondary, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l.t('refresh')),
          ),
        ],
      ),
    );
  }
}
