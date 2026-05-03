import '../entities/branch_entity.dart';

abstract class BranchRepository {
  Future<List<BranchEntity>> getBranches();

  Future<List<BranchEntity>> searchBranches({
    required String query,
  });

  Future<BranchEntity> createBranch({
    required String name,
    required String city,
    required String address,
    required String phoneNumber,
    required BranchStatus status,
  });

  Future<BranchEntity> updateBranch({
    required String branchId,
    required String name,
    required String city,
    required String address,
    required String phoneNumber,
    required BranchStatus status,
  });

  Future<void> deleteBranch({
    required String branchId,
  });
}