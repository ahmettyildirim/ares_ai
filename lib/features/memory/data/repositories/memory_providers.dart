import 'package:ares_ai/app/di/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/memory_repository.dart';
import 'local_memory_repository.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  final storage = ref.read(storageServiceProvider);
  return LocalMemoryRepository(storage);
});
