import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/supplier_retailer_entity.dart';

enum _ContactMethod { email, whatsapp, call }

/// Small "how do I reach this shop" popup for [retailer].
///
/// One tap per option and the phone's own app takes over -- mail, WhatsApp or
/// the dialer. Only shown for a retailer with at least one contact detail, so
/// every row in here does something.
Future<void> showSupplierRetailerContactDialog(
  BuildContext context,
  SupplierRetailerEntity retailer,
) async {
  final l10n = context.l10n;

  // The dialog only reports the choice; launching happens against the calling
  // screen's context, which is still around once the popup has closed.
  final choice = await showDialog<_ContactMethod>(
    context: context,
    builder: (_) => _SupplierRetailerContactDialog(retailer: retailer),
  );

  if (choice == null || !context.mounted) return;

  try {
    final opened = await _launch(choice, retailer, l10n);
    if (!context.mounted || opened) return;

    AppToast.error(context, l10n.supplierStatisticsContactFailed);
  } catch (_) {
    if (!context.mounted) return;
    AppToast.error(context, l10n.supplierStatisticsContactFailed);
  }
}

Future<bool> _launch(
  _ContactMethod method,
  SupplierRetailerEntity retailer,
  AppLocalizations l10n,
) {
  switch (method) {
    case _ContactMethod.email:
      return launchUrl(
        Uri(scheme: 'mailto', path: retailer.email.trim()),
        mode: LaunchMode.externalApplication,
      );
    case _ContactMethod.whatsapp:
      // wa.me wants the number without "+" or separators.
      final digits = retailer.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final text = Uri.encodeComponent(
        l10n.supplierStatisticsWhatsAppMessage(retailer.displayName),
      );
      return launchUrl(
        Uri.parse('https://wa.me/$digits?text=$text'),
        mode: LaunchMode.externalApplication,
      );
    case _ContactMethod.call:
      return launchUrl(
        Uri(scheme: 'tel', path: retailer.phoneNumber.trim()),
        mode: LaunchMode.externalApplication,
      );
  }
}

class _SupplierRetailerContactDialog extends StatelessWidget {
  final SupplierRetailerEntity retailer;

  const _SupplierRetailerContactDialog({required this.retailer});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final phone = retailer.phoneNumber.trim();
    final email = retailer.email.trim();

    void choose(_ContactMethod method) => Navigator.of(context).pop(method);

    return AlertDialog(
      backgroundColor: AppThemeTokens.surface,
      title: Text(
        l10n.supplierStatisticsContactTitle(retailer.displayName),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppThemeTokens.textPrimary,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (email.isNotEmpty)
            _ContactOption(
              icon: Icons.mail_outline_rounded,
              label: l10n.supplierStatisticsContactEmail,
              value: email,
              onTap: () => choose(_ContactMethod.email),
            ),
          if (phone.isNotEmpty) ...[
            _ContactOption(
              icon: Icons.chat_outlined,
              label: l10n.supplierStatisticsContactWhatsApp,
              value: phone,
              onTap: () => choose(_ContactMethod.whatsapp),
            ),
            _ContactOption(
              icon: Icons.call_outlined,
              label: l10n.supplierStatisticsContactCall,
              value: phone,
              onTap: () => choose(_ContactMethod.call),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.supplierStatisticsClose),
        ),
      ],
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: AppThemeTokens.primary, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppThemeTokens.textPrimary,
        ),
      ),
      subtitle: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: AppThemeTokens.textSecondary,
        ),
      ),
    );
  }
}
