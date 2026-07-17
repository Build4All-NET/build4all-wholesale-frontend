import '../../domain/entities/retailer_order_entity.dart';
import '../../domain/entities/skipped_reorder_item_entity.dart';
import '../../domain/repositories/retailer_order_repository.dart';
import '../services/retailer_order_api_service.dart';

class RetailerOrderRepositoryImpl implements RetailerOrderRepository {
  final RetailerOrderApiService apiService;

  RetailerOrderRepositoryImpl({required this.apiService});

  @override
  Future<List<RetailerOrderEntity>> getOrders() {
    return apiService.getOrders();
  }

  @override
  Future<RetailerOrderEntity> getOrderDetails({required int orderId}) {
    return apiService.getOrderDetails(orderId: orderId);
  }

  @override
  Future<RetailerOrderEntity> cancelOrder({required int orderId}) {
    return apiService.cancelOrder(orderId: orderId);
  }

  @override
  Future<List<SkippedReorderItemEntity>> reorder({
    required int orderId,
    required String mode,
  }) async {
    final result = await apiService.reorder(orderId: orderId, mode: mode);
    return result.skippedItems;
  }
}
