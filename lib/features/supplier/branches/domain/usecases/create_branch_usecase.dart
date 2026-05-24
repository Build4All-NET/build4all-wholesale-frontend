import '../entities/branch_entity.dart';
import '../repositories/branch_repository.dart';

class CreateBranchUseCase {
  final BranchRepository repository;

  CreateBranchUseCase(this.repository);

  Future<BranchEntity> call({
    required String name,
    required String countryCode,
    int? regionId,
    required String city,
    required String address,
    required String phoneNumber,
    required BranchStatus status,
  }) {
    return repository.createBranch(
      name: name,
      countryCode: countryCode,
      regionId: regionId,
      city: city,
      address: address,
      phoneNumber: phoneNumber,
      status: status,
    );
  }
}
