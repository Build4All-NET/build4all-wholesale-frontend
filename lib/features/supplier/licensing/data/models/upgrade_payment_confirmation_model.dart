import '../../domain/entities/upgrade_payment_confirmation.dart';
import 'owner_app_access_response.dart';

class UpgradePaymentConfirmationModel {
  final OwnerAppAccessResponse access;
  final String? paymentIntentId;
  final String? status;
  final double? amount;
  final String? currency;
  final String? paidAt;
  final String? receiptUrl;
  final String? invoiceId;

  const UpgradePaymentConfirmationModel({
    required this.access,
    required this.paymentIntentId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paidAt,
    required this.receiptUrl,
    required this.invoiceId,
  });

  static double? _dNullable(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory UpgradePaymentConfirmationModel.fromJson(Map<String, dynamic> j) {
    final accessRaw = j['access'];
    final access = accessRaw is Map
        ? OwnerAppAccessResponse.fromJson(Map<String, dynamic>.from(accessRaw))
        : OwnerAppAccessResponse.fromJson(j);

    final paymentRaw = j['payment'];
    final payment = paymentRaw is Map
        ? Map<String, dynamic>.from(paymentRaw)
        : <String, dynamic>{};

    return UpgradePaymentConfirmationModel(
      access: access,
      paymentIntentId:
          (payment['paymentIntentId'] ?? j['paymentIntentId'] ?? payment['id'])
              ?.toString(),
      status: (payment['status'] ?? j['paymentStatus'])?.toString(),
      amount: _dNullable(payment['amount'] ?? j['amount']),
      currency: (payment['currency'] ?? j['currency'])?.toString(),
      paidAt: (payment['paidAt'] ?? j['paidAt'])?.toString(),
      receiptUrl: (payment['receiptUrl'] ?? j['receiptUrl'])?.toString(),
      invoiceId: (payment['invoiceId'] ?? j['invoiceId'])?.toString(),
    );
  }

  UpgradePaymentConfirmation toEntity() => UpgradePaymentConfirmation(
        access: access,
        paymentIntentId: paymentIntentId,
        status: status,
        amount: amount,
        currency: currency,
        paidAt: paidAt,
        receiptUrl: receiptUrl,
        invoiceId: invoiceId,
      );
}
