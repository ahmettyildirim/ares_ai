import 'dart:convert';

import 'package:ares_ai/app/di/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/memory_item.dart';
import '../../domain/usecases/memory_repository.dart';
import '../models/memory_item_model.dart';

const _memoryStorageKey = 'memory_items';

class LocalMemoryRepository implements MemoryRepository {
  final StorageService storage;

  LocalMemoryRepository(this.storage);

  @override
  Future<void> addMemory(MemoryItem item) async {
    final all = await getAllMemories();
    final updated = [...all, item];
    await _saveList(updated);
  }

  @override
  Future<List<MemoryItem>> getAllMemories() async {
    final raw = await storage.read(_memoryStorageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MemoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<MemoryItem>> getRelevantMemories(String query,
      {int limit = 8}) async {
    final all = await getAllMemories();

    final lowered = query.toLowerCase();

    // çok basit bir relevance: content içinde geçenler + tarih/importance
    final filtered = all
        .where((m) => m.content.toLowerCase().contains(lowered))
        .toList()
      ..sort((a, b) {
        final byImportance = b.importance.compareTo(a.importance);
        if (byImportance != 0) return byImportance;
        return (b.lastUsedAt ?? b.createdAt)
            .compareTo(a.lastUsedAt ?? a.createdAt);
      });

    return filtered.take(limit).toList();
  }

  @override
  Future<void> clearAll() async {
    await storage.delete(_memoryStorageKey);
  }

  Future<void> _saveList(List<MemoryItem> items) async {
    final jsonList = items
        .map((e) => MemoryItemModel(
              id: e.id,
              content: e.content,
              createdAt: e.createdAt,
              lastUsedAt: e.lastUsedAt,
              importance: e.importance,
            ).toJson())
        .toList();

    await storage.write(_memoryStorageKey, jsonEncode(jsonList));
  }
}
