import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../bloc/supplier_profile_display_bloc.dart';
import '../bloc/supplier_profile_display_event.dart';
import '../bloc/supplier_profile_display_state.dart';
import '../widgets/supplier_profile_header_card.dart';
import '../widgets/supplier_profile_info_card.dart';

class SupplierProfileDisplayScreen extends StatelessWidget {
  SupplierProfileDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupplierProfileDisplayBloc>(
      create: (_) => sl<SupplierProfileDisplayBloc>()
        ..add(LoadSupplierProfileDisplayRequested()),
      child: _SupplierProfileDisplayView(),
    );
  }
}

class _SupplierProfileDisplayView extends StatelessWidget {
  _SupplierProfileDisplayView();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      drawer: SupplierAppDrawer(),
      appBar: AppBar(
        title: Text(
          context.l10n.supplierProfileTitle,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<SupplierProfileDisplayBloc, SupplierProfileDisplayState>(
            builder: (context, state) {
              return IconButton(
                tooltip: context.l10n.supplierProfileRefreshTooltip,
                onPressed: state.loading || state.refreshing
                    ? null
                    : () {
                        context.read<SupplierProfileDisplayBloc>().add(
                              RefreshSupplierProfileDisplayRequested(),
                            );
                      },
                icon: state.refreshing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SupplierProfileDisplayBloc, SupplierProfileDisplayState>(
        builder: (context, state) {
          if (state.loading && state.profile == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.errorMessage != null && state.profile == null) {
            return _ErrorView(
              message: state.errorMessage!,
              onRetry: () {
                context.read<SupplierProfileDisplayBloc>().add(
                      LoadSupplierProfileDisplayRequested(),
                    );
              },
            );
          }

          final profile = state.profile;

          if (profile == null) {
            return _ErrorView(
              message: context.l10n.supplierProfileNoData,
              onRetry: () {
                context.read<SupplierProfileDisplayBloc>().add(
                      LoadSupplierProfileDisplayRequested(),
                    );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SupplierProfileDisplayBloc>().add(
                    RefreshSupplierProfileDisplayRequested(),
                  );
            },
            child: ListView(
              padding: EdgeInsets.all(
                AppThemeTokens.screenHorizontalPadding,
              ),
              children: [
                SupplierProfileHeaderCard(profile: profile),
                SizedBox(height: 18),

                if (state.errorMessage != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 14),
                    padding: EdgeInsets.all(12),
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
                      style: TextStyle(
                        color: AppThemeTokens.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                Text(
                  context.l10n.supplierProfileInformation,
                  style: TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 12),

                SupplierProfileInfoCard(
                  icon: Icons.person_outline,
                  label: context.l10n.supplierFullNameLabel,
                  value: profile.fullName,
                ),
                SizedBox(height: 10),

                SupplierProfileInfoCard(
                  icon: Icons.alternate_email_outlined,
                  label: context.l10n.supplierUsernameLabel,
                  value: profile.username,
                ),
                SizedBox(height: 10),

                SupplierProfileInfoCard(
                  icon: Icons.email_outlined,
                  label: context.l10n.supplierEmailLabel,
                  value: profile.email,
                ),
                SizedBox(height: 10),

                SupplierProfileInfoCard(
                  icon: Icons.phone_outlined,
                  label: context.l10n.supplierPhoneNumberLabel,
                  value: profile.phoneNumber,
                ),
                SizedBox(height: 10),

                SupplierProfileInfoCard(
                  icon: Icons.verified_user_outlined,
                  label: context.l10n.supplierAccountTypeLabel,
                  value: _formatAccountType(context, profile.role),
                ),

                SizedBox(height: 28),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _formatAccountType(BuildContext context, String? role) {
    final value = role?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.toUpperCase() == 'OWNER') {
      return context.l10n.supplierOwnerLabel;
    }

    return value;
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppThemeTokens.screenHorizontalPadding),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppThemeTokens.surface,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
            border: Border.all(color: AppThemeTokens.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: AppThemeTokens.error,
                size: 44,
              ),
              SizedBox(height: 12),
              Text(
                context.l10n.supplierUnableToLoadProfile,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
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
                icon: Icon(Icons.refresh),
                label: Text(
                  context.l10n.supplierTryAgain,
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
