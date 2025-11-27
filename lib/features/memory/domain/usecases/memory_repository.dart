import '../entities/memory_item.dart';

abstract class MemoryRepository {
  Future<void> addMemory(MemoryItem item);
  Future<List<MemoryItem>> getAllMemories();

  /// Şimdilik basit filtre: query geçen son N kayıt
  Future<List<MemoryItem>> getRelevantMemories(String query, {int limit = 8});

  Future<void> clearAll();
}
