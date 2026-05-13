import 'package:equatable/equatable.dart';

import '../../../domain/entities/supplier_order_entity.dart';

abstract class SupplierOrdersEvent extends Equatable {
  SupplierOrdersEvent();

  @override
  List<Object?> get props => [];
}

class SupplierOrdersStarted extends SupplierOrdersEvent {
  SupplierOrdersStarted();
}

class SupplierOrdersRefreshed extends SupplierOrdersEvent {
  SupplierOrdersRefreshed();
}

class SupplierOrdersSearchChanged extends SupplierOrdersEvent {
  final String query;

  SupplierOrdersSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SupplierOrdersStatusFilterChanged extends SupplierOrdersEvent {
  final SupplierOrderStatus? status;

  SupplierOrdersStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class SupplierOrdersOrderUpdated extends SupplierOrdersEvent {
  final SupplierOrderEntity order;

  SupplierOrdersOrderUpdated(this.order);

  @override
  List<Object?> get props => [order];
}