import 'package:ares_ai/app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
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
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
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
      routerConfig: router,
    );
  }
}

/// Şimdilik placeholder bir ekran.
/// Sonraki sprintlerde burayı router'a bağlayıp
/// onboarding / auth / home akışlarını koyacağız.
class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

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
