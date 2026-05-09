import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/shipping_method_entity.dart';
import '../bloc/shipping_methods_bloc.dart';
import '../bloc/shipping_methods_event.dart';
import '../bloc/shipping_methods_state.dart';
import '../widgets/shipping_method_card.dart';

class ShippingMethodsScreen extends StatelessWidget {
  const ShippingMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShippingMethodsBloc>(
      create: (_) => sl<ShippingMethodsBloc>()
        ..add(const LoadShippingMethodsRequested()),
      child: const _ShippingMethodsView(),
    );
  }
}

class _ShippingMethodsView extends StatefulWidget {
  const _ShippingMethodsView();

  @override
  State<_ShippingMethodsView> createState() => _ShippingMethodsViewState();
}

class _ShippingMethodsViewState extends State<_ShippingMethodsView> {
  String _searchQuery = '';

  List<ShippingMethodEntity> _filteredMethods(
    List<ShippingMethodEntity> methods,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return methods;

    return methods.where((method) {
      return method.name.toLowerCase().contains(query) ||
          method.deliveryType.label.toLowerCase().contains(query) ||
          method.estimatedDeliveryTime.toLowerCase().contains(query) ||
          method.branchApplicabilityLabel.toLowerCase().contains(query) ||
          method.costLabel.toLowerCase().contains(query) ||
          method.statusLabel.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<ShippingMethodsBloc>().add(
          const LoadShippingMethodsRequested(),
        );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ShippingMethodEntity method,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Shipping Method',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Are you sure you want to delete "${method.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    context.read<ShippingMethodsBloc>().add(
          DeleteShippingMethodRequested(method.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<ShippingMethodsBloc, ShippingMethodsState>(
      listener: (context, state) {
        final message = state.successMessage ?? state.errorMessage;

        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          context.read<ShippingMethodsBloc>().add(
                const ClearShippingMethodMessageRequested(),
              );
        }
      },
      child: Scaffold(
        backgroundColor: AppThemeTokens.background,
        drawer: const SupplierAppDrawer(),
        appBar: AppBar(
          backgroundColor: AppThemeTokens.background,
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, size: 30),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          title: Text(
            'Shipping Methods',
            style: TextStyle(
              color: primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Create Shipping Method',
              onPressed: () => context.go('/supplier-shipping/create'),
              icon: const Icon(Icons.add_circle_outline),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => _refresh(context),
              icon: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<ShippingMethodsBloc, ShippingMethodsState>(
            builder: (context, state) {
              final filteredMethods = _filteredMethods(state.methods);

              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppThemeTokens.screenHorizontalPadding,
                    16,
                    AppThemeTokens.screenHorizontalPadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderCard(primary: primary),
                      const SizedBox(height: 18),
                      _SearchField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(count: filteredMethods.length),
                      const SizedBox(height: 12),
                      if (state.loading)
                        const _LoadingCard()
                      else if (state.errorMessage != null)
                        _ErrorCard(
                          message: state.errorMessage!,
                          onRetry: () => _refresh(context),
                        )
                      else if (state.methods.isEmpty)
                        _EmptyMethodsCard(primary: primary)
                      else if (filteredMethods.isEmpty)
                        _NoSearchResultsCard(primary: primary)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredMethods.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            final method = filteredMethods[index];

                            return ShippingMethodCard(
                              method: method,
                              onEdit: () {
                                context.go(
                                  '/supplier-shipping/edit',
                                  extra: method,
                                );
                              },
                              onDelete: () => _confirmDelete(context, method),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Color primary;

  const _HeaderCard({
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primary.withOpacity(0.12),
            child: Icon(
              Icons.local_shipping_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Shipping Methods',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'View, search, create, edit, and delete supplier shipping methods saved in the backend.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: AppThemeTokens.textSecondary,
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

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search shipping methods',
        hintStyle: const TextStyle(
          color: AppThemeTokens.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppThemeTokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color color = AppThemeTokens.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final int count;

  const _SectionHeader({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Method List',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count method${count == 1 ? '' : 's'} shown',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppThemeTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 34),
          const SizedBox(height: 12),
          const Text(
            'Could not load shipping methods',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMethodsCard extends StatelessWidget {
  final Color primary;

  const _EmptyMethodsCard({
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: primary.withOpacity(0.12),
            child: Icon(
              Icons.local_shipping_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No shipping methods yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create shipping methods from the supplier dashboard quick action or tap the plus icon above. This page is also for viewing, searching, editing, and deleting created methods.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSearchResultsCard extends StatelessWidget {
  final Color primary;

  const _NoSearchResultsCard({
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            color: primary,
            size: 34,
          ),
          const SizedBox(height: 12),
          const Text(
            'No matching shipping methods',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}