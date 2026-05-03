import '../domain/entities/branch_entity.dart';
import '../domain/entities/branch_inventory_item_entity.dart';

class BranchMockStore {
  BranchMockStore._();

  static final List<BranchEntity> branches = [
    const BranchEntity(
      id: '1',
      name: 'Beirut Warehouse',
      city: 'Beirut',
      address: 'Beirut, Lebanon - Main Wholesale Storage Area',
      phoneNumber: '+961 1 234 567',
      status: BranchStatus.active,
    ),
    const BranchEntity(
      id: '2',
      name: 'Tripoli Branch',
      city: 'Tripoli',
      address: 'Tripoli, Lebanon - North Distribution Center',
      phoneNumber: '+961 6 456 789',
      status: BranchStatus.active,
    ),
    const BranchEntity(
      id: '3',
      name: 'Saida Branch',
      city: 'Saida',
      address: 'Saida, Lebanon - South Supply Branch',
      phoneNumber: '+961 7 321 654',
      status: BranchStatus.active,
    ),
  ];

  static final List<BranchInventoryItemEntity> inventoryItems = [
    const BranchInventoryItemEntity(
      id: 'inv_1',
      branchId: '1',
      productId: '1',
      productName: 'Coca-Cola 24-Pack',
      categoryName: 'Food & Beverages',
      stockQuantity: 500,
    ),
    const BranchInventoryItemEntity(
      id: 'inv_5',
      branchId: '2',
      productId: '1',
      productName: 'Coca-Cola 24-Pack',
      categoryName: 'Food & Beverages',
      stockQuantity: 350,
    ),
    const BranchInventoryItemEntity(
      id: 'inv_8',
      branchId: '3',
      productId: '1',
      productName: 'Coca-Cola 24-Pack',
      categoryName: 'Food & Beverages',
      stockQuantity: 260,
    ),
  ];

  static List<BranchEntity> searchBranches(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) return branches;

    return branches.where((branch) {
      return branch.name.toLowerCase().contains(normalizedQuery) ||
          branch.city.toLowerCase().contains(normalizedQuery) ||
          branch.address.toLowerCase().contains(normalizedQuery) ||
          branch.phoneNumber.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  static BranchEntity? getBranchById(String branchId) {
    try {
      return branches.firstWhere((branch) => branch.id == branchId);
    } catch (_) {
      return null;
    }
  }

  static List<BranchInventoryItemEntity> getInventoryByBranchId(
    String branchId,
  ) {
    return inventoryItems
        .where((item) => item.branchId == branchId)
        .toList();
  }

  static int getTotalProductsByBranchId(String branchId) {
    return getInventoryByBranchId(branchId).length;
  }

  static int getTotalStockByBranchId(String branchId) {
    return getInventoryByBranchId(branchId).fold<int>(
      0,
      (total, item) => total + item.stockQuantity,
    );
  }

  static int getTotalStockByProductId(String productId) {
    return inventoryItems
        .where((item) => item.productId == productId)
        .fold<int>(
          0,
          (total, item) => total + item.stockQuantity,
        );
  }

  static int getProductStockForBranch({
    required String branchId,
    required String productId,
  }) {
    try {
      final item = inventoryItems.firstWhere(
        (item) => item.branchId == branchId && item.productId == productId,
      );

      return item.stockQuantity;
    } catch (_) {
      return 0;
    }
  }

  static bool branchHasProduct({
    required String branchId,
    required String productId,
  }) {
    return inventoryItems.any(
      (item) => item.branchId == branchId && item.productId == productId,
    );
  }

  static void addBranch(BranchEntity branch) {
    branches.insert(0, branch);
  }

  static void updateBranch(BranchEntity branch) {
    final index = branches.indexWhere((item) => item.id == branch.id);

    if (index != -1) {
      branches[index] = branch;
    }
  }

  static void deleteBranch(String branchId) {
    branches.removeWhere((branch) => branch.id == branchId);
    inventoryItems.removeWhere((item) => item.branchId == branchId);
  }

  static void deleteInventoryForProduct(String productId) {
    inventoryItems.removeWhere((item) => item.productId == productId);
  }

  static void addInventoryItemToBranch({
    required String branchId,
    required String productId,
    required String productName,
    required String categoryName,
    required int stockQuantity,
  }) {
    final alreadyExists = branchHasProduct(
      branchId: branchId,
      productId: productId,
    );

    if (alreadyExists) return;

    final item = BranchInventoryItemEntity(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      productId: productId,
      productName: productName,
      categoryName: categoryName,
      stockQuantity: stockQuantity,
    );

    inventoryItems.insert(0, item);
  }

  static void updateInventoryStock({
    required String inventoryItemId,
    required int newStockQuantity,
  }) {
    final index = inventoryItems.indexWhere(
      (item) => item.id == inventoryItemId,
    );

    if (index == -1) return;

    final oldItem = inventoryItems[index];

    inventoryItems[index] = BranchInventoryItemEntity(
      id: oldItem.id,
      branchId: oldItem.branchId,
      productId: oldItem.productId,
      productName: oldItem.productName,
      categoryName: oldItem.categoryName,
      stockQuantity: newStockQuantity,
    );
  }

  static void setProductInventoryAllocations({
    required String productId,
    required String productName,
    required String categoryName,
    required Map<String, int> stockByBranchId,
  }) {
    for (final entry in stockByBranchId.entries) {
      final branchId = entry.key;
      final stockQuantity = entry.value;

      final index = inventoryItems.indexWhere(
        (item) => item.branchId == branchId && item.productId == productId,
      );

      if (stockQuantity <= 0) {
        if (index != -1) {
          inventoryItems.removeAt(index);
        }
        continue;
      }

      if (index != -1) {
        final oldItem = inventoryItems[index];

        inventoryItems[index] = BranchInventoryItemEntity(
          id: oldItem.id,
          branchId: branchId,
          productId: productId,
          productName: productName,
          categoryName: categoryName,
          stockQuantity: stockQuantity,
        );
      } else {
        inventoryItems.add(
          BranchInventoryItemEntity(
            id: 'inv_${DateTime.now().millisecondsSinceEpoch}_$branchId',
            branchId: branchId,
            productId: productId,
            productName: productName,
            categoryName: categoryName,
            stockQuantity: stockQuantity,
          ),
        );
      }
    }
  }
}