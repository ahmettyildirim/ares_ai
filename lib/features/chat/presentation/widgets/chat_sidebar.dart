import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/core/theme/spacing.dart';
import '../../domain/entities/chat_session.dart';
import '../controllers/chat_sessions_controller.dart';
import '../controllers/active_chat_session_controller.dart';

class ChatSidebar extends ConsumerWidget {
  const ChatSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👇 mesajı olanlar filtrelenmiş halde geliyor
    final sessions = ref.watch(chatSessionsProvider);
    final active = ref.watch(activeChatSessionProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // NEW CHAT BUTTON
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text("sidebar_new_chat".tr()),
                onPressed: () async {
                  final newSession =
                      await ref.read(chatSessionsProvider.notifier).createNew();

                  ref
                      .read(activeChatSessionProvider.notifier)
                      .loadSession(newSession.id);

                  if (context.mounted) {
                    context.go('/chat/${newSession.id}');
                    Navigator.pop(context);
                  }
                },
              ),
            ),

            const Divider(),

            // SESSION LIST
            Expanded(
              child: ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, i) {
                  final session = sessions[i];
                  final isActive = active?.id == session.id;

                  return Dismissible(
                    key: Key(session.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      await ref
                          .read(chatSessionsProvider.notifier)
                          .deleteSession(session.id);

                      // Eğer aktif chat'i sildiysek → direkt yeni chat aç
                      if (active?.id == session.id) {
                        final newSession = await ref
                            .read(activeChatSessionProvider.notifier)
                            .createNew();

                        context.go('/chat/${newSession.id}');
                      }
                    },
                    child: ListTile(
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
                        Navigator.pop(context);
                      },
                      onLongPress: () {
                        _showRenameDialog(context, ref, session);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          _showSessionMenu(context, ref, session);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.book),
              title: Text("sidebar_memory_viewer".tr()),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text("sidebar_settings".tr()),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, ChatSession session) {
    final controller = TextEditingController(text: session.title);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("rename_chat".tr()),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 50,
        ),
        actions: [
          TextButton(
            child: Text("cancel".tr()),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("save".tr()),
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isEmpty) return;

              await ref
                  .read(chatSessionsProvider.notifier)
                  .updateTitle(session.id, newTitle);

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSessionMenu(
      BuildContext context, WidgetRef ref, ChatSession session) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text("rename_chat".tr()),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, ref, session);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text("delete_chat".tr()),
              onTap: () async {
                Navigator.pop(context);

                await ref
                    .read(chatSessionsProvider.notifier)
                    .deleteSession(session.id);

                // Eğer aktif ise yeni chat aç
                if (ref.read(activeChatSessionProvider)?.id == session.id) {
                  final newSession = await ref
                      .read(activeChatSessionProvider.notifier)
                      .createNew();

                  context.go('/chat/${newSession.id}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
