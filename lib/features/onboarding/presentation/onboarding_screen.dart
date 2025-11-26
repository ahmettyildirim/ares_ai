import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/core/theme/spacing.dart';
import '../../../app/core/theme/typography.dart';
import '../../../app/widgets/buttons/primary_button.dart';
import '../../../app/di/service_locator.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl * 1.5),

              /// Title
              Text(
                "Welcome to Ares AI",
                style: AppTypography.h1.copyWith(
                  fontSize: 32,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              /// Subtitle
              Text(
                "Your smart personal assistant.\nOrganize your life with AI.",
                style: AppTypography.body.copyWith(
                  fontSize: 18,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              /// Big image placeholder
              Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 160,
                  color: Colors.deepPurple.shade300,
                ),
              ),

              const Spacer(),

              PrimaryButton(
                label: "Continue",
                icon: Icons.arrow_forward_rounded,
                onPressed: () async {
                  await storage.setBool('onboarding_seen', true);
                  context.go('/');
                },
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
