import 'package:equatable/equatable.dart';

import '../../domain/entities/retailer_ai_message.dart';

class RetailerProductAiState extends Equatable {
  final int? productId;
  final String productName;
  final String? imageUrl;
  final List<RetailerAiMessage> messages;
  final bool isSending;
  final String? errorMessage;

  const RetailerProductAiState({
    this.productId,
    this.productName = '',
    this.imageUrl,
    this.messages = const [],
    this.isSending = false,
    this.errorMessage,
  });

  factory RetailerProductAiState.initial() {
    return const RetailerProductAiState();
  }

  RetailerProductAiState copyWith({
    int? productId,
    String? productName,
    String? imageUrl,
    bool clearImageUrl = false,
    List<RetailerAiMessage>? messages,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RetailerProductAiState(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    imageUrl,
    messages,
    isSending,
    errorMessage,
  ];
}
