import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../data/promotion_mock_store.dart';
import '../widgets/promotion_card.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  Future<void> _confirmDeletePromotion(String id, String title) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Promotion',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Are you sure you want to delete promotion "$title"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    PromotionMockStore.deletePromotion(id);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Promotion deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final promotions = PromotionMockStore.promotions;

    return Scaffold(
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
          'Promotions',
          style: TextStyle(
            color: primary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppThemeTokens.screenHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(primary: primary),
              const SizedBox(height: 20),

              const Text(
                'Promotion List',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppThemeTokens.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              if (promotions.isEmpty)
                _EmptyPromotionsCard(primary: primary)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: promotions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final promotion = promotions[index];

                    return PromotionCard(
                      promotion: promotion,
                      onEdit: () {
                        context.go(
                          '/supplier-promotions/edit',
                          extra: promotion,
                        );
                      },
                      onDelete: () {
                        _confirmDeletePromotion(
                          promotion.id,
                          promotion.title,
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 28),
            ],
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
              Icons.local_offer_outlined,
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
                  'Manage Promotions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'View, edit, and delete supplier promotional offers. Promotions are managed separately and prepared for future backend integration.',
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

class _EmptyPromotionsCard extends StatelessWidget {
  final Color primary;

  const _EmptyPromotionsCard({required this.primary});

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
              Icons.local_offer_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No promotions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Draft',
              style: TextStyle(
                color: Color(0xFFD97706),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create promotions from the supplier dashboard, then view them here.',
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