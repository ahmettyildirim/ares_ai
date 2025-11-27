import 'dart:convert';
import 'package:ares_ai/app/di/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemoryExtractionResult {
  final bool shouldWrite;
  final String? memory;

  MemoryExtractionResult({
    required this.shouldWrite,
    this.memory,
  });
}

class MemoryExtractionService {
  final AiService ai;

  MemoryExtractionService(this.ai);

  Future<MemoryExtractionResult> extract(String userMessage) async {
    final prompt = """
You are a memory extraction module. 
Your job is to analyze the user's message and determine whether it contains 
a personal fact about the user that should be stored as long-term memory.

Only reply in pure JSON format:

{
  "should_write_memory": true/false,
  "memory_to_write": "string or null"
}

Rules:
- Only store facts that help future conversations.
- Examples: user preferences, long-term goals, pets, health info, routines.
- Do NOT store temporary emotions or random chit-chat.
- Be strict: write memory only if valuable.

User message: "$userMessage"
""";

    final raw = await ai.sendMessage(prompt);

    try {
      final jsonMap = jsonDecode(raw);

      return MemoryExtractionResult(
        shouldWrite: jsonMap["should_write_memory"] == true,
        memory: jsonMap["memory_to_write"],
      );
    } catch (_) {
      return MemoryExtractionResult(
        shouldWrite: false,
        memory: null,
      );
    }
  }
}

final memoryExtractionServiceProvider =
    Provider<MemoryExtractionService>((ref) {
  final ai = ref.read(aiServiceProvider);
  return MemoryExtractionService(ai);
});
