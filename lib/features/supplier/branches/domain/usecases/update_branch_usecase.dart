import '../entities/branch_entity.dart';
import '../repositories/branch_repository.dart';

class UpdateBranchUseCase {
  final BranchRepository repository;

  UpdateBranchUseCase(this.repository);

  Future<BranchEntity> call({
    required String branchId,
    required String name,
    required String city,
    required String address,
    required String phoneNumber,
    required BranchStatus status,
  }) {
    return repository.updateBranch(
      branchId: branchId,
      name: name,
      city: city,
      address: address,
      phoneNumber: phoneNumber,
      status: status,
    );
  }
}