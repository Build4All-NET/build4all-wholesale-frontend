import '../../domain/entities/retailer_order_entity.dart';
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
  Future<void> reorder({required int orderId}) {
    return apiService.reorder(orderId: orderId);
  }
}
