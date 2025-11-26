import 'package:flutter_riverpod/flutter_riverpod.dart';

/// API istekleri için temel client arayüzü.
/// İleride Dio / http / chopper ne kullanırsak buna implemente edeceğiz.
abstract class ApiClient {
  Future<dynamic> get(String path);
  Future<dynamic> post(String path, {Map<String, dynamic>? body});
}

/// Basit dummy implementation - şimdilik sadece iskelet.
/// Gerçek implemantasyon services/api altına taşınacak.
class ApiClientImpl implements ApiClient {
  @override
  Future<dynamic> get(String path) async {
    // TODO: gerçek HTTP çağrısı eklenecek
    return Future.value(null);
  }

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    // TODO: gerçek HTTP çağrısı eklenecek
    return Future.value(null);
  }
}

/// Yerel storage / secure storage / cache için arayüz.
abstract class StorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

/// Basit dummy implementation.
/// İleride Hive + FlutterSecureStorage ile gerçeklenecek.
class InMemoryStorageService implements StorageService {
  final Map<String, String> _memory = {};

  @override
  Future<void> write(String key, String value) async {
    _memory[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _memory[key];
  }

  @override
  Future<void> delete(String key) async {
    _memory.remove(key);
  }
}

/// AI servisleri (LLM entegrasyonu) için arayüz.
abstract class AiService {
  Future<String> sendMessage(String message, {Map<String, dynamic>? context});
}

/// Dummy implementation.
/// Sonraki sprintte OpenAI entegrasyonunu buraya koyacağız.
class FakeAiService implements AiService {
  @override
  Future<String> sendMessage(String message,
      {Map<String, dynamic>? context}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'Bu sadece dummy AI cevabı. Gerçek LLM entegrasyonu sonraki sprintte gelecek. Mesajın: "$message"';
  }
}

/// Buradan itibaren Riverpod provider'larımız:
///
/// Uygulamanın her yerinde:
/// final api = ref.read(apiClientProvider);
/// şeklinde kullanacağız.

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClientImpl();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return InMemoryStorageService();
});

final aiServiceProvider = Provider<AiService>((ref) {
  return FakeAiService();
});
