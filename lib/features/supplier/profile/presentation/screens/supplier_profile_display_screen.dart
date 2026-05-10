import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../bloc/supplier_profile_display_bloc.dart';
import '../bloc/supplier_profile_display_event.dart';
import '../bloc/supplier_profile_display_state.dart';
import '../widgets/supplier_profile_header_card.dart';
import '../widgets/supplier_profile_info_card.dart';

class SupplierProfileDisplayScreen extends StatelessWidget {
  const SupplierProfileDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupplierProfileDisplayBloc>(
      create: (_) => sl<SupplierProfileDisplayBloc>()
        ..add(const LoadSupplierProfileDisplayRequested()),
      child: const _SupplierProfileDisplayView(),
    );
  }
}

class _SupplierProfileDisplayView extends StatelessWidget {
  const _SupplierProfileDisplayView();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      drawer: const SupplierAppDrawer(),
      appBar: AppBar(
        title: const Text(
          'Supplier Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<SupplierProfileDisplayBloc, SupplierProfileDisplayState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'Refresh',
                onPressed: state.loading || state.refreshing
                    ? null
                    : () {
                        context.read<SupplierProfileDisplayBloc>().add(
                              const RefreshSupplierProfileDisplayRequested(),
                            );
                      },
                icon: state.refreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SupplierProfileDisplayBloc, SupplierProfileDisplayState>(
        builder: (context, state) {
          if (state.loading && state.profile == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.errorMessage != null && state.profile == null) {
            return _ErrorView(
              message: state.errorMessage!,
              onRetry: () {
                context.read<SupplierProfileDisplayBloc>().add(
                      const LoadSupplierProfileDisplayRequested(),
                    );
              },
            );
          }

          final profile = state.profile;

          if (profile == null) {
            return _ErrorView(
              message: 'No supplier profile data found',
              onRetry: () {
                context.read<SupplierProfileDisplayBloc>().add(
                      const LoadSupplierProfileDisplayRequested(),
                    );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SupplierProfileDisplayBloc>().add(
                    const RefreshSupplierProfileDisplayRequested(),
                  );
            },
            child: ListView(
              padding: const EdgeInsets.all(
                AppThemeTokens.screenHorizontalPadding,
              ),
              children: [
                SupplierProfileHeaderCard(profile: profile),
                const SizedBox(height: 18),

                if (state.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppThemeTokens.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusMedium,
                      ),
                      border: Border.all(
                        color: AppThemeTokens.error.withOpacity(0.22),
                      ),
                    ),
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: AppThemeTokens.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                const Text(
                  'Profile Information',
                  style: TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),

                SupplierProfileInfoCard(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: profile.fullName,
                ),
                const SizedBox(height: 10),

                SupplierProfileInfoCard(
                  icon: Icons.alternate_email_outlined,
                  label: 'Username',
                  value: profile.username,
                ),
                const SizedBox(height: 10),

                SupplierProfileInfoCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: profile.email,
                ),
                const SizedBox(height: 10),

                SupplierProfileInfoCard(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: profile.phoneNumber,
                ),
                const SizedBox(height: 10),

                SupplierProfileInfoCard(
                  icon: Icons.verified_user_outlined,
                  label: 'Account Type',
                  value: _formatAccountType(profile.role),
                ),

                const SizedBox(height: 28),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _formatAccountType(String? role) {
    final value = role?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.toUpperCase() == 'OWNER') {
      return 'Owner';
    }

    return value;
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppThemeTokens.screenHorizontalPadding),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppThemeTokens.surface,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
            border: Border.all(color: AppThemeTokens.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppThemeTokens.error,
                size: 44,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load supplier profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusMedium,
                    ),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}