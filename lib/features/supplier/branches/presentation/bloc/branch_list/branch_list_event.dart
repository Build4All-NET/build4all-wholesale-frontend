import 'package:equatable/equatable.dart';

abstract class BranchListEvent extends Equatable {
  BranchListEvent();

  @override
  List<Object?> get props => [];
}

class LoadBranches extends BranchListEvent {
  LoadBranches();
}

class SearchBranches extends BranchListEvent {
  final String query;

  SearchBranches(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteBranchRequested extends BranchListEvent {
  final String branchId;

  DeleteBranchRequested(this.branchId);

  @override
  List<Object?> get props => [branchId];
}