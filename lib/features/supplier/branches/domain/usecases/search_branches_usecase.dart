import '../entities/branch_entity.dart';
import '../repositories/branch_repository.dart';

class SearchBranchesUseCase {
  final BranchRepository repository;

  SearchBranchesUseCase(this.repository);

  Future<List<BranchEntity>> call({
    required String query,
  }) {
    return repository.searchBranches(query: query);
  }
}