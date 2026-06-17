import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../domain/entities/supplier_order_entity.dart';
import '../models/supplier_order_model.dart';

class SupplierOrderApiService {
  final ApiClient apiClient;

  SupplierOrderApiService(this.apiClient);

  Future<List<SupplierOrderModel>> getOrders() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierOrders);

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => SupplierOrderModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<List<SupplierOrderModel>> getOrdersByStatus({
    required SupplierOrderStatus status,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.supplierOrdersByStatus(_statusToJson(status)),
      );

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => SupplierOrderModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<SupplierOrderModel> getOrderDetails({
    required int orderId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.supplierOrderById(orderId.toString()),
      );

      return SupplierOrderModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<SupplierOrderModel> updateOrderStatus({
    required int orderId,
    required SupplierOrderStatus status,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierOrderStatus(orderId.toString()),
        data: {
          'status': _statusToJson(status),
        },
      );

      return SupplierOrderModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  String _statusToJson(SupplierOrderStatus status) {
    switch (status) {
      case SupplierOrderStatus.pendingPayment:
        return 'PENDING_PAYMENT';
      case SupplierOrderStatus.pending:
        return 'PENDING';
      case SupplierOrderStatus.accepted:
        return 'ACCEPTED';
      case SupplierOrderStatus.preparing:
        return 'PREPARING';
      case SupplierOrderStatus.shipped:
        return 'SHIPPED';
      case SupplierOrderStatus.delivered:
        return 'DELIVERED';
      case SupplierOrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return e.message ?? 'Supplier order request failed';
  }
}