import '../entities/chat_message.dart';

class PromptBuilder {
  static String build(List<ChatMessage> history, String newMessage) {
    final buffer = StringBuffer();

    buffer.writeln("You are Ares AI — a helpful, friendly, intelligent assistant.");
    buffer.writeln("Conversation history:");

    for (var msg in history) {
      buffer.writeln("${msg.isUser ? "User" : "Ares"}: ${msg.text}");
    }

    buffer.writeln("\nUser: $newMessage");
    buffer.writeln("Ares:");

    return buffer.toString();
  }
}
