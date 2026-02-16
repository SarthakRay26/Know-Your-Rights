import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../l10n/app_locales.dart';
import '../../l10n/app_strings.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // App icon / logo placeholder
              Icon(
                Icons.gavel_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              Text(
                'Know Your Rights',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'अपने अधिकार जानें',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Language selection label
              Text(
                AppStrings.get(currentLocale, 'select_language'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

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

              // Continue button
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
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
