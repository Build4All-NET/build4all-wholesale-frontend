import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/retailer_ai_message.dart';
import '../../domain/repositories/retailer_product_ai_repository.dart';
import 'retailer_product_ai_state.dart';

class RetailerProductAiCubit extends Cubit<RetailerProductAiState> {
  final RetailerProductAiRepository repository;

  RetailerProductAiCubit({required this.repository})
    : super(RetailerProductAiState.initial());

  void openProductChat({
    required int productId,
    required String productName,
    required String welcomeMessage,
    String? imageUrl,
  }) {
    final assistantMessage = RetailerAiMessage(
      role: RetailerAiMessageRole.assistant,
      text: welcomeMessage,
      createdAt: DateTime.now(),
    );

    emit(
      RetailerProductAiState(
        productId: productId,
        productName: productName,
        imageUrl: imageUrl,
        messages: [assistantMessage],
        isSending: false,
      ),
    );
  }

  Future<void> sendMessage({
    required String text,
    required String timeoutMessage,
    required String emptyAnswerMessage,
    required String unavailableMessage,
  }) async {
    final cleanMessage = text.trim();
    final productId = state.productId;

    if (cleanMessage.isEmpty || productId == null || state.isSending) {
      return;
    }

    final userMessage = RetailerAiMessage(
      role: RetailerAiMessageRole.user,
      text: cleanMessage,
      createdAt: DateTime.now(),
    );

    final baseMessages = [...state.messages, userMessage];

    emit(
      state.copyWith(messages: baseMessages, isSending: true, clearError: true),
    );

    try {
      final answer = await repository
          .chatAboutProduct(productId: productId, message: cleanMessage)
          .timeout(const Duration(seconds: 55));

      final assistantMessage = RetailerAiMessage(
        role: RetailerAiMessageRole.assistant,
        text: answer.trim().isEmpty ? emptyAnswerMessage : answer.trim(),
        createdAt: DateTime.now(),
      );

      emit(
        state.copyWith(
          isSending: false,
          messages: [...baseMessages, assistantMessage],
        ),
      );
    } on TimeoutException {
      emit(
        state.copyWith(
          isSending: false,
          messages: [
            ...baseMessages,
            RetailerAiMessage(
              role: RetailerAiMessageRole.assistant,
              text: timeoutMessage,
              createdAt: DateTime.now(),
            ),
          ],
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();
      final visibleMessage = message.isEmpty ? unavailableMessage : message;

      emit(
        state.copyWith(
          isSending: false,
          messages: [
            ...baseMessages,
            RetailerAiMessage(
              role: RetailerAiMessageRole.assistant,
              text: visibleMessage,
              createdAt: DateTime.now(),
            ),
          ],
          errorMessage: visibleMessage,
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
