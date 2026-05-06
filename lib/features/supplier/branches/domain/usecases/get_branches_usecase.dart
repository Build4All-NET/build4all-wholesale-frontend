import '../entities/branch_entity.dart';
import '../repositories/branch_repository.dart';

class GetBranchesUseCase {
  final BranchRepository repository;

  GetBranchesUseCase(this.repository);

  Future<List<BranchEntity>> call() {
    return repository.getBranches();
  }
}