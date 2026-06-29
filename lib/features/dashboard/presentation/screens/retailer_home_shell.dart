import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../retailer/orders/presentation/screens/retailer_orders_screen.dart';
import '../../../retailer/rfq/presentation/screens/retailer_rfq_list_screen.dart';
import '../../../retailer_profile/presentation/screens/retailer_profile_screen.dart';
import 'retailer_dashboard_screen.dart';

/// Persistent shell for the four main retailer tabs.
///
/// Uses an [IndexedStack] so each tab keeps its state (and its already-loaded
/// data) when switching — no more full reload on every tab change — and the
/// bottom navigation bar stays visible across all four tabs.
class RetailerHomeShell extends StatefulWidget {
  final int initialIndex;

  const RetailerHomeShell({super.key, this.initialIndex = 0});

  @override
  State<RetailerHomeShell> createState() => _RetailerHomeShellState();
}

class _RetailerHomeShellState extends State<RetailerHomeShell> {
  late int _currentIndex;

  static const _tabs = <Widget>[
    RetailerDashboardScreen(),
    RetailerOrdersScreen(),
    RetailerRfqListScreen(),
    // The shell owns the bottom nav, so the profile tab must not draw its own.
    RetailerProfileScreen(embedded: true),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _tabs.length - 1);
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: AppThemeTokens.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            label: l10n.orders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.description_outlined),
            label: l10n.rfq,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
