import 'package:equatable/equatable.dart';

import '../../../domain/entities/supplier_category_entity.dart';

abstract class SupplierCatalogEvent extends Equatable {
  const SupplierCatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadSupplierCatalog extends SupplierCatalogEvent {
  const LoadSupplierCatalog();
}

class RefreshSupplierCatalog extends SupplierCatalogEvent {
  const RefreshSupplierCatalog();
}

class CreateCatalogCategoryRequested extends SupplierCatalogEvent {
  final String name;

  const CreateCatalogCategoryRequested({
    required this.name,
  });

  @override
  List<Object?> get props => [name];
}

class UpdateCatalogCategoryRequested extends SupplierCatalogEvent {
  final String categoryId;
  final String name;

  const UpdateCatalogCategoryRequested({
    required this.categoryId,
    required this.name,
  });

  @override
  List<Object?> get props => [categoryId, name];
}

class UpdateCatalogCategoryStatusRequested extends SupplierCatalogEvent {
  final String categoryId;
  final SupplierCatalogStatus status;

  const UpdateCatalogCategoryStatusRequested({
    required this.categoryId,
    required this.status,
  });

  @override
  List<Object?> get props => [categoryId, status];
}

class DeleteCatalogCategoryRequested extends SupplierCatalogEvent {
  final String categoryId;

  const DeleteCatalogCategoryRequested({
    required this.categoryId,
  });

  @override
  List<Object?> get props => [categoryId];
}

class CreateCatalogSubCategoryRequested extends SupplierCatalogEvent {
  final String categoryId;
  final String name;

  const CreateCatalogSubCategoryRequested({
    required this.categoryId,
    required this.name,
  });

  @override
  List<Object?> get props => [categoryId, name];
}

class UpdateCatalogSubCategoryRequested extends SupplierCatalogEvent {
  final String subCategoryId;
  final String name;

  const UpdateCatalogSubCategoryRequested({
    required this.subCategoryId,
    required this.name,
  });

  @override
  List<Object?> get props => [subCategoryId, name];
}

class UpdateCatalogSubCategoryStatusRequested extends SupplierCatalogEvent {
  final String subCategoryId;
  final SupplierCatalogStatus status;

  const UpdateCatalogSubCategoryStatusRequested({
    required this.subCategoryId,
    required this.status,
  });

  @override
  List<Object?> get props => [subCategoryId, status];
}

class DeleteCatalogSubCategoryRequested extends SupplierCatalogEvent {
  final String subCategoryId;

  const DeleteCatalogSubCategoryRequested({
    required this.subCategoryId,
  });

  @override
  List<Object?> get props => [subCategoryId];
}
