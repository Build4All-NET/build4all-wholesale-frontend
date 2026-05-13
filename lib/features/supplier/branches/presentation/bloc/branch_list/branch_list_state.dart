import 'package:equatable/equatable.dart';

import '../../../domain/entities/branch_entity.dart';

class BranchListState extends Equatable {
  final bool isLoading;
  final bool isDeleting;
  final List<BranchEntity> branches;
  final String? error;
  final String? successMessage;

  BranchListState({
    required this.isLoading,
    required this.isDeleting,
    required this.branches,
    this.error,
    this.successMessage,
  });

  factory BranchListState.initial() {
    return BranchListState(
      isLoading: false,
      isDeleting: false,
      branches: [],
    );
  }

  BranchListState copyWith({
    bool? isLoading,
    bool? isDeleting,
    List<BranchEntity>? branches,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return BranchListState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      branches: branches ?? this.branches,
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isDeleting,
        branches,
        error,
        successMessage,
      ];
}