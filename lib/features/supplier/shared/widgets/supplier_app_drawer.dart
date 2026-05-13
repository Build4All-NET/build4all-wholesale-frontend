import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../core/theme/app_theme_tokens.dart';

class SupplierAppDrawer extends StatelessWidget {
  const SupplierAppDrawer({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = context.l10n;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            l10n.supplierLogoutTitle,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(l10n.supplierLogoutConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeTokens.error,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.supplierLogoutTitle),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;
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
                icon: Icon(Icons.close),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 4),
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
                    icon: Icons.percent_outlined,
                    title: l10n.supplierDrawerTaxes,
                    route: '/supplier-tax-rules',
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: l10n.supplierDrawerSettings,
                    route: '/supplier-settings',
                  ),
                ],
              ),
            ),
            Divider(height: 1),
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
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  _DrawerItem({
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
