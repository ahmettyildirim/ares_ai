import 'package:ares_ai/features/chat/presentation/controllers/chat_sessions_controller.dart';
import 'package:ares_ai/features/chat/presentation/controllers/chat_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../data/repositories/chat_repository.dart';

import '../../../memory/data/repositories/memory_providers.dart';
import '../../../memory/domain/entities/memory_item.dart';
import '../../../memory/domain/usecases/memory_extraction_service.dart';
import '../../../memory/domain/usecases/memory_repository.dart';

import '../../domain/entities/chat_session.dart';
import '../controllers/active_chat_session_controller.dart';

class ChatController extends StateNotifier<ChatState> {
  final ChatRepository repo;
  final MemoryRepository memoryRepo;
  final MemoryExtractionService memoryExtractor;
  final ActiveChatSessionController activeSession;
  final Ref ref;

  ChatController({
    required this.repo,
    required this.memoryRepo,
    required this.memoryExtractor,
    required this.activeSession,
    required this.ref,
  }) : super(ChatState(messages: []));

  /// Bir mesajın memory’de işaretli olup olmadığını UI’de güncelle
  void toggleMessageMemory(String messageId, bool saved) {
    final updated = state.messages.map((m) {
      if (m.id == messageId) {
        return m.copyWith(isSavedToMemory: saved);
      }
      return m;
    }).toList();

    state = state.copyWith(messages: updated);
    _persistToSession();
  }

  /// Memory’deki content’lere göre mesajların isSavedToMemory flag’lerini senkronize et
  void syncMessagesWithMemory(List<MemoryItem> currentMemory) {
    final memoryContents = currentMemory.map((m) => m.content).toSet();

    final updatedMessages = state.messages.map((msg) {
      final shouldBeSaved = memoryContents.contains(msg.text);
      return msg.copyWith(isSavedToMemory: shouldBeSaved);
    }).toList();

    state = state.copyWith(messages: updatedMessages);
    _persistToSession();
  }

  ChatSession? get _session => activeSession.state;

  /// Eğer aktif session yoksa yeni bir tane oluştur.
  Future<void> ensureSession() async {
    if (_session == null) {
      await activeSession.createNew();
      // Yeni session oluşturunca state.messages’ı da sıfırla
      state = ChatState(messages: []);
    }
  }

  /// Belirli bir session’ı yükleyip state’e yansıt.
  Future<void> loadSession(String sessionId) async {
    await activeSession.loadSession(sessionId);
    final s = _session;
    if (s != null) {
      state = ChatState(messages: s.messages);
      // Hafızayla senkronizasyon istersen buraya memory sync de ekleyebilirsin.
      final allMemory = await memoryRepo.getAllMemories();
      syncMessagesWithMemory(allMemory);
    }
  }

  /// Mevcut state.messages’ı aktif ChatSession’a persist et.
  Future<void> _persistToSession() async {
    final s = _session;
    if (s == null) return;
    final updated = s.copyWith(
      messages: state.messages,
      updatedAt: DateTime.now(),
    );
    await activeSession.updateSession(updated);
    ref.read(chatSessionsProvider.notifier).refresh();
  }

  Future<void> sendUserMessage(String text) async {
    await ensureSession();

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    // Kullanıcı mesajını ekle + typing başlasın
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isAiTyping: true,
      streamingText: "",
    );
    await _persistToSession();

    // 🧠 Memory extraction
    final extraction = await memoryExtractor.extract(text);
    if (extraction.shouldWrite && extraction.memory != null) {
      final newMemory = MemoryItem(
        id: const Uuid().v4(),
        content: extraction.memory!,
        createdAt: DateTime.now(),
        importance: 0.7,
      );
      await memoryRepo.addMemory(newMemory);

      // Hafıza değiştiyse, mesajların isSavedToMemory flag’lerini güncelle
      final allMemory = await memoryRepo.getAllMemories();
      syncMessagesWithMemory(allMemory);
    }

    // 🤖 Streaming AI cevabı
    String fullResponse = "";

    final stream = repo.sendMessageStream(
      state.messages,
      text,
    );

    await for (final token in stream) {
      fullResponse += token;

      // streamingText güncelle
      state = state.copyWith(
        streamingText: fullResponse,
      );
    }

    // Streaming bitti → final AI mesajı
    final aiMsg = ChatMessage(
      id: const Uuid().v4(),
      text: state.streamingText,
      isUser: false,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      streamingText: "",
      isAiTyping: false,
    );

    await _persistToSession();

    if (state.messages.length == 2) {
      _generateTitleForSession(text);
    }
  }
  Future<void> _generateTitleForSession(String firstMessage) async {
  final title = await repo.generateSessionTitle(firstMessage);

  final s = _session;
  if (s == null) return;

  final updated = s.copyWith(
    title: title,
    updatedAt: DateTime.now(),
  );

  await activeSession.updateSession(updated);
  ref.read(chatSessionsProvider.notifier).refresh();
}

}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final repo = ref.read(chatRepositoryProvider);
  final memory = ref.read(memoryRepositoryProvider);
  final extractor = ref.read(memoryExtractionServiceProvider);
  final activeSession = ref.read(activeChatSessionProvider.notifier);

  return ChatController(
    repo: repo,
    memoryRepo: memory,
    memoryExtractor: extractor,
    activeSession: activeSession,
    ref: ref, 
  );
});
