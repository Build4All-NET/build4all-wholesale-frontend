import 'package:equatable/equatable.dart';

import '../../../domain/entities/supplier_order_entity.dart';

abstract class SupplierOrderDetailsEvent extends Equatable {
  const SupplierOrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class SupplierOrderDetailsStarted extends SupplierOrderDetailsEvent {
  final int orderId;
  final SupplierOrderEntity? initialOrder;

  const SupplierOrderDetailsStarted({
    required this.orderId,
    this.initialOrder,
  });

  @override
  List<Object?> get props => [orderId, initialOrder];
}

class SupplierOrderDetailsStatusUpdateRequested
    extends SupplierOrderDetailsEvent {
  final SupplierOrderStatus status;

  const SupplierOrderDetailsStatusUpdateRequested(this.status);

  @override
  List<Object?> get props => [status];
}