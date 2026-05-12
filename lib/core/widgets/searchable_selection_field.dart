import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';

class SearchableSelectionField<T> extends FormField<T> {
  SearchableSelectionField({
    super.key,
    required String label,
    required String hintText,
    required String searchHintText,
    required List<T> items,
    required String Function(T item) itemLabel,
    required ValueChanged<T> onSelected,
    T? value,
    bool enabled = true,
    bool isLoading = false,
    String? emptyText,
    String? Function(T?)? validator,
  }) : super(
          initialValue: value,
          validator: validator,
          builder: (field) {
            final selectedValue = field.value;
            final hasSelection = selectedValue != null;

            Future<void> openPicker() async {
              if (!enabled || isLoading) return;

              final selected = await showModalBottomSheet<T>(
                context: field.context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return _SearchableSelectionSheet<T>(
                    title: label.replaceAll('*', '').trim(),
                    searchHintText: searchHintText,
                    items: items,
                    itemLabel: itemLabel,
                    selectedValue: selectedValue,
                    emptyText: emptyText ?? 'No results found',
                  );
                },
              );

              if (selected != null) {
                field.didChange(selected);
                onSelected(selected);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppThemeTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
                    onTap: openPicker,
                    child: InputDecorator(
                      isEmpty: !hasSelection,
                      decoration: InputDecoration(
                        hintText: isLoading ? 'Loading...' : hintText,
                        errorText: field.errorText,
                        filled: true,
                        fillColor: enabled
                            ? AppThemeTokens.inputFill
                            : AppThemeTokens.inputFill.withValues(alpha: 0.55),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppThemeTokens.radiusSmall,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppThemeTokens.radiusSmall,
                          ),
                          borderSide: const BorderSide(
                            color: AppThemeTokens.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppThemeTokens.radiusSmall,
                          ),
                          borderSide: const BorderSide(
                            color: AppThemeTokens.error,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              hasSelection ? itemLabel(selectedValue) : hintText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: hasSelection
                                    ? AppThemeTokens.textPrimary
                                    : AppThemeTokens.textSecondary,
                                fontWeight: hasSelection
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isLoading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.search_rounded,
                              color: enabled
                                  ? AppThemeTokens.textSecondary
                                  : AppThemeTokens.textSecondary
                                      .withValues(alpha: 0.55),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
}

class _SearchableSelectionSheet<T> extends StatefulWidget {
  final String title;
  final String searchHintText;
  final List<T> items;
  final String Function(T item) itemLabel;
  final T? selectedValue;
  final String emptyText;

  const _SearchableSelectionSheet({
    required this.title,
    required this.searchHintText,
    required this.items,
    required this.itemLabel,
    required this.selectedValue,
    required this.emptyText,
  });

  @override
  State<_SearchableSelectionSheet<T>> createState() =>
      _SearchableSelectionSheetState<T>();
}

class _SearchableSelectionSheetState<T>
    extends State<_SearchableSelectionSheet<T>> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return widget.items;

    return widget.items
        .where(
          (item) => widget.itemLabel(item).toLowerCase().contains(
                normalizedQuery,
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: AppThemeTokens.surface,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
            border: Border.all(color: AppThemeTokens.border),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: widget.searchHintText,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppThemeTokens.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusSmall,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            widget.emptyText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppThemeTokens.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: AppThemeTokens.border,
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final selected = item == widget.selectedValue;

                          return ListTile(
                            title: Text(
                              widget.itemLabel(item),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: selected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
