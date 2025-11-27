import '../entities/memory_item.dart';

abstract class MemoryRepository {
  Future<void> addMemory(MemoryItem item);
  Future<List<MemoryItem>> getAllMemories();
  Future<List<MemoryItem>> getRelevantMemories(String query, {int limit = 8});
  Future<void> removeMemoryByContent(String content); 
  Future<void> clearAll();
}
