import 'package:equatable/equatable.dart';

import '../../../domain/entities/supplier_category_entity.dart';

abstract class SupplierCatalogEvent extends Equatable {
  SupplierCatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadSupplierCatalog extends SupplierCatalogEvent {
  LoadSupplierCatalog();
}

class RefreshSupplierCatalog extends SupplierCatalogEvent {
  RefreshSupplierCatalog();
}

class CreateCatalogCategoryRequested extends SupplierCatalogEvent {
  final String name;

  CreateCatalogCategoryRequested({
    required this.name,
  });

  @override
  List<Object?> get props => [name];
}

class UpdateCatalogCategoryRequested extends SupplierCatalogEvent {
  final String categoryId;
  final String name;

  UpdateCatalogCategoryRequested({
    required this.categoryId,
    required this.name,
  });

  @override
  List<Object?> get props => [categoryId, name];
}

class UpdateCatalogCategoryStatusRequested extends SupplierCatalogEvent {
  final String categoryId;
  final SupplierCatalogStatus status;

  UpdateCatalogCategoryStatusRequested({
    required this.categoryId,
    required this.status,
  });

  @override
  List<Object?> get props => [categoryId, status];
}

class DeleteCatalogCategoryRequested extends SupplierCatalogEvent {
  final String categoryId;

  DeleteCatalogCategoryRequested({
    required this.categoryId,
  });

  @override
  List<Object?> get props => [categoryId];
}

class CreateCatalogSubCategoryRequested extends SupplierCatalogEvent {
  final String categoryId;
  final String name;

  CreateCatalogSubCategoryRequested({
    required this.categoryId,
    required this.name,
  });

  @override
  List<Object?> get props => [categoryId, name];
}

class UpdateCatalogSubCategoryRequested extends SupplierCatalogEvent {
  final String subCategoryId;
  final String name;

  UpdateCatalogSubCategoryRequested({
    required this.subCategoryId,
    required this.name,
  });

  @override
  List<Object?> get props => [subCategoryId, name];
}

class UpdateCatalogSubCategoryStatusRequested extends SupplierCatalogEvent {
  final String subCategoryId;
  final SupplierCatalogStatus status;

  UpdateCatalogSubCategoryStatusRequested({
    required this.subCategoryId,
    required this.status,
  });

  @override
  List<Object?> get props => [subCategoryId, status];
}

class DeleteCatalogSubCategoryRequested extends SupplierCatalogEvent {
  final String subCategoryId;

  DeleteCatalogSubCategoryRequested({
    required this.subCategoryId,
  });

  @override
  List<Object?> get props => [subCategoryId];
}
