import '../../domain/entities/chat_message.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isAiTyping;
  final String streamingText;

  ChatState({
    required this.messages,
    this.isAiTyping = false,
    this.streamingText = "",
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isAiTyping,
    String? streamingText,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      streamingText: streamingText ?? this.streamingText,
    );
  }
}
