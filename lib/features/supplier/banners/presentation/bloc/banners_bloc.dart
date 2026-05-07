import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_banner_usecase.dart';
import '../../domain/usecases/delete_banner_usecase.dart';
import '../../domain/usecases/get_banners_usecase.dart';
import '../../domain/usecases/update_banner_usecase.dart';
import 'banners_event.dart';
import 'banners_state.dart';

class BannersBloc extends Bloc<BannersEvent, BannersState> {
  final GetBannersUseCase getBannersUseCase;
  final CreateBannerUseCase createBannerUseCase;
  final UpdateBannerUseCase updateBannerUseCase;
  final DeleteBannerUseCase deleteBannerUseCase;

  BannersBloc({
    required this.getBannersUseCase,
    required this.createBannerUseCase,
    required this.updateBannerUseCase,
    required this.deleteBannerUseCase,
  }) : super(const BannersState()) {
    on<LoadBannersRequested>(_onLoadBannersRequested);
    on<CreateBannerRequested>(_onCreateBannerRequested);
    on<UpdateBannerRequested>(_onUpdateBannerRequested);
    on<DeleteBannerRequested>(_onDeleteBannerRequested);
    on<ClearBannerMessageRequested>(_onClearBannerMessageRequested);
  }

  Future<void> _onLoadBannersRequested(
    LoadBannersRequested event,
    Emitter<BannersState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final banners = await getBannersUseCase();

      emit(
        state.copyWith(
          loading: false,
          banners: banners,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateBannerRequested(
    CreateBannerRequested event,
    Emitter<BannersState> emit,
  ) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await createBannerUseCase(event.banner);

      emit(
        state.copyWith(
          saving: false,
          successMessage: 'Banner created successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateBannerRequested(
    UpdateBannerRequested event,
    Emitter<BannersState> emit,
  ) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await updateBannerUseCase(event.banner);

      emit(
        state.copyWith(
          saving: false,
          successMessage: 'Banner updated successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteBannerRequested(
    DeleteBannerRequested event,
    Emitter<BannersState> emit,
  ) async {
    emit(
      state.copyWith(
        deleting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await deleteBannerUseCase(event.bannerId);

      final updatedBanners = state.banners
          .where((banner) => banner.id != event.bannerId)
          .toList();

      emit(
        state.copyWith(
          deleting: false,
          banners: updatedBanners,
          successMessage: 'Banner deleted successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          deleting: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onClearBannerMessageRequested(
    ClearBannerMessageRequested event,
    Emitter<BannersState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }
}