import '../repositories/branch_repository.dart';

class DeleteBranchUseCase {
  final BranchRepository repository;

  DeleteBranchUseCase(this.repository);

  Future<void> call({
    required String branchId,
  }) {
    return repository.deleteBranch(branchId: branchId);
  }
}