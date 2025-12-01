import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_session.dart';

abstract class ChatSessionRepository {
  Future<List<ChatSession>> getSessions();
  Future<ChatSession?> getSession(String sessionId);
  Future<void> saveSession(ChatSession session);
  Future<ChatSession> createNewSession();
  Future<void> deleteSession(String sessionId);
  Future<void> clearAllSessions();
  Future<void> updateTitle(String sessionId, String newTitle);
}

class InMemoryChatSessionRepository implements ChatSessionRepository {
  final List<ChatSession> _sessions = [];

  @override
  Future<List<ChatSession>> getSessions() async {
    // En yeni en üstte
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return _sessions;
  }

  @override
  Future<ChatSession?> getSession(String sessionId) async {
    try {
      return _sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSession(ChatSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);

    if (index == -1) {
      _sessions.add(session);
    } else {
      _sessions[index] = session;
    }

    // Sort after save
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<ChatSession> createNewSession() async {
    final now = DateTime.now();
    final session = ChatSession(
      id: const Uuid().v4(),
      title: "New Chat",
      messages: [],
      createdAt: now,
      updatedAt: now,
    );

    _sessions.add(session);

    // Limit: keep only latest 10
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (_sessions.length > 10) {
      _sessions.removeLast();
    }

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

  @override
  Future<void> updateTitle(String sessionId, String newTitle) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;

    final updated = _sessions[index].copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    );

    _sessions[index] = updated;

    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}

final chatSessionRepositoryProvider =
    Provider<ChatSessionRepository>((ref) => InMemoryChatSessionRepository());
