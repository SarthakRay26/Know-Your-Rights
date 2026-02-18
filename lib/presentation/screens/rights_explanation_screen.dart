import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../domain/entities/issue.dart';
import '../../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Shows plain-language legal rights, myths, applicable laws, and timeline.
class RightsExplanationScreen extends ConsumerWidget {
  final Issue issue;

  const RightsExplanationScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final content = issue.content;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(locale, 'your_rights')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Issue title
              Text(
                issue.titleForLocale(locale),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),

              // What the law says
              _SectionHeader(
                icon: Icons.balance_rounded,
                title: AppStrings.get(locale, 'what_law_says'),
                accent: AppTheme.accentBlue,
              ),
              const SizedBox(height: 12),
              Text(
                content.explanationForLocale(locale),
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 28),

              // Common myths
              if (content.myths.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.lightbulb_outline_rounded,
                  title: AppStrings.get(locale, 'common_myths'),
                  accent: AppTheme.accentYellow,
                ),
                const SizedBox(height: 12),
                ...content.myths.map(
                  (myth) => _MythCard(myth: myth, locale: locale),
                ),
                const SizedBox(height: 28),
              ],

              // Applicable laws
              if (content.applicableLaws.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.menu_book_rounded,
                  title: AppStrings.get(locale, 'applicable_laws'),
                  accent: AppTheme.accentPurple,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: content.applicableLaws
                      .map((law) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPurple,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Text(
                              law,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.fgPrimary,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 28),
              ],

              // Timeline
              _SectionHeader(
                icon: Icons.schedule_rounded,
                title: AppStrings.get(locale, 'typical_timeline'),
                accent: AppTheme.accentGreen,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppTheme.controlDark, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        content.timelineForLocale(locale),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.fgPrimary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Navigate to action steps — dark pill button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/action-steps',
                    arguments: issue,
                  );
                },
                child: Text(AppStrings.get(locale, 'see_action_steps')),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, size: 18, color: AppTheme.controlDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

class _MythCard extends StatelessWidget {
  final Myth myth;
  final String locale;

  const _MythCard({required this.myth, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Myth
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Color(0xFFD32F2F), size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get(locale, 'myth_label'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD32F2F),
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        myth.mythForLocale(locale),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.fgPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),
            // Fact
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Color(0xFF2E7D32), size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get(locale, 'fact_label'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        myth.factForLocale(locale),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.fgPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
