import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/locale_cubit.dart';
import '../../../../injection_container.dart';
import '../cubit/retailer_profile_cubit.dart';
import '../cubit/retailer_profile_state.dart';

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
          AppToast.error(context, state.errorMessage!);
          context.read<RetailerProfileCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        final l10n = context.l10n;

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
            currentIndex: 3,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/retailer-dashboard');
                  break;
                case 1:
                  context.push('/retailer-orders');
                  break;
                case 2:
                  context.push('/retailer-rfqs');
                  break;
                case 3:
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
                  l10n.logout,
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
                  l10n.logoutQuestion,
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
                          l10n.logout,
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
    );
  }
}
