import 'package:ares_ai/app/di/service_locator.dart';
import 'package:ares_ai/features/memory/domain/usecases/memory_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/build_prompt.dart';
import '../../../memory/domain/entities/memory_item.dart';
import '../../../memory/data/repositories/memory_providers.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final ai = ref.read(aiServiceProvider);
  final memoryRepo = ref.read(memoryRepositoryProvider);
  return ChatRepository(ai: ai, memoryRepository: memoryRepo);
});

class ChatRepository {
  final AiService ai;
  final MemoryRepository memoryRepository;

  ChatRepository({
    required this.ai,
    required this.memoryRepository,
  });

  /// NON-stream (hala kullanıyorsan)
  Future<ChatMessage> sendMessage(
      List<ChatMessage> history, String userText) async {
    final memories =
        await memoryRepository.getRelevantMemories(userText, limit: 8);

    final prompt = PromptBuilder.build(history, userText, memories: memories);

    final responseText = await ai.sendMessage(prompt);

    return ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: responseText,
      isUser: false,
      createdAt: DateTime.now(),
    );
  }

  /// STREAM version – Sprint 6 için kullandığımız
  Stream<String> sendMessageStream(
      List<ChatMessage> history, String userText) async* {
    final memories =
        await memoryRepository.getRelevantMemories(userText, limit: 8);

    final prompt = PromptBuilder.build(history, userText, memories: memories);

    final stream = ai.sendMessageStream(prompt);

    await for (final token in stream) {
      yield token;
    }

    // Burada istersen ileride kullanılan memory’lerin lastUsedAt’ini güncelleriz.
  }
}
