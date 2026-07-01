import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../core/auth/session_manager.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/locale_cubit.dart';
import '../../../../injection_container.dart';


String _paymentMethodsLabel(BuildContext context) {
  final languageCode = Localizations.localeOf(context).languageCode;
  if (languageCode == 'ar') return 'طرق الدفع';
  if (languageCode == 'fr') return 'Méthodes de paiement';
  return 'Payment Methods';
}

class SupplierAppDrawer extends StatelessWidget {
  const SupplierAppDrawer({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = context.l10n;

    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: BoxDecoration(
              color: AppThemeTokens.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppThemeTokens.error.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: AppThemeTokens.error,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.supplierLogoutTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.supplierLogoutConfirmation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          side: BorderSide(
                            color: AppThemeTokens.border,
                            width: 1.3,
                          ),
                          foregroundColor: AppThemeTokens.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: Text(
                          l10n.supplierLogoutTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          elevation: 0,
                          backgroundColor: AppThemeTokens.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout != true) return;

    // Clears the stored session (token + refresh token); the router redirect
    // then takes the user to /login.
    await sl<SessionManager>().signOut();

    if (!context.mounted) return;
    Navigator.of(context).pop();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Drawer(
      width: 290,
      backgroundColor: AppThemeTokens.surface,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  _DrawerItem(
                    icon: Icons.trending_up,
                    title: l10n.supplierDrawerDashboard,
                    route: '/supplier-dashboard',
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    title: l10n.supplierDrawerProfile,
                    route: '/supplier-profile',
                  ),
                  _DrawerItem(
                    icon: Icons.workspace_premium_outlined,
                    title: l10n.supplierDrawerSubscription,
                    route: '/supplier-subscription',
                  ),
                  _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    title: l10n.supplierDrawerProducts,
                    route: '/supplier-products',
                  ),
                  _DrawerItem(
                    icon: Icons.category_outlined,
                    title: l10n.supplierDrawerCatalog,
                    route: '/supplier-catalog',
                  ),
                  _DrawerItem(
                    icon: Icons.location_on_outlined,
                    title: l10n.supplierDrawerBranches,
                    route: '/supplier-branches',
                  ),
                  _DrawerItem(
                    icon: Icons.shopping_bag_outlined,
                    title: l10n.supplierDrawerOrders,
                    route: '/supplier-orders',
                  ),
                  _DrawerItem(
                    icon: Icons.request_quote_outlined,
                    title: l10n.supplierDrawerRfqs,
                    route: '/supplier-rfqs',
                  ),
                  _DrawerItem(
                    icon: Icons.local_offer_outlined,
                    title: l10n.supplierDrawerPromotions,
                    route: '/supplier-promotions',
                  ),
                  _DrawerItem(
                    icon: Icons.sell_outlined,
                    title: l10n.supplierDrawerCoupons,
                    route: '/supplier-coupons',
                  ),
                  _DrawerItem(
                    icon: Icons.image_outlined,
                    title: l10n.supplierDrawerHomeBanners,
                    route: '/supplier-banners',
                  ),
                  _DrawerItem(
                    icon: Icons.local_shipping_outlined,
                    title: l10n.supplierDrawerShippingMethods,
                    route: '/supplier-shipping',
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: _paymentMethodsLabel(context),
                    route: '/supplier-payment-methods',
                  ),
                  _DrawerItem(
                    icon: Icons.percent_outlined,
                    title: l10n.supplierDrawerTaxes,
                    route: '/supplier-tax-rules',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const _SupplierDrawerLanguageTile(),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.logout, color: AppThemeTokens.error),
              title: Text(
                l10n.supplierLogoutTitle,
                style: TextStyle(
                  color: AppThemeTokens.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onTap: () => _confirmLogout(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SupplierDrawerLanguageTile extends StatelessWidget {
  const _SupplierDrawerLanguageTile();

  String _languageLabel(BuildContext context, String languageCode) {
    final l10n = context.l10n;

    switch (languageCode) {
      case 'ar':
        return l10n.arabic;
      case 'fr':
        return l10n.french;
      case 'en':
      default:
        return l10n.english;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguageCode =
        context.watch<LocaleCubit>().state.locale.languageCode;
    final l10n = context.l10n;

    return PopupMenuButton<String>(
      tooltip: l10n.language,
      initialValue: currentLanguageCode,
      onSelected: (value) {
        context.read<LocaleCubit>().changeLocale(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'en', child: Text(l10n.english)),
        PopupMenuItem(value: 'ar', child: Text(l10n.arabic)),
        PopupMenuItem(value: 'fr', child: Text(l10n.french)),
      ],
      child: ListTile(
        leading: Icon(
          Icons.language_rounded,
          color: AppThemeTokens.textPrimary,
          size: 22,
        ),
        title: Text(
          l10n.language,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        subtitle: Text(
          _languageLabel(context, currentLanguageCode),
          style: TextStyle(
            color: AppThemeTokens.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_drop_down_rounded,
          color: AppThemeTokens.textSecondary,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppThemeTokens.textPrimary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppThemeTokens.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}