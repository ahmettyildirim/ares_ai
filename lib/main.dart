import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Buraya ileride: Firebase init, Hive init vb. gelecek.
  // Şimdilik sadece ProviderScope ile Riverpod'u sarıyoruz.

    runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('tr')],
        path: 'assets/lang',
        fallbackLocale: const Locale('en'),
        child: const AresApp(),
      ),
    ),
  );
}
