import '../entities/chat_message.dart';
import '../../../memory/domain/entities/memory_item.dart';

class PromptBuilder {
  static String build(
    List<ChatMessage> history,
    String newMessage, {
    List<MemoryItem>? memories,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
        "You are Ares AI — a helpful, friendly, intelligent assistant for the user.");
    buffer.writeln();

    if (memories != null && memories.isNotEmpty) {
      buffer.writeln("Here are some important facts about the user and their context:");
      for (final m in memories) {
        buffer.writeln("- ${m.content}");
      }
      buffer.writeln();
    }

    buffer.writeln("Conversation history:");
    for (var msg in history) {
      buffer.writeln("${msg.isUser ? "User" : "Ares"}: ${msg.text}");
    }

    buffer.writeln();
    buffer.writeln("User: $newMessage");
    buffer.writeln("Ares:");

    return buffer.toString();
  }
}
