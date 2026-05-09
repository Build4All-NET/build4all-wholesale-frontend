import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

class CatalogCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const CatalogCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.canDelete,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isActive
        ? const Color(0xFF16A34A)
        : AppThemeTokens.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.12),
            child: Icon(
              isActive
                  ? Icons.check_circle_outline
                  : Icons.pause_circle_outline,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppThemeTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                    ),
                    if (!canDelete)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeTokens.inputFill,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppThemeTokens.border),
                        ),
                        child: const Text(
                          'Linked',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              }

              if (value == 'toggle') {
                onToggleStatus();
              }

              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        isActive
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                      ),
                      const SizedBox(width: 10),
                      Text(isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: AppThemeTokens.error,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: AppThemeTokens.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}