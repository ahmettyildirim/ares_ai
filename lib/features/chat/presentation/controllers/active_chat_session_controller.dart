import 'package:ares_ai/features/chat/data/repositories/chat_session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_session.dart';

class ActiveChatSessionController
    extends StateNotifier<ChatSession?> {
  final ChatSessionRepository repo;

  ActiveChatSessionController(this.repo) : super(null);

  Future<void> loadSession(String sessionId) async {
    final session = await repo.getSession(sessionId);
    state = session;
  }

  Future<void> createNew() async {
    final session = await repo.createNewSession();
    state = session;
  }

  Future<void> updateSession(ChatSession session) async {
    await repo.saveSession(session);
    state = session;
  }

  Future<void> deleteSession(String sessionId) async {
    await repo.deleteSession(sessionId);
    if (state?.id == sessionId) {
      state = null;
    }
  }
}

final activeChatSessionProvider =
    StateNotifierProvider<ActiveChatSessionController, ChatSession?>((ref) {
  final repo = ref.read(chatSessionRepositoryProvider);
  return ActiveChatSessionController(repo);
});
