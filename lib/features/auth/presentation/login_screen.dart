import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../app/core/theme/spacing.dart';
import '../../../app/core/theme/typography.dart';
import '../../../app/widgets/buttons/primary_button.dart';
import '../../../app/widgets/inputs/primary_input.dart';
import '../../../app/di/service_locator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final storage = ref.read(storageServiceProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl * 2),

                // Title
                Text(
                  "welcome_back".tr(),
                  style: AppTypography.h1,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  "login_subtitle".tr(),
                  style: AppTypography.body,
                ),

                const SizedBox(height: AppSpacing.xl * 2),

                // Email
                PrimaryInput(
                  label: "email".tr(),
                  hint: "email_hint".tr(),
                  controller: emailCtrl,
                  icon: Icons.email_outlined,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "email_required".tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Password
                PrimaryInput(
                  label: "password".tr(),
                  hint: "password_hint".tr(),
                  isPassword: true,
                  controller: passwordCtrl,
                  icon: Icons.lock_outline,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "password_required".tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xl * 2),

                // Login Button
                PrimaryButton(
                  label: _loading ? "loading".tr() : "login".tr(),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    setState(() => _loading = true);

                    // Demo Auth (Sprint 5’te backend / LLM auth ekleniyor)
                    await Future.delayed(const Duration(milliseconds: 700));

                    await storage.write("token", "dummy_jwt_token");

                    if (!mounted) return;
                    context.go('/home');

                    setState(() => _loading = false);
                  },
                ),

                const SizedBox(height: AppSpacing.xl * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
