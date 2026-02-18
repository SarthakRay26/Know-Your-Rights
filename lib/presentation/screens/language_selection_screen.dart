import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../l10n/app_locales.dart';
import '../../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// First screen: lets the user choose their preferred language.
/// Persists the choice and navigates to the home screen.
class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // App icon — pastel blue circle with gavel
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  size: 44,
                  color: AppTheme.controlDark,
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Know Your Rights',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'अपने अधिकार जानें',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.fgTertiary,
                    ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Language selection label
              Text(
                AppStrings.get(currentLocale, 'select_language'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              // Language buttons
              ...AppLocales.supported.map((locale) {
                final code = locale.languageCode;
                final isSelected = code == currentLocale;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LanguageButton(
                    label: AppLocales.displayName(code),
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(localeProvider.notifier).setLocale(code);
                    },
                  ),
                );
              }),

              const Spacer(flex: 2),

              // Continue button — dark pill
              ElevatedButton(
                onPressed: () async {
                  await ref.read(onboardingCompleteProvider.notifier).complete();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                },
                child: Text(AppStrings.get(currentLocale, 'continue_btn')),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppTheme.controlDark : AppTheme.surface;
    final fgColor = isSelected ? Colors.white : AppTheme.fgPrimary;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: isSelected ? AppTheme.shadowMd : AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: isSelected ? Colors.white : AppTheme.fgTertiary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: fgColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
