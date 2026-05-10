import '../entities/supplier_order_entity.dart';
import '../repositories/supplier_order_repository.dart';

class GetSupplierOrdersUseCase {
  final SupplierOrderRepository repository;

  const GetSupplierOrdersUseCase(this.repository);

  Future<List<SupplierOrderEntity>> call({
    String query = '',
    SupplierOrderStatus? status,
  }) {
    return repository.searchOrders(
      query: query,
      status: status,
    );
  }
}