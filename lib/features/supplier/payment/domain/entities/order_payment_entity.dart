class OrderPaymentEntity {
  final int orderId;
  final String? orderNumber;
  final String? paymentMethod;
  final String? paymentState;
  final double orderTotal;
  final double paidAmount;
  final double remainingAmount;
  final bool fullyPaid;
  final int? transactionId;
  final String? providerCode;
  final String? providerPaymentId;
  final String? latestPaymentStatus;
  final DateTime? transactionCreatedAt;
  final DateTime? transactionUpdatedAt;

  const OrderPaymentEntity({
    required this.orderId,
    required this.orderTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.fullyPaid,
    this.orderNumber,
    this.paymentMethod,
    this.paymentState,
    this.transactionId,
    this.providerCode,
    this.providerPaymentId,
    this.latestPaymentStatus,
    this.transactionCreatedAt,
    this.transactionUpdatedAt,
  });

  bool get isCash {
    final method = paymentMethod?.trim().toUpperCase();
    final provider = providerCode?.trim().toUpperCase();
    return method == 'CASH' ||
        method == 'CASH_ON_DELIVERY' ||
        method == 'COD' ||
        provider == 'CASH';
  }

  bool get isOfflinePending {
    return latestPaymentStatus?.trim().toUpperCase() == 'OFFLINE_PENDING';
  }

  bool get canMarkCashAsPaid {
    return isCash && isOfflinePending && !fullyPaid;
  }
}
