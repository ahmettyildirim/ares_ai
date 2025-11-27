import 'package:ares_ai/app/core/theme/spacing.dart';
import 'package:ares_ai/features/memory/data/repositories/memory_providers.dart';
import 'package:ares_ai/features/memory/domain/entities/memory_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemoryViewerScreen extends ConsumerWidget {
  const MemoryViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoryRepo = ref.watch(memoryRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("memory_title".tr()),
      ),
      body: FutureBuilder<List<MemoryItem>>(
        future: memoryRepo.getAllMemories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final memories = snapshot.data!;
          if (memories.isEmpty) {
            return Center(
              child: Text("memory_empty".tr()),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: memories.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) {
              final mem = memories[i];
              return _MemoryCard(memory: mem);
            },
          );
        },
      ),
    );
  }
}

class _MemoryCard extends ConsumerWidget {
  final MemoryItem memory;

  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoryRepo = ref.read(memoryRepositoryProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            memory.content,
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await memoryRepo.removeMemoryByContent(memory.content);

                  // Listeyi güncellemek için provider'ı invalidate et
                  ref.invalidate(memoryRepositoryProvider);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("memory_deleted".tr())),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
