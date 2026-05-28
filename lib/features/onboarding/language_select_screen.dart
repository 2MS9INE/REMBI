import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/locale_provider.dart';

class LanguageSelectScreen extends ConsumerWidget {
  const LanguageSelectScreen({super.key});

  Future<void> _selectLanguage(
    BuildContext context,
    WidgetRef ref,
    String code,
  ) async {
    // kab is not a supported Flutter locale — fall back to ar for system locale
    // but save 'kab' so the UI remembers the user's choice
    final localeCode = code == 'kab' ? 'ar' : code;
    ref.read(localeProvider.notifier).setLocale(Locale(localeCode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    await prefs.setString('language', code);
    if (context.mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'اختر لغتك / Choose Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 40),
              _buildLangCard(context, ref, 'العربية', 'ar'),
              const SizedBox(height: 16),
              _buildLangCard(context, ref, 'Français', 'fr'),
              const SizedBox(height: 16),
              _buildLangCard(context, ref, 'English', 'en'),
              const SizedBox(height: 16),
              _buildLangCard(context, ref, 'Tamaziɣt', 'kab'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangCard(
    BuildContext context,
    WidgetRef ref,
    String title,
    String code,
  ) {
    return InkWell(
      onTap: () => _selectLanguage(context, ref, code),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withAlpha(51)),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }
}
