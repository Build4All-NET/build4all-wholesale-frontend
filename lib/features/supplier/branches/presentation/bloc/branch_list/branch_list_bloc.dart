import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/delete_branch_usecase.dart';
import '../../../domain/usecases/get_branches_usecase.dart';
import '../../../domain/usecases/search_branches_usecase.dart';
import 'branch_list_event.dart';
import 'branch_list_state.dart';

class BranchListBloc extends Bloc<BranchListEvent, BranchListState> {
  final GetBranchesUseCase getBranchesUseCase;
  final SearchBranchesUseCase searchBranchesUseCase;
  final DeleteBranchUseCase deleteBranchUseCase;

  BranchListBloc({
    required this.getBranchesUseCase,
    required this.searchBranchesUseCase,
    required this.deleteBranchUseCase,
  }) : super(BranchListState.initial()) {
    on<LoadBranches>(_onLoadBranches);
    on<SearchBranches>(_onSearchBranches);
    on<DeleteBranchRequested>(_onDeleteBranchRequested);
  }

  Future<void> _onLoadBranches(
    LoadBranches event,
    Emitter<BranchListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));

    try {
      final branches = await getBranchesUseCase();

      emit(
        state.copyWith(
          isLoading: false,
          branches: branches,
          clearMessages: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onSearchBranches(
    SearchBranches event,
    Emitter<BranchListState> emit,
  ) async {
    try {
      final branches = event.query.trim().isEmpty
          ? await getBranchesUseCase()
          : await searchBranchesUseCase(query: event.query);

      emit(
        state.copyWith(
          branches: branches,
          clearMessages: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onDeleteBranchRequested(
    DeleteBranchRequested event,
    Emitter<BranchListState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, clearMessages: true));

    try {
      await deleteBranchUseCase(branchId: event.branchId);

      final updatedBranches = state.branches
          .where((branch) => branch.id != event.branchId)
          .toList();

      emit(
        state.copyWith(
          isDeleting: false,
          branches: updatedBranches,
          successMessage: 'branchDeleted',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}