import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../domain/entities/supplier_retailer_entity.dart';
import '../../domain/entities/supplier_statistics_entity.dart';
import '../../domain/usecases/get_supplier_statistics_usecase.dart';

enum SupplierStatisticsStatus { initial, loading, loaded, error }

class SupplierStatisticsState {
  final SupplierStatisticsStatus status;
  final SupplierStatisticsEntity statistics;
  final String query;
  final String? error;

  /// True while a pull-to-refresh runs over content already on screen, so the
  /// list stays visible instead of flashing back to a spinner.
  final bool refreshing;

  const SupplierStatisticsState({
    required this.status,
    required this.statistics,
    required this.query,
    required this.error,
    required this.refreshing,
  });

  const SupplierStatisticsState.initial()
      : status = SupplierStatisticsStatus.initial,
        statistics = SupplierStatisticsEntity.empty,
        query = '',
        error = null,
        refreshing = false;

  List<SupplierRetailerEntity> get visibleRetailers =>
      statistics.search(query);

  SupplierStatisticsState copyWith({
    SupplierStatisticsStatus? status,
    SupplierStatisticsEntity? statistics,
    String? query,
    String? error,
    bool clearError = false,
    bool? refreshing,
  }) {
    return SupplierStatisticsState(
      status: status ?? this.status,
      statistics: statistics ?? this.statistics,
      query: query ?? this.query,
      error: clearError ? null : (error ?? this.error),
      refreshing: refreshing ?? this.refreshing,
    );
  }
}

class SupplierStatisticsCubit extends Cubit<SupplierStatisticsState> {
  final GetSupplierStatisticsUseCase getStatistics;

  SupplierStatisticsCubit({required this.getStatistics})
      : super(const SupplierStatisticsState.initial());

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      emit(state.copyWith(refreshing: true, clearError: true));
    } else {
      emit(state.copyWith(
        status: SupplierStatisticsStatus.loading,
        clearError: true,
      ));
    }

    try {
      final statistics = await getStatistics();

      emit(state.copyWith(
        status: SupplierStatisticsStatus.loaded,
        statistics: statistics,
        refreshing: false,
        clearError: true,
      ));
    } catch (e) {
      // A failed refresh keeps the rows the supplier is already looking at; a
      // failed first load has nothing to fall back on, so it shows the error.
      final keepContent =
          refresh && state.status == SupplierStatisticsStatus.loaded;

      emit(state.copyWith(
        status: keepContent
            ? SupplierStatisticsStatus.loaded
            : SupplierStatisticsStatus.error,
        error: e is AppException ? e.message : e.toString(),
        refreshing: false,
      ));
    }
  }

  void search(String query) {
    if (query == state.query) return;
    emit(state.copyWith(query: query));
  }

  void clearError() {
    if (state.error == null) return;
    emit(state.copyWith(clearError: true));
  }
}
