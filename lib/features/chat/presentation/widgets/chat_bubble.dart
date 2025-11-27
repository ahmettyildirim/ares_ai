import 'package:ares_ai/app/core/theme/spacing.dart';
import 'package:ares_ai/features/chat/presentation/controllers/chat_controller.dart';
import 'package:ares_ai/features/memory/data/repositories/memory_providers.dart';
import 'package:ares_ai/features/memory/domain/entities/memory_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';

class ChatBubble extends ConsumerWidget {
  final ChatMessage message;

  const ChatBubble({required this.message, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.isUser;

    final bubbleColor = isUser
        ? Colors.blueAccent
        : Theme.of(context).colorScheme.secondaryContainer;

    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return GestureDetector(
      onLongPress: () => _showMessageMenu(context, ref, message),
      child: Column(
        crossAxisAlignment: align,
        children: [
          // 🔖 Saved Memory Icon
          if (message.isSavedToMemory)
            Padding(
              padding: const EdgeInsets.only(right: 6, left: 6),
              child: Icon(
                Icons.bookmark,
                size: 14,
                color: Colors.amber.shade600,
              ),
            ),

          // 💬 Chat Bubble
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageMenu(BuildContext context, WidgetRef ref, ChatMessage msg) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final memoryRepo = ref.read(memoryRepositoryProvider);
        final isSaved = msg.isSavedToMemory;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 📋 Copy
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: Text('chat_copy'.tr()),          // <-- key
                onTap: () {
                  Clipboard.setData(ClipboardData(text: msg.text));
                  Navigator.pop(context);
                },
              ),

              // 🧠 Memory Toggle
              ListTile(
                leading: Icon(
                  isSaved ? Icons.bookmark_remove : Icons.bookmark_add,
                ),
                title: Text(
                  isSaved
                      ? 'chat_remove_from_memory'.tr()  // <-- key
                      : 'chat_save_to_memory'.tr(),      // <-- key
                ),
                onTap: () async {
                  if (isSaved) {
                    await memoryRepo.removeMemoryByContent(msg.text);
                  } else {
                    await memoryRepo.addMemory(
                      MemoryItem(
                        id: const Uuid().v4(),
                        content: msg.text,
                        createdAt: DateTime.now(),
                        importance: 0.7,
                      ),
                    );
                  }

                  ref
                      .read(chatControllerProvider.notifier)
                      .toggleMessageMemory(msg.id, !isSaved);

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
