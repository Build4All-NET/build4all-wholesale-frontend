import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../utils/supplier_excel_import_i18n.dart';

class SupplierExcelInstructionCard extends StatefulWidget {
  const SupplierExcelInstructionCard({super.key});

  @override
  State<SupplierExcelInstructionCard> createState() =>
      _SupplierExcelInstructionCardState();
}

class _SupplierExcelInstructionCardState
    extends State<SupplierExcelInstructionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: primary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.upload_file_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppThemeTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.compactInstructionHint,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppThemeTokens.textSecondary,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: primary,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: primary.withOpacity(0.18)),
                  const SizedBox(height: 8),
                  Text(
                    l.subtitle,
                    style: TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Note(text: l.noteOne),
                  _Note(text: l.noteTwo),
                  _Note(text: l.noteThree),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;

  const _Note({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
