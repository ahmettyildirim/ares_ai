import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_session.dart';
import '../../data/repositories/chat_session_repository.dart';

class ChatSessionsController extends StateNotifier<List<ChatSession>> {
  final ChatSessionRepository repo;

  ChatSessionsController(this.repo) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final sessions = await repo.getSessions();

    // Filter: mesaj yoksa listede görünmesin
    final filtered = sessions.where((s) => s.messages.isNotEmpty).toList();

    state = filtered;
  }
    Future<void> refresh() async {
    await _load();
  }

  Future<ChatSession> createNew() async {
    final session = await repo.createNewSession();
    await _load();
    return session;
  }

  Future<void> deleteSession(String id) async {
    await repo.deleteSession(id);
    await _load();
  }

  Future<void> updateTitle(String id, String newTitle) async {
    await repo.updateTitle(id, newTitle);
    await _load();
  }
}

final chatSessionsProvider =
    StateNotifierProvider<ChatSessionsController, List<ChatSession>>((ref) {
  final repo = ref.read(chatSessionRepositoryProvider);
  return ChatSessionsController(repo);
});
