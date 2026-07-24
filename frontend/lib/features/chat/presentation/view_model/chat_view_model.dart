import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/features/chat/domain/entities/chat_message.dart';
import 'package:civic_connect/features/chat/domain/local_chat_assistant.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isSending;

  const ChatState({
    required this.messages,
    this.isSending = false,
  });

  factory ChatState.initial() => ChatState(
        messages: [
          ChatMessage(
            role: 'assistant',
            content:
                'Hello. I\'m the CivicConnect assistant. Ask about tabs, reporting, categories, statuses, photos, or your profile — I\'ll give a complete answer.',
            createdAt: DateTime.now(),
          ),
        ],
      );

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

final chatViewModelProvider =
    NotifierProvider<ChatViewModel, ChatState>(ChatViewModel.new);

class ChatViewModel extends Notifier<ChatState> {
  @override
  ChatState build() => ChatState.initial();

  Future<void> send(String rawMessage) async {
    final message = rawMessage.trim();
    if (message.isEmpty || state.isSending) return;

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          role: 'user',
          content: message,
          createdAt: DateTime.now(),
        ),
      ],
      isSending: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 220));

    // On-device only — never calls the network, so connection errors cannot appear.
    String reply;
    try {
      reply = LocalChatAssistant.reply(message);
      if (reply.trim().isEmpty) {
        reply = LocalChatAssistant.overview;
      }
    } catch (_) {
      reply = LocalChatAssistant.overview;
    }

    state = state.copyWith(
      isSending: false,
      messages: [
        ...state.messages,
        ChatMessage(
          role: 'assistant',
          content: reply,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  void clearChat() {
    state = ChatState.initial();
  }
}
