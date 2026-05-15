import '../entities/supplier_rfq_request_entity.dart';

class SupplierQuotationParams {
  final double unitPrice;
  final int availableQuantity;
  final DateTime? deliveryDate;
  final double shippingCost;
  final String? message;

  const SupplierQuotationParams({
    required this.unitPrice,
    required this.availableQuantity,
    this.deliveryDate,
    required this.shippingCost,
    this.message,
  });
}

abstract class SupplierRfqRepository {
  Future<List<SupplierRfqRequestEntity>> getOpenRfqs();
  Future<SupplierRfqRequestEntity> getRfqDetails(int rfqId);
  Future<void> submitQuotation({
    required int rfqId,
    required SupplierQuotationParams params,
  });
  Future<void> updateQuotation({
    required int quotationId,
    required SupplierQuotationParams params,
  });
  Future<void> withdrawQuotation(int quotationId);
}
