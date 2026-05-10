import '../../domain/entities/shipping_method_entity.dart';
import '../../domain/repositories/shipping_method_repository.dart';
import '../models/shipping_method_model.dart';
import '../services/shipping_method_api_service.dart';

class ShippingMethodRepositoryImpl implements ShippingMethodRepository {
  final ShippingMethodApiService apiService;

  ShippingMethodRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<List<ShippingMethodEntity>> getShippingMethods() async {
    final models = await apiService.getShippingMethods();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ShippingMethodEntity> createShippingMethod(
    ShippingMethodEntity method,
  ) async {
    final model = ShippingMethodModel.fromEntity(method);
    final created = await apiService.createShippingMethod(model);
    return created.toEntity();
  }

  @override
  Future<ShippingMethodEntity> updateShippingMethod(
    ShippingMethodEntity method,
  ) async {
    final model = ShippingMethodModel.fromEntity(method);
    final updated = await apiService.updateShippingMethod(model);
    return updated.toEntity();
  }

  @override
  Future<void> deleteShippingMethod(String id) {
    return apiService.deleteShippingMethod(id);
  }
}