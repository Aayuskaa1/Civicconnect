class ChatMessage {
  final String role; // user | assistant
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  bool get isUser => role == 'user';
}
