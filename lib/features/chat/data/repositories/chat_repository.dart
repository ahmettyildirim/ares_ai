import 'package:ares_ai/app/di/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/build_prompt.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final ai = ref.read(aiServiceProvider);
  return ChatRepository(ai);
});

class ChatRepository {
  final AiService ai;

  ChatRepository(this.ai);

  Future<ChatMessage> sendMessage(
      List<ChatMessage> history, String userText) async {
    final prompt = PromptBuilder.build(history, userText);

    // Fake AI (Sprint 5'te gerçek OpenAI/Anthropic geliyor)
    final response = await ai.sendMessage(prompt);

    return ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: response,
      isUser: false,
      createdAt: DateTime.now(),
    );
  }
  Stream<String> sendMessageStream(
    List<ChatMessage> history, String userText) async* {
  final prompt = PromptBuilder.build(history, userText);

  final stream = await ai.sendMessageStream(prompt);

  await for (final token in stream) {
    yield token;
  }
}

}
