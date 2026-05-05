import '../domain/entities/branch_entity.dart';
import '../domain/entities/branch_inventory_item_entity.dart';

class BranchMockStore {
  BranchMockStore._();

  static final List<BranchEntity> branches = [
    const BranchEntity(
      id: '1',
      name: 'Beirut Main Warehouse',
      city: 'Beirut',
      address: 'Hamra Main Street, Beirut',
      phoneNumber: '81911967',
      status: BranchStatus.active,
    ),
    const BranchEntity(
      id: '2',
      name: 'Tripoli Branch',
      city: 'Tripoli',
      address: 'Tripoli, Lebanon',
      phoneNumber: '70123456',
      status: BranchStatus.active,
    ),
    const BranchEntity(
      id: '3',
      name: 'Saida Branch',
      city: 'Saida',
      address: 'Saida, Lebanon',
      phoneNumber: '76123456',
      status: BranchStatus.inactive,
    ),
  ];

  static final List<BranchInventoryItemEntity> inventoryItems = [];

  static List<BranchInventoryItemEntity> getInventoryByBranchId(
    String branchId,
  ) {
    return inventoryItems
        .where((inventoryItem) => inventoryItem.branchId == branchId)
        .toList();
  }

  static List<BranchInventoryItemEntity> getInventoryByProductId(
    String productId,
  ) {
    return inventoryItems
        .where((inventoryItem) => inventoryItem.productId == productId)
        .toList();
  }

  static void addInventoryItem(BranchInventoryItemEntity item) {
    final existingIndex = inventoryItems.indexWhere(
      (inventoryItem) =>
          inventoryItem.branchId == item.branchId &&
          inventoryItem.productId == item.productId,
    );

    if (existingIndex == -1) {
      inventoryItems.add(item);
    } else {
      inventoryItems[existingIndex] = item;
    }
  }

  static void updateInventoryItem(BranchInventoryItemEntity item) {
    final index = inventoryItems.indexWhere(
      (inventoryItem) => inventoryItem.id == item.id,
    );

    if (index != -1) {
      inventoryItems[index] = item;
    }
  }

  static void updateStock({
    required String inventoryItemId,
    required int stockQuantity,
  }) {
    final index = inventoryItems.indexWhere(
      (inventoryItem) => inventoryItem.id == inventoryItemId,
    );

    if (index == -1) return;

    final oldItem = inventoryItems[index];

    inventoryItems[index] = BranchInventoryItemEntity(
      id: oldItem.id,
      branchId: oldItem.branchId,
      branchName: oldItem.branchName,
      branchCity: oldItem.branchCity,
      productId: oldItem.productId,
      productName: oldItem.productName,
      categoryId: oldItem.categoryId,
      categoryName: oldItem.categoryName,
      subCategoryId: oldItem.subCategoryId,
      subCategoryName: oldItem.subCategoryName,
      stockQuantity: stockQuantity,
    );
  }

  static void deleteInventoryItem(String inventoryItemId) {
    inventoryItems.removeWhere(
      (inventoryItem) => inventoryItem.id == inventoryItemId,
    );
  }

  static void deleteInventoryForProduct(String productId) {
    inventoryItems.removeWhere(
      (inventoryItem) => inventoryItem.productId == productId,
    );
  }

  static void deleteInventoryForBranch(String branchId) {
    inventoryItems.removeWhere(
      (inventoryItem) => inventoryItem.branchId == branchId,
    );
  }

  static int getTotalProductsByBranchId(String branchId) {
    return inventoryItems
        .where((inventoryItem) => inventoryItem.branchId == branchId)
        .length;
  }

  static int getTotalStockByBranchId(String branchId) {
    return inventoryItems
        .where((inventoryItem) => inventoryItem.branchId == branchId)
        .fold<int>(
          0,
          (sum, inventoryItem) => sum + inventoryItem.stockQuantity,
        );
  }

  static int getTotalStockByProductId(String productId) {
    return inventoryItems
        .where((inventoryItem) => inventoryItem.productId == productId)
        .fold<int>(
          0,
          (sum, inventoryItem) => sum + inventoryItem.stockQuantity,
        );
  }

  static BranchEntity? getBranchById(String branchId) {
    try {
      return branches.firstWhere((branch) => branch.id == branchId);
    } catch (_) {
      return null;
    }
  }
}