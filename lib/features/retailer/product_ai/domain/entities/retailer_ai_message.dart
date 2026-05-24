enum RetailerAiMessageRole { user, assistant }

class RetailerAiMessage {
  final RetailerAiMessageRole role;
  final String text;
  final DateTime createdAt;

  const RetailerAiMessage({
    required this.role,
    required this.text,
    required this.createdAt,
  });

  bool get isUser => role == RetailerAiMessageRole.user;
}
