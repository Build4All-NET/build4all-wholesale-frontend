import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/retailer_ai_message.dart';
import '../cubit/retailer_product_ai_cubit.dart';
import '../cubit/retailer_product_ai_state.dart';

class RetailerProductAiChatSheet extends StatefulWidget {
  final int productId;
  final String productName;
  final String? imageUrl;

  const RetailerProductAiChatSheet({
    super.key,
    required this.productId,
    required this.productName,
    this.imageUrl,
  });

  @override
  State<RetailerProductAiChatSheet> createState() =>
      _RetailerProductAiChatSheetState();
}

class _RetailerProductAiChatSheetState
    extends State<RetailerProductAiChatSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<RetailerProductAiCubit>().openProductChat(
        productId: widget.productId,
        productName: widget.productName,
        imageUrl: widget.imageUrl,
        welcomeMessage: context.l10n.aiWelcomeMessage,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send(String text) {
    final clean = text.trim();

    if (clean.isEmpty) return;

    _controller.clear();

    context.read<RetailerProductAiCubit>().sendMessage(
      text: clean,
      timeoutMessage: context.l10n.aiTimeout,
      emptyAnswerMessage: context.l10n.aiEmptyAnswer,
      unavailableMessage: context.l10n.aiUnavailable,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardBottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardBottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: keyboardBottomInset > 0 ? 0.92 : 0.86,
        minChildSize: 0.58,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Material(
              color: AppThemeTokens.surface,
              child: Column(
                children: [
                  const _SheetHandle(),
                  _Header(title: widget.productName, imageUrl: widget.imageUrl),
                  const Divider(height: 1, color: AppThemeTokens.border),
                  Expanded(
                    child:
                        BlocBuilder<
                          RetailerProductAiCubit,
                          RetailerProductAiState
                        >(
                          builder: (context, state) {
                            return ListView.builder(
                              controller: scrollController,
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                              itemCount:
                                  state.messages.length +
                                  (state.isSending ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (state.isSending &&
                                    index == state.messages.length) {
                                  return const _TypingBubble();
                                }

                                final message = state.messages[index];
                                return _MessageBubble(message: message);
                              },
                            );
                          },
                        ),
                  ),
                  BlocBuilder<RetailerProductAiCubit, RetailerProductAiState>(
                    builder: (context, state) {
                      final hasUserMessage = state.messages.any(
                        (m) => m.isUser,
                      );

                      if (hasUserMessage || state.isSending) {
                        return const SizedBox.shrink();
                      }

                      return _SuggestedPrompts(onSelected: _send);
                    },
                  ),
                  _InputBar(
                    controller: _controller,
                    onSend: () => _send(_controller.text),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeTokens.surface,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Center(
        child: Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: AppThemeTokens.border,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? imageUrl;

  const _Header({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveImageUrl(imageUrl);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 10, 16),
      decoration: BoxDecoration(color: primary.withValues(alpha: 0.045)),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppThemeTokens.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppThemeTokens.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: resolvedUrl == null
                    ? Icon(Icons.inventory_2_outlined, color: primary, size: 28)
                    : Image.network(
                        resolvedUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            Icons.inventory_2_outlined,
                            color: primary,
                            size: 28,
                          );
                        },
                      ),
              ),
              PositionedDirectional(
                end: -4,
                bottom: -4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppThemeTokens.surface, width: 2),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.productAiAssistant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 17,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppThemeTokens.textSecondary,
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          ),
        ],
      ),
    );
  }

  String? _resolveImageUrl(String? rawUrl) {
    if (rawUrl == null) return null;

    final value = rawUrl.trim();

    if (value.isEmpty) return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/uploadsPublic/') || value.startsWith('/uploads/')) {
      return '${_backendRootUrl()}$value';
    }

    if (value.startsWith('uploadsPublic/') || value.startsWith('uploads/')) {
      return '${_backendRootUrl()}/$value';
    }

    return value;
  }

  String _backendRootUrl() {
    final projectApiBaseUrl = AppConfig.projectApiBaseUrl.trim();

    if (projectApiBaseUrl.endsWith('/api')) {
      return projectApiBaseUrl.substring(0, projectApiBaseUrl.length - 4);
    }

    return projectApiBaseUrl.replaceAll(RegExp(r'/+$'), '');
  }
}

class _SuggestedPrompts extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const _SuggestedPrompts({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      context.l10n.aiSuggestionFitStore,
      context.l10n.aiSuggestionOrderQuantity,
      context.l10n.aiSuggestionMoqStock,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      decoration: const BoxDecoration(
        color: AppThemeTokens.surface,
        border: Border(top: BorderSide(color: AppThemeTokens.border)),
      ),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final text = suggestions[index];

            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onSelected(text),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 240),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.22),
                  ),
                ),
                child: Center(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 48,
                  maxHeight: 118,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppThemeTokens.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppThemeTokens.border),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: context.l10n.askAboutThisProduct,
                    hintStyle: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            BlocBuilder<RetailerProductAiCubit, RetailerProductAiState>(
              builder: (context, state) {
                return SizedBox(
                  width: 48,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isSending ? null : onSend,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: primary,
                      disabledBackgroundColor: AppThemeTokens.border,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppThemeTokens.textSecondary,
                    ),
                    child: state.isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final RetailerAiMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final primary = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: isUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.80,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? primary : AppThemeTokens.background,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(18),
            topEnd: const Radius.circular(18),
            bottomStart: Radius.circular(isUser ? 18 : 5),
            bottomEnd: Radius.circular(isUser ? 5 : 18),
          ),
          border: isUser ? null : Border.all(color: AppThemeTokens.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isUser ? 0.03 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : AppThemeTokens.textPrimary,
            fontSize: 14,
            height: 1.38,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppThemeTokens.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.aiThinking,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
