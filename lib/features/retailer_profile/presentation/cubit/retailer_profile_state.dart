import 'package:equatable/equatable.dart';

import '../../data/models/retailer_profile_model.dart';

class RetailerProfileState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final bool isLoggingOut;
  final bool logoutSuccess;
  final RetailerProfileCombinedModel? profile;
  final String? errorMessage;
  final String? successMessage;

  const RetailerProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoggingOut = false,
    this.logoutSuccess = false,
    this.profile,
    this.errorMessage,
    this.successMessage,
  });

  RetailerProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoggingOut,
    bool? logoutSuccess,
    RetailerProfileCombinedModel? profile,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return RetailerProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      logoutSuccess: logoutSuccess ?? this.logoutSuccess,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    isLoggingOut,
    logoutSuccess,
    profile,
    errorMessage,
    successMessage,
  ];
}
