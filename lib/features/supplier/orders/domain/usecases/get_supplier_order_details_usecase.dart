import '../entities/supplier_order_entity.dart';
import '../repositories/supplier_order_repository.dart';

class GetSupplierOrderDetailsUseCase {
  final SupplierOrderRepository repository;

  GetSupplierOrderDetailsUseCase(this.repository);

  Future<SupplierOrderEntity> call({
    required int orderId,
  }) {
    return repository.getOrderDetails(orderId: orderId);
  }
}