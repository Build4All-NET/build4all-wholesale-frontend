import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../network/api_config.dart';

class HostedCheckoutFlow {
  static Uri buildWholesalePaymentUri(String redirectUrl) {
    final value = redirectUrl.trim();
    final parsed = Uri.tryParse(value);

    if (parsed != null && parsed.hasScheme) {
      return parsed;
    }

    final base = Uri.parse(ApiConfig.projectApiBaseUrl);
    final origin = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
    );

    final path = value.startsWith('/') ? value : '/$value';
    return Uri.parse('${origin.toString()}$path');
  }

  static Future<bool> openAndAskForCompletion({
    required BuildContext context,
    required String redirectUrl,
    required String title,
    required String message,
    required String paidButtonLabel,
    required String cancelButtonLabel,
  }) async {
    final uri = buildWholesalePaymentUri(redirectUrl);

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      throw Exception('Could not open hosted checkout page.');
    }

    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelButtonLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(paidButtonLabel),
            ),
          ],
        );
      },
    );

    return result == true;
  }
}
