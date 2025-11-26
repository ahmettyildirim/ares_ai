import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../app/core/theme/spacing.dart';
import '../../../app/core/theme/typography.dart';
import '../../../app/widgets/buttons/primary_button.dart';
import '../../../app/di/service_locator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);

    // İleride user profile feature’ından gelecek
    final username = "Ahmet";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ares AI"),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await storage.delete("token");
              context.go('/login');
            },
            tooltip: "logout".tr(),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headline
              Text(
                "hello_user".tr(args: [username]),
                style: AppTypography.h1,
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                "what_today".tr(),
                style: AppTypography.body,
              ),

              const SizedBox(height: AppSpacing.xl * 1.5),

              // AI Button
              PrimaryButton(
                label: "ask_ares".tr(),
                icon: Icons.auto_awesome,
                onPressed: () {
                 context.go('/chat');
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Tasks Button
              PrimaryButton(
                label: "my_tasks".tr(),
                icon: Icons.check_circle_rounded,
                onPressed: () {},
              ),

              const SizedBox(height: AppSpacing.lg),

              // Notes Button
              PrimaryButton(
                label: "my_notes".tr(),
                icon: Icons.note_alt_rounded,
                onPressed: () {},
              ),

              const SizedBox(height: AppSpacing.xl * 2),
            ],
          ),
        ),
      ),
    );
  }
}
