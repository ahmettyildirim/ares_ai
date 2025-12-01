import 'package:ares_ai/features/chat/domain/entities/chat_message.dart';
import 'package:uuid/uuid.dart';

class ChatSession {
  final String id;
  String title;
  List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatSession copyWith({
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ChatSession.createEmpty() {
    final now = DateTime.now();
    return ChatSession(
      id: const Uuid().v4(),
      title: "New Chat",
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
  }
}
