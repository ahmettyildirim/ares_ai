import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_session.dart';

abstract class ChatSessionRepository {
  Future<List<ChatSession>> getSessions();
  Future<ChatSession?> getSession(String sessionId);
  Future<void> saveSession(ChatSession session);
  Future<ChatSession> createNewSession();
  Future<void> deleteSession(String sessionId);
  Future<void> clearAllSessions();
}

class InMemoryChatSessionRepository implements ChatSessionRepository {
  final List<ChatSession> _sessions = [];

  @override
  Future<List<ChatSession>> getSessions() async {
    return _sessions;
  }

  @override
  Future<ChatSession?> getSession(String sessionId) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) {
      return null;
    }
    return _sessions[index];
  }

  @override
  Future<void> saveSession(ChatSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);

    if (index == -1) {
      _sessions.add(session);
    } else {
      _sessions[index] = session;
    }
  }

  @override
  Future<ChatSession> createNewSession() async {
    final session = ChatSession.createEmpty();
    _sessions.add(session);
    return session;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
  }

  @override
  Future<void> clearAllSessions() async {
    _sessions.clear();
  }
}

final chatSessionRepositoryProvider =
    Provider<ChatSessionRepository>((ref) => InMemoryChatSessionRepository());
