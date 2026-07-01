/// A single in-app notification as shown to the user.
///
/// Mirrors the backend `NotificationView` exposed by the shared notify library
/// at `/api/notify/notifications`.
class NotificationEntity {
  final int id;
  final String typeCode;
  final String? title;
  final String? body;
  final bool read;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.typeCode,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? read}) {
    return NotificationEntity(
      id: id,
      typeCode: typeCode,
      title: title,
      body: body,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
