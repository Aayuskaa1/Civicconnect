import 'package:civic_connect/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isUser reflects chat role', () {
    final userMessage = ChatMessage(
      role: 'user',
      content: 'Hello',
      createdAt: DateTime(2026, 3, 1),
    );
    final assistantMessage = ChatMessage(
      role: 'assistant',
      content: 'Hi there',
      createdAt: DateTime(2026, 3, 1),
    );

    expect(userMessage.isUser, isTrue);
    expect(assistantMessage.isUser, isFalse);
  });
}
