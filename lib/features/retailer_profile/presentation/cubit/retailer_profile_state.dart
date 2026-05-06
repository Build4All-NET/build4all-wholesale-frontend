import 'package:equatable/equatable.dart';

import '../../data/models/retailer_profile_model.dart';

class RetailerProfileState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final bool isLoggingOut;
  final bool isDeletingAccount;
  final bool logoutSuccess;
  final bool accountDeletedSuccess;
  final RetailerProfileCombinedModel? profile;
  final String? errorMessage;
  final String? successMessage;

  const RetailerProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoggingOut = false,
    this.isDeletingAccount = false,
    this.logoutSuccess = false,
    this.accountDeletedSuccess = false,
    this.profile,
    this.errorMessage,
    this.successMessage,
  });

  RetailerProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoggingOut,
    bool? isDeletingAccount,
    bool? logoutSuccess,
    bool? accountDeletedSuccess,
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
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      logoutSuccess: logoutSuccess ?? this.logoutSuccess,
      accountDeletedSuccess:
          accountDeletedSuccess ?? this.accountDeletedSuccess,
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
    isDeletingAccount,
    logoutSuccess,
    accountDeletedSuccess,
    profile,
    errorMessage,
    successMessage,
  ];
}
