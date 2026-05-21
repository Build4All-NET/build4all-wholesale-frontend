import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/retailer_order_entity.dart';
import '../utils/retailer_order_formatters.dart';
import '../utils/retailer_order_i18n.dart';

class RetailerOrderTimeline extends StatelessWidget {
  final RetailerOrderEntity order;

  const RetailerOrderTimeline({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _steps(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;

          return _TimelineStepTile(
            step: step,
            isLast: isLast,
          );
        }),
      ),
    );
  }

  List<_TimelineStep> _steps(BuildContext context) {
    final i18n = RetailerOrderI18n(context);
    final statusIndex = _currentStepIndex(order.status);
    final isCancelled = order.status == RetailerOrderStatus.cancelled;

    final labels = [
      i18n.orderPlaced,
      i18n.accepted,
      i18n.preparing,
      i18n.shipped,
      i18n.delivered,
    ];

    final icons = [
      Icons.receipt_long_rounded,
      Icons.verified_rounded,
      Icons.inventory_2_rounded,
      Icons.local_shipping_rounded,
      Icons.location_on_rounded,
    ];

    return List.generate(labels.length, (index) {
      final completed = !isCancelled && index < statusIndex;
      final inProgress = !isCancelled && index == statusIndex;

      return _TimelineStep(
        label: labels[index],
        subtitle: index == 0
            ? formatRetailerOrderDateTime(context, order.createdAt)
            : completed || inProgress
                ? formatRetailerOrderDateTime(context, order.updatedAt)
                : i18n.waiting,
        icon: icons[index],
        completed: completed,
        inProgress: inProgress,
      );
    });
  }

  int _currentStepIndex(RetailerOrderStatus status) {
    switch (status) {
      case RetailerOrderStatus.pending:
        return 0;
      case RetailerOrderStatus.accepted:
        return 1;
      case RetailerOrderStatus.preparing:
        return 2;
      case RetailerOrderStatus.shipped:
        return 3;
      case RetailerOrderStatus.delivered:
        return 4;
      case RetailerOrderStatus.cancelled:
        return 0;
    }
  }
}

class _TimelineStep {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool completed;
  final bool inProgress;

  const _TimelineStep({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.completed,
    required this.inProgress,
  });
}

class _TimelineStepTile extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineStepTile({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final activeColor = step.completed || step.inProgress
        ? primary
        : AppThemeTokens.textSecondary.withValues(alpha: 0.45);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.completed ? Icons.check_rounded : step.icon,
                  size: 19,
                  color: activeColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: step.completed
                        ? primary.withValues(alpha: 0.45)
                        : AppThemeTokens.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.label,
                          style: TextStyle(
                            color: step.completed || step.inProgress
                                ? AppThemeTokens.textPrimary
                                : AppThemeTokens.textSecondary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (step.inProgress)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            RetailerOrderI18n(context).inProgress,
                            style: TextStyle(
                              color: primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.subtitle,
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
