import '../entities/supplier_order_entity.dart';
import '../repositories/supplier_order_repository.dart';

class UpdateSupplierOrderStatusUseCase {
  final SupplierOrderRepository repository;

  const UpdateSupplierOrderStatusUseCase(this.repository);

  Future<SupplierOrderEntity> call({
    required int orderId,
    required SupplierOrderStatus status,
  }) {
    return repository.updateOrderStatus(
      orderId: orderId,
      status: status,
    );
  }
}