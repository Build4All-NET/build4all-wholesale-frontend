import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme_tokens.dart';

class SupplierAppDrawer extends StatelessWidget {
  const SupplierAppDrawer({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
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
                children: const [
                  _DrawerItem(
                    icon: Icons.trending_up,
                    title: 'Dashboard',
                    route: '/supplier-dashboard',
                  ),
                  _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Products',
                    route: '/supplier-products',
                  ),
                  _DrawerItem(
                    icon: Icons.location_on_outlined,
                    title: 'Branches',
                    route: '/supplier-branches',
                  ),
                  _DrawerItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Orders',
                    route: '/supplier-orders',
                  ),
                  _DrawerItem(
                    icon: Icons.local_offer_outlined,
                    title: 'Promotions',
                    route: '/supplier-promotions',
                  ),
                  _DrawerItem(
                    icon: Icons.sell_outlined,
                    title: 'Coupons',
                    route: '/supplier-coupons',
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    route: '/supplier-settings',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
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
        style: const TextStyle(
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