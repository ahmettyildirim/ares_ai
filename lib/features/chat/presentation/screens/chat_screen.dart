import 'package:ares_ai/app/core/theme/spacing.dart';
import 'package:ares_ai/app/widgets/inputs/primary_input.dart';
import 'package:ares_ai/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:ares_ai/features/chat/presentation/widgets/chat_bubble_streaming.dart';
import 'package:ares_ai/features/chat/presentation/widgets/typing/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final scrollCtrl = ScrollController();

  void _scrollToBottom() {
    if (!scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollCtrl.animateTo(
        scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);

    // Auto-scroll her state update’inde tetiklenir
    ref.listen(chatControllerProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(title: const Text("Ares AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Normal mesajlar
                for (final msg in chatState.messages)
                  ChatBubble(message: msg),

                // Eğer AI şu anda yazıyorsa streaming text bubble
                if (chatState.streamingText.isNotEmpty)
                  ChatBubbleStreaming(text: chatState.streamingText),

                // Eğer AI typing indicator açıldıysa
                if (chatState.isAiTyping)
                  const TypingIndicator(),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryInput(
                    label: "Message",
                    controller: _controller,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    ref
                        .read(chatControllerProvider.notifier)
                        .sendUserMessage(text);

                    _controller.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
