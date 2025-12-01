import 'package:ares_ai/features/chat/presentation/controllers/chat_controller.dart';
import 'package:ares_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:ares_ai/features/memory/presentation/screens/memory_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import 'package:ares_ai/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ares_ai/features/splash/presentation/splash_screen.dart';
import 'package:ares_ai/features/auth/presentation/login_screen.dart';
import 'package:ares_ai/features/home/presentation/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Yeni sohbet (ID'siz) - controller ensureSession() ile halledecek
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),

      // Var olan bir session'a gitmek için
      GoRoute(
        path: '/chat/:sessionId',
        name: 'chat_session',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          // Session yüklemesini ChatScreen içinde initState’te de yapıyoruz,
          // ama burada da çağırmak istersen (opsiyonel) kullanabilirsin:
          ref.read(chatControllerProvider.notifier).loadSession(sessionId);
          return ChatScreen(sessionId: sessionId);
        },
      ),

      GoRoute(
        path: '/memory',
        name: 'memory',
        builder: (_, __) => const MemoryViewerScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('404 - Not Found'))),
  );
});
