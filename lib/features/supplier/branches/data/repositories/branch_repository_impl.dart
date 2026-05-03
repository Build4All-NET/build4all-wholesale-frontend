import '../../domain/entities/branch_entity.dart';
import '../../domain/repositories/branch_repository.dart';
import '../services/branch_api_service.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchApiService apiService;

  BranchRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<List<BranchEntity>> getBranches() {
    return apiService.getBranches();
  }

  @override
  Future<List<BranchEntity>> searchBranches({
    required String query,
  }) {
    return apiService.searchBranches(query: query);
  }

  @override
  Future<BranchEntity> createBranch({
    required String name,
    required String city,
    required String address,
    required String phoneNumber,
    required BranchStatus status,
  }) {
    return apiService.createBranch(
      name: name,
      city: city,
      address: address,
      phoneNumber: phoneNumber,
      status: status,
    );
  }

  @override
  Future<BranchEntity> updateBranch({
    required String branchId,
    required String name,
    required String city,
    required String address,
    required String phoneNumber,
    required BranchStatus status,
  }) {
    return apiService.updateBranch(
      branchId: branchId,
      name: name,
      city: city,
      address: address,
      phoneNumber: phoneNumber,
      status: status,
    );
  }

  @override
  Future<void> deleteBranch({
    required String branchId,
  }) {
    return apiService.deleteBranch(branchId: branchId);
  }
}