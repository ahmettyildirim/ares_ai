import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Buraya ileride: Firebase init, Hive init vb. gelecek.
  // Şimdilik sadece ProviderScope ile Riverpod'u sarıyoruz.

  runApp(
    const ProviderScope(
      child: AresApp(),
    ),
  );
}
