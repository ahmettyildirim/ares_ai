import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/repositories/chat_repository.dart';

final chatControllerProvider =
    StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  final repo = ref.read(chatRepositoryProvider);
  return ChatController(repo);
});

class ChatController extends StateNotifier<List<ChatMessage>> {
  final ChatRepository repo;

  ChatController(this.repo) : super([]);

  Future<void> sendUserMessage(String text) async {
    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    state = [...state, userMsg];

    final aiMsg = await repo.sendMessage(state, text);

    state = [...state, aiMsg];
  }
}
