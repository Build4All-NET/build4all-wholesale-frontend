import 'package:equatable/equatable.dart';

import '../../../domain/entities/supplier_order_entity.dart';

abstract class SupplierOrderDetailsEvent extends Equatable {
  SupplierOrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class SupplierOrderDetailsStarted extends SupplierOrderDetailsEvent {
  final int orderId;
  final SupplierOrderEntity? initialOrder;

  SupplierOrderDetailsStarted({
    required this.orderId,
    this.initialOrder,
  });

  @override
  List<Object?> get props => [orderId, initialOrder];
}

class SupplierOrderDetailsStatusUpdateRequested
    extends SupplierOrderDetailsEvent {
  final SupplierOrderStatus status;

  SupplierOrderDetailsStatusUpdateRequested(this.status);

  @override
  List<Object?> get props => [status];
}

class SupplierOrderDetailsPaymentRefreshRequested
    extends SupplierOrderDetailsEvent {
  SupplierOrderDetailsPaymentRefreshRequested();
}

class SupplierOrderDetailsMarkCashPaidRequested
    extends SupplierOrderDetailsEvent {
  SupplierOrderDetailsMarkCashPaidRequested();
}
