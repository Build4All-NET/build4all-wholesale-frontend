import '../entities/skipped_reorder_item_entity.dart';
import '../repositories/retailer_order_repository.dart';

class ReorderRetailerOrderUseCase {
  final RetailerOrderRepository repository;

  ReorderRetailerOrderUseCase(this.repository);

  Future<List<SkippedReorderItemEntity>> call({
    required int orderId,
    required String mode,
  }) {
    return repository.reorder(orderId: orderId, mode: mode);
  }
}
