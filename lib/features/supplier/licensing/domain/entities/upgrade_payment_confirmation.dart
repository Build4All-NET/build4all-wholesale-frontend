import 'owner_app_access.dart';

/// Response returned by the backend after a successful upgrade payment is
/// confirmed.
class UpgradePaymentConfirmation {
  final OwnerAppAccess access;
  final String? paymentIntentId;
  final String? status; // e.g. PAID / PROCESSING / FAILED
  final double? amount;
  final String? currency;
  final String? paidAt;
  final String? receiptUrl;
  final String? invoiceId;

  const UpgradePaymentConfirmation({
    required this.access,
    required this.paymentIntentId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paidAt,
    required this.receiptUrl,
    required this.invoiceId,
  });

  bool get isPaid => (status ?? '').toUpperCase() == 'PAID';
}
