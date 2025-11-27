import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/repositories/chat_repository.dart';

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

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final repo = ref.read(chatRepositoryProvider);
  return ChatController(repo);
});

class ChatController extends StateNotifier<ChatState> {
  final ChatRepository repo;

  ChatController(this.repo)
      : super(ChatState(messages: []));

  Future<void> sendUserMessage(String text) async {
    // Add user message
    final userMsg = ChatMessage(
      id: "${DateTime.now().microsecondsSinceEpoch}",
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
    );

    // Show typing indicator
    state = state.copyWith(isAiTyping: true, streamingText: "");

    // Get AI answer as a stream
    await for (final chunk in repo.sendMessageStream(state.messages, text)) {
      // chunk = partial text from LLM
      state = state.copyWith(streamingText: state.streamingText + chunk);
    }

    // Streaming finished → convert to chat message
    final aiMsg = ChatMessage(
      id: "${DateTime.now().microsecondsSinceEpoch}",
      text: state.streamingText,
      isUser: false,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      streamingText: "",
      isAiTyping: false,
    );
  }
}
