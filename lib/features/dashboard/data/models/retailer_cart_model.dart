class RetailerCartModel {
  final List<RetailerCartItemModel> items;
  final int totalItems;
  final double subtotal;
  final double shippingEstimated;
  final double total;

  const RetailerCartModel({
    required this.items,
    required this.totalItems,
    required this.subtotal,
    required this.shippingEstimated,
    required this.total,
  });

  factory RetailerCartModel.fromJson(Map<String, dynamic> json) {
    return RetailerCartModel(
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (item) => RetailerCartItemModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      totalItems: _toInt(json['totalItems']),
      subtotal: _toDouble(json['subtotal']),
      shippingEstimated: _toDouble(json['shippingEstimated']),
      total: _toDouble(json['total']),
    );
  }
}

class RetailerCartItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? imageUrl;
  final double unitPrice;
  final String currency;
  final int moq;
  final String moqUnit;
  final int quantity;
  final double lineTotal;

  const RetailerCartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.unitPrice,
    required this.currency,
    required this.moq,
    required this.moqUnit,
    required this.quantity,
    required this.lineTotal,
  });

  factory RetailerCartItemModel.fromJson(Map<String, dynamic> json) {
    return RetailerCartItemModel(
      id: _toInt(json['id']),
      productId: _toInt(json['productId']),
      productName: json['productName']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      unitPrice: _toDouble(json['unitPrice']),
      currency: json['currency']?.toString() ?? r'$',
      moq: _toInt(json['moq'], fallback: 1),
      moqUnit: json['moqUnit']?.toString() ?? 'units',
      quantity: _toInt(json['quantity'], fallback: 1),
      lineTotal: _toDouble(json['lineTotal']),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}
