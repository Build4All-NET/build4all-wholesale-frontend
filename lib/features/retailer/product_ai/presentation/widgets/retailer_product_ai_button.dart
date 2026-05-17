import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../injection_container.dart';
import '../cubit/retailer_product_ai_cubit.dart';
import 'retailer_product_ai_chat_sheet.dart';

class RetailerProductAiButton extends StatelessWidget {
  final int productId;
  final String productName;
  final String? imageUrl;
  final bool expanded;

  const RetailerProductAiButton({
    super.key,
    required this.productId,
    required this.productName,
    this.imageUrl,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton.icon(
      onPressed: () => _openAiSheet(context),
      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
      label: Text(
        context.l10n.askAi,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );

    if (expanded) {
      return SizedBox(width: double.infinity, height: 38, child: button);
    }

    return SizedBox(height: 36, child: button);
  }

  void _openAiSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider(
          create: (_) => sl<RetailerProductAiCubit>(),
          child: RetailerProductAiChatSheet(
            productId: productId,
            productName: productName,
            imageUrl: imageUrl,
          ),
        );
      },
    );
  }
}
