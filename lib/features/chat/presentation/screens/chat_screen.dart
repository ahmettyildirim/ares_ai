import 'package:ares_ai/app/core/theme/spacing.dart';
import 'package:ares_ai/app/widgets/inputs/primary_input.dart';
import 'package:ares_ai/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:ares_ai/features/chat/presentation/widgets/chat_bubble_streaming.dart';
import 'package:ares_ai/features/chat/presentation/widgets/typing/typing_indicator.dart';
import 'package:ares_ai/features/chat/presentation/widgets/chat_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../controllers/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? sessionId;

  const ChatScreen({
    super.key,
    this.sessionId,
  });

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
  void initState() {
    super.initState();
    // İlk açılışta session yükleme / oluşturma
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = ref.read(chatControllerProvider.notifier);
      if (widget.sessionId != null) {
        chat.loadSession(widget.sessionId!);
      } else {
        chat.ensureSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);

    // State değiştikçe auto-scroll
    ref.listen(chatControllerProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/home');
              },
            ),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            ),
          ],
        ),
        title: Text("chat_title".tr()),
      ),
      drawer: const ChatSidebar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Normal mesajlar
                for (final msg in chatState.messages) ChatBubble(message: msg),

                // Streaming bubble
                if (chatState.streamingText.isNotEmpty)
                  ChatBubbleStreaming(text: chatState.streamingText),

                // Typing indicator
                if (chatState.isAiTyping) const TypingIndicator(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryInput(
                    label: "chat_input_placeholder".tr(),
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
