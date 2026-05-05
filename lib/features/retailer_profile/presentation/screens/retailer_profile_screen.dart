import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../cubit/retailer_profile_cubit.dart';
import '../cubit/retailer_profile_state.dart';

import '../../../../core/theme/locale_cubit.dart';

class RetailerProfileScreen extends StatelessWidget {
  const RetailerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerProfileCubit>()..loadProfile(),
      child: const _RetailerProfileView(),
    );
  }
}

class _RetailerProfileView extends StatelessWidget {
  const _RetailerProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RetailerProfileCubit, RetailerProfileState>(
      listener: (context, state) {
        if (state.logoutSuccess) {
          context.go('/login');
        }

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<RetailerProfileCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final primaryColor = Theme.of(context).colorScheme.primary;

        if (state.isLoading && state.profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = state.profile;

        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            title: Text(l10n.profileTitle),
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/retailer-dashboard'),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<RetailerProfileCubit>().loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                AppThemeTokens.screenHorizontalPadding,
              ),
              child: Column(
                children: [
                  if (profile != null)
                    _ProfileHeaderCard(
                      name: profile.account.fullName.isEmpty
                          ? profile.business.storeName
                          : profile.account.fullName,
                      email: profile.account.email,
                      storeName: profile.business.storeName,
                    ),
                  const SizedBox(height: 18),
                  _BalanceCards(primaryColor: primaryColor),
                  const SizedBox(height: 24),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.settings,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    isLoggingOut: state.isLoggingOut,
                    onEditProfile: () => context.push('/retailer-profile/edit'),
                    onLogout: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _ProfileBottomNav(
            currentIndex: 4,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/retailer-dashboard');
                  break;
                case 1:
                  context.go('/retailer-top-ranking');
                  break;
                case 2:
                  context.go('/retailer-orders');
                  break;
                case 3:
                  context.go('/retailer-rfq');
                  break;
                case 4:
                  break;
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<RetailerProfileCubit>().logout();
    }
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String storeName;

  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 48),
          padding: const EdgeInsets.fromLTRB(18, 58, 18, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppThemeTokens.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                name.isEmpty ? storeName : name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                storeName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 6),
          ),
          child: Icon(Icons.storefront_rounded, color: primaryColor, size: 48),
        ),
      ],
    );
  }
}

class _BalanceCards extends StatelessWidget {
  final Color primaryColor;

  const _BalanceCards({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: _BalanceCard(
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.walletBalance,
            value: l10n.comingSoon,
            color: primaryColor,
            onTap: () => context.push('/retailer-wallet'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BalanceCard(
            icon: Icons.credit_card_outlined,
            title: l10n.creditBalance,
            value: l10n.comingSoon,
            color: primaryColor,
            onTap: () => context.push('/retailer-credit'),
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _BalanceCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 128,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isLoggingOut;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  const _SettingsCard({
    required this.isLoggingOut,
    required this.onEditProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.edit_rounded,
            iconColor: primaryColor,
            title: l10n.editProfile,
            subtitle: l10n.basicInformation,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onEditProfile,
          ),
          const Divider(height: 1),
          _SettingsRow(
            icon: Icons.language_rounded,
            iconColor: primaryColor,
            title: l10n.language,
            subtitle: l10n.chooseLanguage,
            trailing: const ProfileLanguageDropdown(),
            onTap: null,
          ),
          const Divider(height: 1),
          _SettingsRow(
            icon: Icons.logout_rounded,
            iconColor: AppThemeTokens.error,
            title: l10n.logout,
            subtitle: l10n.logoutQuestion,
            trailing: isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right_rounded),
            onTap: isLoggingOut ? null : onLogout,
          ),
        ],
      ),
    );
  }
}

class ProfileLanguageDropdown extends StatelessWidget {
  const ProfileLanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();

    return PopupMenuButton<String>(
      tooltip: context.l10n.language,
      onSelected: (value) {
        localeCubit.changeLocale(value);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.system,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down_rounded),
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'system', child: Text(context.l10n.system)),
        PopupMenuItem(value: 'en', child: Text(context.l10n.english)),
        PopupMenuItem(value: 'ar', child: Text(context.l10n.arabic)),
        PopupMenuItem(value: 'fr', child: Text(context.l10n.french)),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 18,
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: iconColor.withValues(alpha: 0.10),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppThemeTokens.textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _ProfileBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ProfileBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: AppThemeTokens.textSecondary,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_rounded),
          label: l10n.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.trending_up_rounded),
          label: l10n.topRanking,
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
    );
  }
}
