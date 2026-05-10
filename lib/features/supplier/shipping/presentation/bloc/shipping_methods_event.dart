import 'package:equatable/equatable.dart';

import '../../domain/entities/shipping_method_entity.dart';

abstract class ShippingMethodsEvent extends Equatable {
  const ShippingMethodsEvent();

  @override
  List<Object?> get props => [];
}

class LoadShippingMethodsRequested extends ShippingMethodsEvent {
  const LoadShippingMethodsRequested();
}

class CreateShippingMethodRequested extends ShippingMethodsEvent {
  final ShippingMethodEntity method;

  const CreateShippingMethodRequested(this.method);

  @override
  List<Object?> get props => [method];
}

class UpdateShippingMethodRequested extends ShippingMethodsEvent {
  final ShippingMethodEntity method;

  const UpdateShippingMethodRequested(this.method);

  @override
  List<Object?> get props => [method];
}

class DeleteShippingMethodRequested extends ShippingMethodsEvent {
  final String id;

  const DeleteShippingMethodRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearShippingMethodMessageRequested extends ShippingMethodsEvent {
  const ClearShippingMethodMessageRequested();
}
