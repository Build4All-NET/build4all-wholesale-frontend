import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/banner_entity.dart';
import '../bloc/banners_bloc.dart';
import '../bloc/banners_event.dart';
import '../bloc/banners_state.dart';
import '../widgets/banner_card.dart';

class BannersScreen extends StatelessWidget {
  const BannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BannersBloc>(
      create: (_) => sl<BannersBloc>()..add(const LoadBannersRequested()),
      child: const _BannersView(),
    );
  }
}

class _BannersView extends StatefulWidget {
  const _BannersView();

  @override
  State<_BannersView> createState() => _BannersViewState();
}

class _BannersViewState extends State<_BannersView> {
  Future<void> _refresh(BuildContext context) async {
    context.read<BannersBloc>().add(const LoadBannersRequested());
  }

  Future<void> _confirmDeleteBanner(
    BuildContext context,
    BannerEntity banner,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Banner',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Are you sure you want to delete "${banner.title}"?',
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

    context.read<BannersBloc>().add(
          DeleteBannerRequested(banner.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<BannersBloc, BannersState>(
      listener: (context, state) {
        final message = state.successMessage ?? state.errorMessage;

        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          context.read<BannersBloc>().add(
                const ClearBannerMessageRequested(),
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
            'Home Banners',
            style: TextStyle(
              color: primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Create Banner',
              onPressed: () => context.go('/supplier-banners/create'),
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
          child: BlocBuilder<BannersBloc, BannersState>(
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
                      const Text(
                        'Banner List',
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
                      else if (state.banners.isEmpty)
                        _EmptyBannersCard(primary: primary)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.banners.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            final banner = state.banners[index];

                            return BannerCard(
                              banner: banner,
                              onEdit: () {
                                context.go(
                                  '/supplier-banners/edit',
                                  extra: banner,
                                );
                              },
                              onDelete: () {
                                _confirmDeleteBanner(context, banner);
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
              Icons.image_outlined,
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
                  'Manage Home Banners',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'View, create, edit, and delete supplier banners saved in the backend database. These banners will later appear for retailers on the home screen.',
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
            'Could not load banners',
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

class _EmptyBannersCard extends StatelessWidget {
  final Color primary;

  const _EmptyBannersCard({required this.primary});

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
              Icons.image_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No banners yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create banners from the supplier dashboard quick action or tap the plus icon above.',
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