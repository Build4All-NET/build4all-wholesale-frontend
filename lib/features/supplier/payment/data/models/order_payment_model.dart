import '../../domain/entities/order_payment_entity.dart';

class OrderPaymentModel extends OrderPaymentEntity {
  const OrderPaymentModel({
    required super.orderId,
    required super.orderTotal,
    required super.paidAmount,
    required super.remainingAmount,
    required super.fullyPaid,
    super.orderNumber,
    super.paymentMethod,
    super.paymentState,
    super.transactionId,
    super.providerCode,
    super.providerPaymentId,
    super.latestPaymentStatus,
    super.transactionCreatedAt,
    super.transactionUpdatedAt,
  });

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) {
    return OrderPaymentModel(
      orderId: _asInt(json['orderId'] ?? json['order_id']),
      orderNumber: _nullableString(json['orderNumber'] ?? json['order_number']),
      paymentMethod: _nullableString(json['paymentMethod'] ?? json['payment_method']),
      paymentState: _nullableString(json['paymentState'] ?? json['payment_state']),
      orderTotal: _asDouble(json['orderTotal'] ?? json['order_total']),
      paidAmount: _asDouble(json['paidAmount'] ?? json['paid_amount']),
      remainingAmount: _asDouble(
        json['remainingAmount'] ?? json['remaining_amount'],
      ),
      fullyPaid: _asBool(json['fullyPaid'] ?? json['fully_paid']),
      transactionId: _nullableInt(json['transactionId'] ?? json['transaction_id']),
      providerCode: _nullableString(json['providerCode'] ?? json['provider_code']),
      providerPaymentId: _nullableString(
        json['providerPaymentId'] ?? json['provider_payment_id'],
      ),
      latestPaymentStatus: _nullableString(
        json['latestPaymentStatus'] ?? json['latest_payment_status'],
      ),
      transactionCreatedAt: _nullableDateTime(
        json['transactionCreatedAt'] ?? json['transaction_created_at'],
      ),
      transactionUpdatedAt: _nullableDateTime(
        json['transactionUpdatedAt'] ?? json['transaction_updated_at'],
      ),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().trim().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return null;
    return text;
  }

  static DateTime? _nullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    final parsed = DateTime.tryParse(value.toString());
    return parsed?.toLocal();
  }
}
