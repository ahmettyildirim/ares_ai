import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uygulama genelinde ThemeMode'u yönetecek provider.
/// İleride Settings feature'ından buraya dokunacağız.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

class AresApp extends ConsumerWidget {
  const AresApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Ares AI',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const _RootScreen(),
    );
  }
}

/// Şimdilik placeholder bir ekran.
/// Sonraki sprintlerde burayı router'a bağlayıp
/// onboarding / auth / home akışlarını koyacağız.
class _RootScreen extends ConsumerWidget {
  const _RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ares AI'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Ares AI is up & running 🚀\n\nSprint 1: Architecture skeleton hazır.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
