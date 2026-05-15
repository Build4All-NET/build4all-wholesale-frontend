import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/coupon_entity.dart';
import '../bloc/coupons_bloc.dart';
import '../bloc/coupons_event.dart';
import '../bloc/coupons_state.dart';
import '../widgets/coupon_card.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CouponsBloc>(
      create: (_) => sl<CouponsBloc>()..add(const LoadCouponsRequested()),
      child: const _CouponsView(),
    );
  }
}

class _CouponsView extends StatefulWidget {
  const _CouponsView();

  @override
  State<_CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<_CouponsView> {
  Future<void> _refresh(BuildContext context) async {
    context.read<CouponsBloc>().add(const LoadCouponsRequested());
  }

  Future<void> _confirmDeleteCoupon(
    BuildContext context,
    CouponEntity coupon,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.supplierDeleteCoupon,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            context.l10n.supplierDeleteCouponConfirmation(coupon.code),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(
                context.l10n.deleteButton,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    context.read<CouponsBloc>().add(
          DeleteCouponRequested(coupon.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<CouponsBloc, CouponsState>(
      listener: (context, state) {
        final message = state.successMessage ?? state.errorMessage;

        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          context.read<CouponsBloc>().add(
                const ClearCouponMessageRequested(),
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
            context.l10n.supplierCoupons,
            style: TextStyle(
              color: primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              tooltip: context.l10n.supplierCreateCoupon,
              onPressed: () => context.go('/supplier-coupons/create'),
              icon: const Icon(Icons.add_circle_outline),
            ),
            IconButton(
              tooltip: context.l10n.refreshButton,
              onPressed: () => _refresh(context),
              icon: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<CouponsBloc, CouponsState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(
                    AppThemeTokens.screenHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderCard(primary: primary),
                      const SizedBox(height: 20),
                      Text(
                        context.l10n.supplierCouponList,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state.loading)
                        const _LoadingCard()
                      else if (state.errorMessage != null)
                        _ErrorCard(
                          message: state.errorMessage!,
                          onRetry: () => _refresh(context),
                        )
                      else if (state.coupons.isEmpty)
                        _EmptyCouponsCard(primary: primary)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.coupons.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            final coupon = state.coupons[index];

                            return CouponCard(
                              coupon: coupon,
                              onEdit: () {
                                context.go(
                                  '/supplier-coupons/edit',
                                  extra: coupon,
                                );
                              },
                              onDelete: () {
                                _confirmDeleteCoupon(context, coupon);
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 28),
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

  const _HeaderCard({required this.primary});

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
              Icons.confirmation_number_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.supplierManageCoupons,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  context.l10n.supplierCouponsDescription,
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
      child: const Center(
        child: CircularProgressIndicator(),
      ),
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
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.supplierCouldNotLoadCoupons,
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
            child: Text(
              context.l10n.retryButton,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCouponsCard extends StatelessWidget {
  final Color primary;

  const _EmptyCouponsCard({required this.primary});

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
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: primary.withOpacity(0.12),
            child: Icon(
              Icons.confirmation_number_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.supplierNoCouponsYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.supplierCreateCouponsFromDashboard,
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