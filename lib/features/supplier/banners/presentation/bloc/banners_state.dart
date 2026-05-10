import 'package:equatable/equatable.dart';

import '../../domain/entities/banner_entity.dart';

class BannersState extends Equatable {
  final bool loading;
  final bool saving;
  final bool deleting;
  final List<BannerEntity> banners;
  final String? errorMessage;
  final String? successMessage;

  const BannersState({
    this.loading = false,
    this.saving = false,
    this.deleting = false,
    this.banners = const [],
    this.errorMessage,
    this.successMessage,
  });

  BannersState copyWith({
    bool? loading,
    bool? saving,
    bool? deleting,
    List<BannerEntity>? banners,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BannersState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      deleting: deleting ?? this.deleting,
      banners: banners ?? this.banners,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        saving,
        deleting,
        banners,
        errorMessage,
        successMessage,
      ];
}