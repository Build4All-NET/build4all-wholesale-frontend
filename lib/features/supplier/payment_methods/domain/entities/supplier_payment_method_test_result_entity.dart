class SupplierPaymentMethodTestResultEntity {
  final String methodName;
  final bool success;
  final String message;

  const SupplierPaymentMethodTestResultEntity({
    required this.methodName,
    required this.success,
    required this.message,
  });
}