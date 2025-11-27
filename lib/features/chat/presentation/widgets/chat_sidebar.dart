import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../app/core/theme/spacing.dart';
import '../../domain/entities/chat_session.dart';
import '../../data/repositories/chat_session_repository.dart';
import '../controllers/active_chat_session_controller.dart';

class ChatSidebar extends ConsumerWidget {
  const ChatSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(chatSessionRepositoryProvider);
    final active = ref.watch(activeChatSessionProvider);

    return Drawer(
      child: SafeArea(
        child: FutureBuilder<List<ChatSession>>(
          future: repo.getSessions(),
          builder: (context, snapshot) {
            final sessions = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // NEW CHAT BUTTON
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text("sidebar_new_chat".tr()),
                    onPressed: () async {
                      final newSession = await ref
                          .read(activeChatSessionProvider.notifier)
                          .createNew();
                      if (context.mounted) {
                        context.go('/chat/${newSession.id}');
                      }
                    },
                  ),
                ),

                const Divider(),

                // CHAT SESSION LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, i) {
                      final session = sessions[i];
                      final isActive = active?.id == session.id;

                      return ListTile(
                        title: Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        leading: Icon(
                          Icons.chat_bubble_outline,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        onTap: () {
                          ref
                              .read(activeChatSessionProvider.notifier)
                              .loadSession(session.id);

                          context.go('/chat/${session.id}');
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await ref
                                .read(activeChatSessionProvider.notifier)
                                .deleteSession(session.id);

                            if (context.mounted) context.go('/');
                          },
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),

                // FUTURE BUTTONS (Memory Viewer / Settings)
                ListTile(
                  leading: const Icon(Icons.book),
                  title: Text("sidebar_memory_viewer".tr()),
                  onTap: () {
                    // will be used in Sprint 9+
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text("sidebar_settings".tr()),
                  onTap: () {},
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
