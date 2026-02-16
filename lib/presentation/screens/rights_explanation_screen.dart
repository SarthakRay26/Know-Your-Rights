import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../domain/entities/issue.dart';
import '../../l10n/app_strings.dart';

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
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // What the law says
              _SectionHeader(
                icon: Icons.balance,
                title: AppStrings.get(locale, 'what_law_says'),
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
                  icon: Icons.lightbulb_outline,
                  title: AppStrings.get(locale, 'common_myths'),
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
                  icon: Icons.menu_book,
                  title: AppStrings.get(locale, 'applicable_laws'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: content.applicableLaws
                      .map((law) => Chip(
                            label: Text(law),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 28),
              ],

              // Timeline
              _SectionHeader(
                icon: Icons.schedule,
                title: AppStrings.get(locale, 'typical_timeline'),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        content.timelineForLocale(locale),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Navigate to action steps
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

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Myth
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.close, color: Colors.red[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get(locale, 'myth_label'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        myth.mythForLocale(locale),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Fact
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get(locale, 'fact_label'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        myth.factForLocale(locale),
                        style: Theme.of(context).textTheme.bodyLarge,
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
