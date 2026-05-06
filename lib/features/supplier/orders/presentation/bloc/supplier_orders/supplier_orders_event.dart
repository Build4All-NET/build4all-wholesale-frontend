import 'package:equatable/equatable.dart';

import '../../../domain/entities/supplier_order_entity.dart';

abstract class SupplierOrdersEvent extends Equatable {
  const SupplierOrdersEvent();

  @override
  List<Object?> get props => [];
}

class SupplierOrdersStarted extends SupplierOrdersEvent {
  const SupplierOrdersStarted();
}

class SupplierOrdersRefreshed extends SupplierOrdersEvent {
  const SupplierOrdersRefreshed();
}

class SupplierOrdersSearchChanged extends SupplierOrdersEvent {
  final String query;

  const SupplierOrdersSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SupplierOrdersStatusFilterChanged extends SupplierOrdersEvent {
  final SupplierOrderStatus? status;

  const SupplierOrdersStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class SupplierOrdersOrderUpdated extends SupplierOrdersEvent {
  final SupplierOrderEntity order;

  const SupplierOrdersOrderUpdated(this.order);

  @override
  List<Object?> get props => [order];
}