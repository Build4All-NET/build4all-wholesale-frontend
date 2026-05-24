class RetailerProductAiChatResponseModel {
  final int productId;
  final String productName;
  final String answer;

  const RetailerProductAiChatResponseModel({
    required this.productId,
    required this.productName,
    required this.answer,
  });

  factory RetailerProductAiChatResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RetailerProductAiChatResponseModel(
      productId: _toInt(json['productId']),
      productName: json['productName']?.toString() ?? '',
      answer:
          json['answer']?.toString() ??
          json['message']?.toString() ??
          json['content']?.toString() ??
          '',
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
