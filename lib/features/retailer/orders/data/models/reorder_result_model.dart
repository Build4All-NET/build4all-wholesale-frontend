import '../../domain/entities/skipped_reorder_item_entity.dart';

class ReorderResultModel {
  final List<SkippedReorderItemEntity> skippedItems;

  const ReorderResultModel({required this.skippedItems});

  factory ReorderResultModel.fromJson(Map<String, dynamic> json) {
    final rawSkipped = json['skippedItems'] as List<dynamic>? ?? [];

    return ReorderResultModel(
      skippedItems: rawSkipped
          .map(
            (item) => SkippedReorderItemEntity(
              productId: _toInt(
                (Map<String, dynamic>.from(item as Map))['productId'],
              ),
              productName:
                  (Map<String, dynamic>.from(item))['productName']
                          ?.toString() ??
                      '',
              reason:
                  (Map<String, dynamic>.from(item))['reason']?.toString() ??
                      '',
            ),
          )
          .toList(),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
