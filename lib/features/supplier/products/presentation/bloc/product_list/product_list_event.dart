import 'package:equatable/equatable.dart';

abstract class ProductListEvent extends Equatable {
  ProductListEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductListEvent {
  LoadProducts();
}

class SearchProducts extends ProductListEvent {
  final String query;

  SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteProductRequested extends ProductListEvent {
  final String productId;

  DeleteProductRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}