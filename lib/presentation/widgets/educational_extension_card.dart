import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// A calm, non-intrusive card that offers users the option to explore
/// legal topics in depth through Sarthak Law Academy.
///
/// Placed at the end of [RightsExplanationScreen], after escalation
/// boundaries. Fully localized (en / hi / bn).
class EducationalExtensionCard extends StatelessWidget {
  final String locale;

  static const _academyUrl = 'https://www.sarthaklawacademy.com';

  const EducationalExtensionCard({super.key, required this.locale});

  Future<void> _openAcademy() async {
    final uri = Uri.parse(_academyUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: AppTheme.controlDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.get(locale, 'learn_law_title'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.get(locale, 'learn_law_description'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openAcademy,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(AppStrings.get(locale, 'learn_law_button')),
            ),
          ),
        ],
      ),
    );
  }
}
