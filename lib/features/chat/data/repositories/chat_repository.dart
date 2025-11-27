import 'package:ares_ai/app/di/service_locator.dart';
import 'package:ares_ai/features/chat/domain/entities/chat_message.dart';
import 'package:ares_ai/features/memory/data/repositories/memory_providers.dart';
import 'package:ares_ai/features/memory/domain/usecases/memory_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRepository {
  final AiService aiService;
  final MemoryRepository memoryRepo;

  ChatRepository({
    required this.aiService,
    required this.memoryRepo,
  });

  Stream<String> sendMessageStream(
    List<ChatMessage> messages,
    String userMessage,
  ) async* {
    // 1) Long-term memory'yi çek
    final memories = await memoryRepo.getAllMemories();

    final formattedMemory = memories.isEmpty
        ? "No memory available."
        : memories.map((m) => "- ${m.content}").join("\n");

    // 2) Son X mesajı context olarak al
    final lastMessages = messages.length > 10
        ? messages.sublist(messages.length - 10)
        : messages;

    final contextBlock = lastMessages.map((m) {
      final role = m.isUser ? "user" : "assistant";
      return "$role: ${m.text}";
    }).join("\n");

    // 3) System prompt'u hazırla
    final systemPrompt = """
You are Ares AI, a personal AI assistant.

Here is the user's long-term memory:
$formattedMemory

Here is the recent conversation:
$contextBlock

Now answer the next user message based only on:
- the user's long-term memory
- the recent conversation
- your own AI capabilities

Be helpful, context-aware, and consistent.
""";

    // 4) AiService üzerinden OpenAI'ye git
    final stream = aiService.sendMessageStream(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
    );

    await for (final token in stream) {
      yield token;
    }
  }
}

// Riverpod provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final ai = ref.read(aiServiceProvider);
  final memory = ref.read(memoryRepositoryProvider);

  return ChatRepository(
    aiService: ai,
    memoryRepo: memory,
  );
});
