import 'package:equatable/equatable.dart';

abstract class BranchListEvent extends Equatable {
  const BranchListEvent();

  @override
  List<Object?> get props => [];
}

class LoadBranches extends BranchListEvent {
  const LoadBranches();
}

class SearchBranches extends BranchListEvent {
  final String query;

  const SearchBranches(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteBranchRequested extends BranchListEvent {
  final String branchId;

  const DeleteBranchRequested(this.branchId);

  @override
  List<Object?> get props => [branchId];
}