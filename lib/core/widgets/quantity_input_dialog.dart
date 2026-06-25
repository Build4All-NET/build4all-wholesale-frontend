import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/l10n_extension.dart';
import '../theme/app_theme_tokens.dart';

/// Lets the retailer type an exact quantity instead of tapping +/- one at a
/// time. Returns the chosen quantity, or null if cancelled. The result is
/// always clamped to at least [minQuantity] (the product MOQ).
Future<int?> showQuantityInputDialog(
  BuildContext context, {
  required int initialQuantity,
  required int minQuantity,
  String? unitLabel,
}) {
  final safeMin = minQuantity <= 0 ? 1 : minQuantity;

  return showDialog<int>(
    context: context,
    builder: (dialogContext) => _QuantityInputDialog(
      initialQuantity: initialQuantity < safeMin ? safeMin : initialQuantity,
      minQuantity: safeMin,
      unitLabel: unitLabel,
    ),
  );
}

class _QuantityInputDialog extends StatefulWidget {
  final int initialQuantity;
  final int minQuantity;
  final String? unitLabel;

  const _QuantityInputDialog({
    required this.initialQuantity,
    required this.minQuantity,
    this.unitLabel,
  });

  @override
  State<_QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<_QuantityInputDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialQuantity.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final parsed = int.tryParse(_controller.text.trim());

    if (parsed == null || parsed <= 0) {
      setState(() => _errorText = l10n.quantity);
      return;
    }

    if (parsed < widget.minQuantity) {
      setState(
        () => _errorText = '${l10n.moq}: ${widget.minQuantity}',
      );
      return;
    }

    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final minHint = widget.unitLabel == null
        ? '${l10n.moq}: ${widget.minQuantity}'
        : '${l10n.moq}: ${widget.minQuantity} ${widget.unitLabel}';

    return AlertDialog(
      title: Text(
        l10n.quantity,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: l10n.quantity,
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            minHint,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
