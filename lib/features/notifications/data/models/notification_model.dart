import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.typeCode,
    required super.title,
    required super.body,
    required super.read,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _toInt(json['id']),
      typeCode: (json['typeCode'] ?? '').toString(),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      // Backend serializes the boolean field `read` as `read`.
      read: json['read'] == true || json['isRead'] == true,
      createdAt: _toDate(json['createdAt']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
