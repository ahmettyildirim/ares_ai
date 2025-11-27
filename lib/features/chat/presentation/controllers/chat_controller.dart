import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_state.dart';

import '../../../memory/domain/entities/memory_item.dart';
import '../../../memory/domain/usecases/memory_extraction_service.dart';
import '../../../memory/domain/usecases/memory_repository.dart';
import '../../../memory/data/repositories/memory_providers.dart';

class ChatController extends StateNotifier<ChatState> {
  final ChatRepository repo;
  final MemoryExtractionService memoryExtractor;
  final MemoryRepository memoryRepo;

  ChatController({
    required this.repo,
    required this.memoryExtractor,
    required this.memoryRepo,
  }) : super(ChatState(messages: []));

  Future<void> sendUserMessage(String text) async {
    // 1) Kullanıcı mesajını ekle
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
    );

    // 2) Ares typing başlasın
    state = state.copyWith(
      isAiTyping: true,
      streamingText: "",
    );

    // 3) 🧠 Memory Extraction
    final extraction = await memoryExtractor.extract(text);

    if (extraction.shouldWrite && extraction.memory != null) {
      final newMemory = MemoryItem(
        id: const Uuid().v4(),
        content: extraction.memory!,
        createdAt: DateTime.now(),
        importance: 0.7,
      );
      await memoryRepo.addMemory(newMemory);
    }

    // 4) Streaming AI yanıtı
    String fullResponse = "";

    final stream = repo.sendMessageStream(
      state.messages,
      text,
    );

    await for (final token in stream) {
      fullResponse += token;

      // Streaming aşaması
      state = state.copyWith(
        streamingText: fullResponse,
      );
    }

    // 5) Streaming bitti → final mesaj
    final finalMsg = ChatMessage(
      id: const Uuid().v4(),
      text: fullResponse,
      isUser: false,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, finalMsg],
      streamingText: "",
      isAiTyping: false,
    );
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final repo = ref.read(chatRepositoryProvider);
  final extractor = ref.read(memoryExtractionServiceProvider);
  final memory = ref.read(memoryRepositoryProvider);

  return ChatController(
    repo: repo,
    memoryExtractor: extractor,
    memoryRepo: memory,
  );
});
